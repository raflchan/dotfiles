from multiprocessing.connection import Client

from globals import SOCKET_PATH

class SocketClient:
    def send(msg: str) -> None:
        with Client(SOCKET_PATH) as client:
            client.send(msg)

