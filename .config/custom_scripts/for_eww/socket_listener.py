from multiprocessing.connection import Listener
from notification import Notifications

CONNECTION_TIMEOUT = .1


class SocketListener:
    def __init__(self, notifications: Notifications) -> None:
        self._notifications: Notifications = notifications

    def run(self) -> None:
        listener = Listener(f'/tmp/notify-log-socket')
        while True:
            with listener.accept() as connection:
                if not connection.poll(CONNECTION_TIMEOUT):
                    continue
                msg = connection.recv()
                match msg.split():
                    case ['clear', *args]:
                        id = int(args[0])
                        self._notifications.remove(id)
                        print(self._notifications.to_json())
                    case ['clear-all']:
                        self._notifications.remove_all()
                        print(self._notifications.to_json())
                connection.close()
