from multiprocessing.connection import Client

class Communicator:
    def __init__(self, name: str):
        self.name = name

    def run(self, command: str, await_reply: bool = False):
        client = Client(f'/tmp/rafl_runner_socket_{self.name}')
        client.send(command)
        if await_reply:
            print(client.recv())
        client.close()
        