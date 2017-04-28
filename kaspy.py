# -*- encoding: utf-8 -*-
import os.path

import pgpxmlrpc

import settings
import dbutils

IMPORT_KASPY_SQL = 'import_kaspy.sql'


def get_regs_to_import():
    request = pgpxmlrpc.ProxyService(*settings.PYKASSO_XMLRPC_SETTINGS)
    db_conn = dbutils.PlutoConnection(settings.PLUTO_DB)
    last_generated_reg_num = request.report.registry.get_last()
    last_imported_registry = int(db_conn.get_max_imported_registry(prog=2)[0])
    just_created_regs = db_conn.get_registries_with_status(1)
    just_created_reg_nums = [int(item[0]) for item in just_created_regs if item[2] == 2]
    to_import = range(last_imported_registry + 1, last_generated_reg_num + 1)
    to_import.extend(just_created_reg_nums)
    return to_import


def row_to_line(row):
    res = []
    for val in row:
        # if type(val) in (float,):
        #     val = ('%.2f' % val).replace('.', ',')
        res.append(unicode(val).encode('cp1251'))
    return ';'.join(res)


def service_to_line(service):
    """Услугу переданную как словарь представляет в виде строки"""
    # TODO: Заменять отсутствующие поля на строку r'\N'
    if service:
        return u"{};{};{};{}".format(
            service.get('coconut_code') if service.get('coconut_code') else service.get('code'),
            service.get('type'),
            service.get('price'),  # Умножать на quant если quant!=1
            service.get('name')
        ).encode('cp1251')
    else:
        return r'\N;\N;\N;\N'


def save_report_to_file(report_rows, filename):
    with open(filename, 'w') as f:
        for row in report_rows:
            payment_line = row_to_line(row[:-1])
            last_field = row[-1] if row[-1] else [{}]
            for service in last_field:
                service_line = service_to_line(service)
                f.write(';'.join([payment_line, service_line]).replace('None', '\\N') + '\n')


def import_kaspy_from_api():
    request = pgpxmlrpc.ProxyService(*settings.PYKASSO_XMLRPC_SETTINGS)
    db_conn = dbutils.PlutoConnection(settings.PLUTO_DB)
    script_filename = os.path.join(settings.SQL_PATH, IMPORT_KASPY_SQL)

    for reg_num in get_regs_to_import():
        rows = request.report.registry.get(reg_num)

        filename = os.path.join(settings.SAVE_FILES_TO, '{}.csv'.format(reg_num))
        save_report_to_file(rows, filename)

        csv_dbl_slash = filename.replace("\\", "\\\\")
        db_conn.add_registry(str(reg_num), prog=2)
        allow_loading = db_conn.start_registry_loading(str(reg_num), prog=2)
        if allow_loading:
            params = {'registry_name': str(reg_num), 'path': csv_dbl_slash}
            db_conn.exec_script(script_filename, 'utf-8', params, delimiter='$$')


def main():
    import_kaspy_from_api()


if __name__ == '__main__':
    main()
