import os
from multiprocessing.connection import Listener

from notification import Notifications
from globals import SOCKET_PATH

CONNECTION_TIMEOUT = .1

class SocketListener:
    def __init__(self, notifications: Notifications) -> None:
        self._notifications: Notifications = notifications
        self.listener: Listener = None

    def __delete__(self):
        if self.listener is not None:
            self.listener.close()

    def run(self) -> None:
        if os.path.exists(SOCKET_PATH):
            os.remove(SOCKET_PATH)
        self.listener = Listener(SOCKET_PATH)
        while True:
            with self.listener.accept() as connection:
                if not connection.poll(CONNECTION_TIMEOUT):
                    continue
                msg = connection.recv()
                match msg.split():
                    case ['clear', *args]:
                        id = int(args[0])
                        self._notifications.remove(id)
                    case ['clear-all']:
                        self._notifications.remove_all()
                        # print(self._notifications.to_json()
                connection.close()
