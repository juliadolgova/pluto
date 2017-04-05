from stream import *


def manage_file_my(fn):
    try:
        manage_file(fn)
    except:
        print 'error while uploading {}'.format(fn)


def filter_regs_from_stream_my(message):
    return 'Daily_Registry' in message["subject"]
    # return True


utils.check_files_in_mail(settings.MAIL_POP3, filter_regs_from_stream_my, manage_file_my)
