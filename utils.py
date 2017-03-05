# -*- encoding: utf-8 -*-
import poplib
import email
import os.path
from functools import partial
import zipfile

from settings import SAVE_FILES_TO


# callback_func - функция, получает в параметре сообщение
# filter - функция, получает в параметре сообщение, возвращает true если требуется обработка
def check_mail(mail_pop3, filter_func=None, callback_func=None):
    server = mail_pop3['server']
    port = mail_pop3['port']
    login = mail_pop3['login']
    password = mail_pop3['password']

    box = poplib.POP3(server, port)
    box.user(login)
    box.pass_(password)

    response, lst, octets = box.list()

    for msg_num, msg_size in [i.split() for i in lst]:
        (resp, lines, _) = box.retr(msg_num)
        msg_text = '\n'.join(lines) + "\n\n"
        message = email.message_from_string(msg_text)
        if not filter_func or filter_func(message):
            callback_func(message)
    box.quit()


def extractfile_and_callback(message, callback_func=None):
    for part in message.walk():
        filename = part.get_filename()
        if filename:
            part.get_payload()
            try:
                file_path = os.path.join(SAVE_FILES_TO, filename)
                f = open(file_path, 'wb')
                msg_buffer = part.get_payload(decode=True)
                if msg_buffer:
                    f.write(msg_buffer)
                f.close()
                if callback_func:
                    callback_func(file_path)
            except IOError:
                # TODO вероятно в названии файла русские буквы, надо подумать о преобразовании кодировки
                # Когда не может сохранить то тоже глушится - исправить!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
                if __debug__:
                    print "Cannot save file {}".format(filename)
                pass


#  callback_func - функция, получает в параметре путь к файлу
def check_files_in_mail(mail_pop3, filter_func=None, callback_func=None):
    check_mail(mail_pop3, filter_func, partial(extractfile_and_callback, callback_func=callback_func))


def unzip_in_same_dir(filename):
    file_dir = os.path.dirname(filename)
    cur_dir = os.path.realpath(os.curdir)
    if file_dir:
        os.chdir(file_dir)
    file_basename = os.path.basename(filename)

    zipp = zipfile.ZipFile(file_basename, mode='r')
    zipp.extractall()
    zipp.close()

    os.chdir(cur_dir)
    return zipp.namelist()


def array_pad(lst, size, value):
    if size >= 0:
        return lst + [value] * (size - len(lst))
    else:
        return [value] * (-size - len(lst)) + lst
