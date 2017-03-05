# -*- encoding: utf-8 -*-
import os.path

import settings
import dbutils
from kaspy import row_to_line


EXPORT_DIR = settings.EXPORT_DIR


def export_table_to_csv(table_name):
    db_conn = dbutils.PlutoConnection(settings.PLUTO_DB)
    sql = "select * from %s" % table_name
    cursor = db_conn.db.cursor()
    cursor.execute(sql)
    with open(os.path.join(EXPORT_DIR, table_name+'.csv'), 'w') as f:
        f.write(';'.join([item[0] for item in cursor.description]) + '\n')
        for rec in cursor.fetchall():
            f.write(row_to_line(rec) + '\n')
    cursor.close()


def main():
    export_table_to_csv('v_accepted_payments')
    export_table_to_csv('v_forbidden_payments')


if __name__ == '__main__':
    main()
