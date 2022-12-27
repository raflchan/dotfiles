from multiprocessing.connection import Client


class SocketClient:
    def send(msg: str) -> None:
        with Client(f'/tmp/notify-log-socket') as client:
            client.send(msg)

