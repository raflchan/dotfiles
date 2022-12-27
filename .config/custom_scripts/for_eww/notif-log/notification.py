import json
import os

from collections import defaultdict
from dataclasses import dataclass, field
from io import TextIOWrapper
from typing import List

from discord_icon_decoder import save_image_bytes
from globals import LOG_PATH


def _last_line(path: str) -> str:
    with open(path, 'rb') as f:
        try:  # catch OSError in case of a one line file
            f.seek(-2, os.SEEK_END)
            while f.read(1) != b'\n':
                f.seek(-2, os.SEEK_CUR)
        except OSError:
            f.seek(0)
        return f.readline().decode()


@dataclass
class Notification:
    app_name: str
    app_icon: str
    summary: str
    body: str
    actions: str
    hints: dict = field(default_factory=dict)
    id: int = 0

    def to_json(self) -> str:
        return json.dumps(self.__dict__)

    def clean(self):
        # app_icon
        if self.app_icon:
            strip_prefixes = ["file://"]
            app_icon = self.app_icon
            for prefix in strip_prefixes:
                if app_icon.startswith(prefix):
                    app_icon = app_icon.removeprefix(prefix)
            self.app_icon = app_icon

        if "icon_data" in self.hints.keys():
            self.app_icon = save_image_bytes(self.hints["icon_data"])
            self.hints["icon_data"] = ''

        return self

class Notifications:

    def __init__(self) -> None:
        self._counter = 0
        self._notifications: List[Notification] = []

        self._cache_dir = LOG_PATH
        cache_exists = os.path.exists(self._cache_dir)

        if cache_exists:
            last_state = _last_line(self._cache_dir)
            highest_count = 0
            for notification in json.loads(last_state):
                if notification['id'] > highest_count:
                    highest_count = notification['id']
                self._notifications.append(Notification(**notification))
            self._counter = highest_count

        self._file: TextIOWrapper = open(self._cache_dir, 'a+', buffering=1)
        self._write()

    def __delete__(self) -> None:
        if self._file is not None:
            self._file.close()



    def add(self, notification: Notification) -> None:
        self._counter += 1
        notification.id = self._counter
        self._notifications.append(notification.clean())
        self._write()

    def remove(self, id: int) -> None:
        to_delete = list(filter(lambda x: x.id == id, self._notifications))
        if len(to_delete) > 0:
            to_delete = to_delete[0]
            self._notifications.remove(to_delete)
        self._write()

    def remove_all(self) -> None:
        self._notifications.clear()
        self._write()

    def _sort(self) -> None:
        self._notifications.sort(key=lambda x: x.id, reverse=True)

    def to_json(self) -> str:
        self._sort()
        return json.dumps([x.__dict__ for x in self._notifications])

    def _write(self) -> None:
        self._file.write(self.to_json() + '\n')
