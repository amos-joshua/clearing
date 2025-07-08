from clearing_server.core.call_identifiable import CallIdentifiable


class LogBase:

    def debug(self, call: CallIdentifiable, message: str):
        raise NotImplemented()

    def info(self, call: CallIdentifiable, message: str):
        raise NotImplemented()

    def warn(self, call: CallIdentifiable, message: str):
        raise NotImplemented()

    def error(
        self,
        call: CallIdentifiable,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        raise NotImplemented()

    def state_change(
        self,
        call: CallIdentifiable,
        old_state: str,
        new_state: str,
        trigger: str,
    ):
        raise NotImplemented()

    def outgoing_event(
        self, call: CallIdentifiable, dest_queue: str, event: str
    ):
        raise NotImplemented()

    def incoming_event(
        self, call: CallIdentifiable, source_queue: str, event: str
    ):
        raise NotImplemented()

    def server_error(
        self,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        raise NotImplemented()

    def push_notification_error(
        self,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        raise NotImplemented()

    def push_notification_debug(self, message: str):
        raise NotImplemented()
