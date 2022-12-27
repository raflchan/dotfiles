import os

from collections import defaultdict
from dataclasses import dataclass, field
from threading import Thread
from multiprocessing.connection import Listener
from time import sleep
from typing import Callable, Dict
from sys import stderr

CONNECTION_TIMEOUT = .1

@dataclass
class Runner:

    name: str
    click_left          : Callable = lambda: None
    click_right         : Callable = lambda: None
    click_middle        : Callable = lambda: None
    double_click_left   : Callable = lambda: None
    double_click_right  : Callable = lambda: None
    double_click_middle : Callable = lambda: None
    scroll_up           : Callable = lambda: None
    scroll_down         : Callable = lambda: None

    click_left_kwargs          : Dict = field(default_factory=lambda: defaultdict(dict))
    click_right_kwargs         : Dict = field(default_factory=lambda: defaultdict(dict))
    click_middle_kwargs        : Dict = field(default_factory=lambda: defaultdict(dict))
    double_click_left_kwargs   : Dict = field(default_factory=lambda: defaultdict(dict))
    double_click_right_kwargs  : Dict = field(default_factory=lambda: defaultdict(dict))
    double_click_middle_kwargs : Dict = field(default_factory=lambda: defaultdict(dict))
    scroll_up_kwargs           : Dict = field(default_factory=lambda: defaultdict(dict))
    scroll_down_kwargs         : Dict = field(default_factory=lambda: defaultdict(dict))


    initial         : Callable = lambda: None
    pre_action      : Callable = lambda: None
    post_action     : Callable = lambda: None
    outputter       : Callable = lambda: None
    custom_command  : Callable = lambda: None

    initial_kwargs          : Dict = field(default_factory=lambda: defaultdict(dict))
    pre_action_kwargs       : Dict = field(default_factory=lambda: defaultdict(dict))
    post_action_kwargs      : Dict = field(default_factory=lambda: defaultdict(dict))
    outputter_kwargs        : Dict = field(default_factory=lambda: defaultdict(dict))
    custom_command_kwargs   : Dict = field(default_factory=lambda: defaultdict(dict))

    disable_outputter   : bool = False
    disable_logging     : bool = False

    def log(self, *msgs):
        if not self.disable_logging:
            print(f'[RUNNER:{self.name}]', *msgs, file=stderr)

    def run(self):
        connection_handler = Thread(target=self._connection_handler)
        connection_handler.start()

        if not self.disable_outputter:
            outputter = Thread(target=self._outputter)
            outputter.start()

    def _outputter(self):
        def log(*msgs):
            self.log('[_outputter]', *msgs)
        
        while True:
            # TODO: make this so awesomewm notifies this script if there is a change
            self.outputter(**self.outputter_kwargs)
            sleep(.1)

    def _connection_handler(self):
        def log(*msgs):
            self.log('[_connection_handler]', *msgs)
        # TODO: delete socket fd if exist
        socket_path = f'/tmp/rafl_runner_socket_{self.name}'
        if os.path.exists(socket_path):
            os.remove(socket_path)
        listener = Listener(socket_path)
        self.initial(**self.initial_kwargs)
        while True:
            with listener.accept() as connection:
                log('connection accepted')
                if not connection.poll(CONNECTION_TIMEOUT):
                    log('connection dropped due to timeout')
                    continue
                msg = connection.recv()
                self.pre_action(**self.pre_action_kwargs)
                match msg.split():
                    case ['click-left']:
                        log(msg)
                        self.click_left(**self.click_left_kwargs)
                    case ['click-middle']:
                        log(msg)
                        self.click_middle(**self.click_middle_kwargs)
                    case ['click-right']:
                        log(msg)
                        self.click_right(**self.click_right_kwargs)
                    case ['double-click-left']:
                        log(msg)
                        self.double_click_left(**self.double_click_left_kwargs)
                    case ['double-click-middle']:
                        log(msg)
                        self.double_click_middle(**self.double_click_middle_kwargs)
                    case ['double-click-right']:
                        log(msg)
                        self.double_click_right(**self.double_click_right_kwargs)
                    case ['scroll-up']:
                        log(msg)
                        self.scroll_up(**self.scroll_up_kwargs)
                    case ['scroll-down']:
                        log(msg)
                        self.scroll_down(**self.scroll_down_kwargs)
                    case ['custom', *args]:
                        log('[custom]', msg)
                        self.custom_command(**self.custom_command_kwargs, msg=msg)
                    case _:
                        log('unknown command')
            self.post_action(**self.post_action_kwargs)
            log('connection dropped')
