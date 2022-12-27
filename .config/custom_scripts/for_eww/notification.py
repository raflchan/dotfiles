from dataclasses import dataclass
from typing import List
import json


@dataclass
class Notification:
    app_name: str
    app_icon: str
    summary: str
    body: str
    actions: str
    id: int = 0

    def to_json(self) -> str:
        return json.dumps(self.__dict__)


class Notifications:
    def __init__(self) -> None:
        self._counter = 0
        self._notifications: List[Notification] = []

    def add(self, notification: Notification) -> None:
        self._counter += 1
        notification.id = self._counter
        self._notifications.append(notification)

    def remove(self, id: int) -> None:
        to_delete = list(filter(lambda x: x.id == id, self._notifications))
        if len(to_delete) > 0:
            to_delete = to_delete[0]
            self._notifications.remove(to_delete)
    
    def remove_all(self) -> None:
        self._notifications.clear()

    def _sort(self) -> None:
        self._notifications.sort(key=lambda x: x.id, reverse=True)

    def to_json(self) -> str:
        self._sort()
        return json.dumps([x.__dict__ for x in self._notifications])
