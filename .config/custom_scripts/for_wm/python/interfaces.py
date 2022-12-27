#!/usr/bin/python3 -u

import json
import psutil

import typer

from dataclasses import dataclass
from subprocess import Popen, PIPE
from typing import List, TypedDict

from utils.runner import Runner
from utils.communicator import Communicator

app = typer.Typer()


MODULE_NAME = 'interfaces'


@app.command()
def server():

    class Interface(TypedDict):
        name: str
        address: str

    def generate_interfaces() -> List[Interface]:
        all_interfaces: dict = json.loads(json.dumps(psutil.net_if_addrs()))
        interfaces: List[Interface] = [Interface(
            name=x, address=all_interfaces[x][0][1]) for x in all_interfaces.keys() if x != 'lo']
        return interfaces

    @dataclass
    class CustomData:
        current_position: int = 0

        def inc(self):
            self.current_position += 1 % len(generate_interfaces())
            print(self.current_position)

        def dec(self):
            self.current_position - + 1 % len(generate_interfaces())
            print(self.current_position)

    def click_left(test_obj: CustomData):
        copy_cmd = 'xclip -i -rmlastnl -selection "clipboard"'
        address = generate_interfaces()[test_obj.current_position]['address']
        p = Popen(copy_cmd, shell=True,  stdin=PIPE)
        p.communicate(input=bytes(address, 'utf-8'))

    t = CustomData()
    Runner(
        MODULE_NAME,
        click_left=click_left,
        click_left_kwargs={'test_obj': t},
        scroll_up=lambda: t.inc(),
        scroll_down=lambda: t.dec(),
    ).run()


@app.command()
def client(command: str):
    Communicator(MODULE_NAME).run(command)


if __name__ == '__main__':
    app()
