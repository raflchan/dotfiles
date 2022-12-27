#!/usr/bin/python3

import json
import os

from dataclasses import dataclass
from multiprocessing.connection import Client, Listener
from multiprocessing import Queue
from subprocess import PIPE, Popen
from typing import List, TextIO

import typer

app = typer.Typer()

MODULE_NAME = 'tags'
CONNECTION_TIMEOUT = .1
LOGGING = False

@dataclass
class Screen:
    path: str
    fd: TextIO
    number: int

class Communicator:
    def __init__(self, name: str):
        self.name = name

    def run(self, command: str, await_reply: bool = False):
        client = Client(f'/tmp/rafl_runner_socket_{self.name}')
        client.send(command)
        if await_reply:
            print(client.recv())
        client.close()
        

class Handler:

    def __init__(self, name: str) -> None:
        self.name = name
        self.screens: List[Screen] = []
        self.socket_path = f'/tmp/rafl_runner_socket_{self.name}'
        self.prints = 0

    def __del__(self):
        for screen in self.screens:
            screen.fd.close()
            os.remove(screen.path)

    name: str

    def get_tags() -> List:
        cmd = 'awesome-client \'return get_tags()\''
        p = Popen(cmd, shell=True, stdout=PIPE)
        out = []
        for line in p.stdout.readline():
            out.append(line)
        out = ''.join([chr(char) for char in out])
        out = out.strip().removeprefix('string "').removesuffix('"')
        return json.loads(out)

    def print_tags(self):
        for screen in self.screens:
            if screen.number >= len(self.screens):
                print("[tags.py] INVALID SCREEN SUBSCRIPTION???")
                return
            output = Handler.get_tags()[screen.number]
            fd = screen.fd
            if self.prints >= 100:
                fd.truncate(0)
                fd.flush()
            fd.write(json.dumps(output))
            fd.write('\n')
            fd.flush()


    def run(self):
        def log(*msgs):
            if LOGGING:
                print('[_connection_handler]', *msgs)
        
        if os.path.exists(self.socket_path):
            os.remove(self.socket_path)
        listener = Listener(self.socket_path)
        while True:
            with listener.accept() as connection:
                log('connection accepted')
                if not connection.poll(CONNECTION_TIMEOUT):
                    log('connection dropped due to timeout')
                    continue
                msg = connection.recv()
                match msg.split():
                    case ['update']:
                        self.print_tags()
                    case ['subscribe', *msg]:
                        screen = msg[0]
                        if int(screen) not in [x.number+1 for x in self.screens]:
                            path = f'/tmp/rafl_runner_subscription_{self.name}_{screen}'
                            self.screens.append(Screen(path, open(path, 'w'), int(screen)-1))
                        else:
                            path = {str(x.number+1): x.path for x in self.screens}[str(screen)]
                        connection.send(path)
            log('connection closed')
            


@app.command()
def client(command: str):
    reply = False
    if 'subscribe' in command.split():
        reply = True
    Communicator(MODULE_NAME).run(command, await_reply=reply)

@app.command()
def server():
    Handler(MODULE_NAME).run()

if __name__ == '__main__':
    app()
