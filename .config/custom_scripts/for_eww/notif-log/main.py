#! /usr/bin/python3
from threading import Thread

import typer

from dbus_listener import DbusListener
from notification import Notifications
from socket_client import SocketClient
from socket_listener import SocketListener
app = typer.Typer()

# class Runner:
#     def __init__(self, notifications: Notifications, target_class) -> None:
#         self._notifications: Notifications = notifications
#         self._target_class = target_class
#         self._thread: Thread = None

#     def run(self):
        
#         self._thread = Thread(target=self._target_class(self._notifications))
#         self._thread.run()
#         return self
    

@app.command()
def server():
    notifications: Notifications = Notifications()

    # Runner(notifications, DbusListener).run()
    dbus_listener = DbusListener(notifications)
    dbus_thread = Thread(target=dbus_listener.run)
    dbus_thread.start()

    socket_listener = SocketListener(notifications)
    socket_thread = Thread(target=socket_listener.run)
    socket_thread.start()


@app.command()
def client(command: str):
    SocketClient.send(command)


if __name__ == '__main__':
    app()
