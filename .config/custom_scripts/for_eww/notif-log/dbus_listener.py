from gi.repository import GLib
import dbus
from dbus.mainloop.glib import DBusGMainLoop
from notification import Notification, Notifications


class DbusListener:

    def __init__(self, notifications: Notifications) -> None:
        self.notifications = notifications

    def print_notification(self, bus, message) -> None:
        keys = ['app_name', 'replaces_id', 'app_icon', 'summary',
                'body', 'actions', 'hints', 'expire_timeout']
        args = message.get_args_list()
        if len(args) == 8:
            _notification = dict([(keys[i], args[i]) for i in range(8)])
            notification = Notification(
                _notification['app_name'],
                _notification['app_icon'],
                _notification['summary'],
                _notification['body'],
                _notification['actions'],
            )
            self.notifications.add(notification)
            print(self.notifications.to_json())

    def run(self):
        loop = DBusGMainLoop(set_as_default=True)
        session_bus = dbus.SessionBus()
        session_bus.add_match_string(
            "type='method_call',interface='org.freedesktop.Notifications',member='Notify',eavesdrop=true")
        session_bus.add_message_filter(self.print_notification)

        GLib.MainLoop().run()
