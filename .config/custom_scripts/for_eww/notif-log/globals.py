import os

SOCKET_PATH = '/tmp/notify-log-socket'
LOG_PATH = os.path.join(os.environ['HOME'], '.cache/notif-log/log.txt')
if not os.path.exists(os.path.dirname(LOG_PATH)):
    os.makedirs(os.path.dirname(LOG_PATH))