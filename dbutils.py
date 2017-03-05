# -*- encoding: utf-8 -*-
import MySQLdb
import time


class PlutoConnection(object):
    def __init__(self, db_connection_settings):
        self.db = MySQLdb.connect(**db_connection_settings)

    def __del__(self):
        self.db.close()

    def exec_script(self, filename, coding='utf-8', params=None, delimiter=';'):
        with open(filename, 'rb') as f:
            lines = f.readlines()
        sql = ''.join(lines).decode(coding) % params
        sql = sql.encode('utf-8')
        for sql_command in sql.split(delimiter):
            if sql_command.strip() != '':
                try:
                    self.db.query(sql_command)
                    self.db.commit()
                except:
                    if __debug__:
                        print sql_command
                    raise

    def add_registry(self, registry_name, prog):
        params = {'registry_name': registry_name, 'prog': prog}
        sql = "SELECT registry_id FROM registry WHERE name = '%(registry_name)s' and prog = %(prog)d"
        self.db.query(sql % params)
        data = self.db.store_result().fetch_row()
        if len(data) == 0:
            sql = "insert into registry(`name`, `prog`, `status`) VALUES ('%(registry_name)s', %(prog)d, 1)"
            self.db.query(sql % params)
            insert_id = self.db.insert_id()
            self.db.commit()
            return insert_id
        else:
            return data[0][0]

    def start_registry_loading(self, registry_name, prog):
        params = {'registry_name': registry_name, 'prog': prog}
        sql = "select registry_loading_allowed(%(prog)d, '%(registry_name)s')"
        self.db.query(sql % params)
        data = self.db.store_result().fetch_row()
        self.db.commit()
        return data[0][0]

    def get_max_imported_registry(self, prog):
        params = {'prog': prog}
        sql = """
            select name, registry_id
            from registry
            where prog = %(prog)d and status=3
            order by name desc
            limit 1
        """
        self.db.query(sql % params)
        data = self.db.store_result().fetch_row()
        if data:
            return data[0]
        else:
            return['0', 0]

    def get_registries_with_status(self, status):
        sql = """
            SELECT name, registry_id, prog
            FROM registry
            WHERE status = %(status)d
        """
        cursor = self.db.cursor()
        cursor.execute(sql % {'status': status})
        return [rec for rec in cursor.fetchall()]

