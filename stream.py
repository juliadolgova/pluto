# -*- encoding: utf-8 -*-
import os.path

import settings
import utils
import dbutils

IMPORT_STREAM_SQL = 'import_stream.sql'


def manage_file(filename):
    # TODO учесть, что в архиве может быть папка
    file_list = [filename]
    if filename.endswith('zip'):
        file_list.extend([os.path.join(os.path.dirname(filename), fn) for fn in utils.unzip_in_same_dir(filename)])
    script_filename = os.path.join(settings.SQL_PATH, IMPORT_STREAM_SQL)
    db_conn = dbutils.PlutoConnection(settings.PLUTO_DB)
    for csv in (item for item in file_list if item.endswith('csv')):
        registry_name = os.path.splitext(os.path.basename(csv))[0]
        csv_dbl_slash = csv.replace("\\", "\\\\")
        inserted_registry = db_conn.add_registry(registry_name, prog=1)
        if __debug__:
            print 'inserted_registry:', inserted_registry
        allow_loading = db_conn.start_registry_loading(registry_name, prog=1)
        if __debug__:
            print 'allow_loading:', allow_loading
        if allow_loading:
            params = {'registry_name': registry_name, 'path': csv_dbl_slash}
            db_conn.exec_script(script_filename, 'utf-8', params, delimiter='$$')


def filter_regs_from_stream(message):
    return (message["from"].lower() == 'spps@nskes.ru') and ('Daily_Registry' in message["subject"])


def import_stream_files_from_mail():
    utils.check_files_in_mail(settings.MAIL_POP3, filter_regs_from_stream, manage_file)


def main():
    import_stream_files_from_mail()


if __name__ == '__main__':
    main()
