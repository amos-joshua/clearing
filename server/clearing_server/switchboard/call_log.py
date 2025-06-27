import datetime
from typing import override

import firebase_admin.db

from clearing_server.core.log_base import CallIdentifiable, LogBase
from clearing_server.core.model.config import ServerConfig


class LogFirebase(LogBase):

    def __init__(self, config: ServerConfig):
        self.config = config
        self.verbose = config.verbose_log

    @override
    def info(self, call: CallIdentifiable, message: str):
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "INFO",
                "message": message,
            }
        )
        if self.verbose:
            print(f"INFO[call {call.uuid}]: {message}")

    @override
    def warn(self, call: CallIdentifiable, message: str):
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "WARN",
                "message": message,
            }
        )
        if self.verbose:
            print(f"WARN[call {call.uuid}]: {message}")

    @override
    def error(
        self,
        call: CallIdentifiable,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "ERROR",
                "error": type(error).__name__,
                "message": message,
                "stacktrace": stacktrace,
            }
        )
        if self.verbose:
            print(f"ERROR[call {call.uuid}]: {message}: {error}\n{stacktrace}")

    @override
    def state_change(
        self,
        call: CallIdentifiable,
        old_state: str,
        new_state: str,
        trigger: str,
    ):
        if self.verbose:
            print(
                f"STATE_CHANGE [{call}]: {old_state}->{new_state} because of {trigger}"
            )
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "STATE-CHANGE",
                "old_state": old_state,
                "new_state": new_state,
                "trigger": trigger,
            }
        )
        firebase_admin.db.reference(
            f"/{self.config.firebase_directed_call_path(call.uuid, call.direction)}"
        ).update({"state": new_state})

    @override
    def outgoing_event(
        self, call: CallIdentifiable, dest_queue: str, event: str
    ):
        if self.verbose:
            print(f"OUTGOING-EVENT: {event} -> {dest_queue}")
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "OUTGOING_EVENT",
                "dest_queue": dest_queue,
                "message": event,
            }
        )

    @override
    def incoming_event(
        self, call: CallIdentifiable, source_queue: str, event: str
    ):
        if self.verbose:
            print(f"INCOMING_EVENT: {event} <- {source_queue}")
        firebase_admin.db.reference(
            self.config.firebase_call_log_path(call)
        ).push(
            {
                "timestamp": datetime.datetime.now().isoformat(),
                "type": "INCOMING_EVENT",
                "source_queue": source_queue,
                "message": event,
            }
        )

    @override
    def server_error(
        self,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        if self.verbose:
            print(f"SERVER ERROR: {message} ({error})")
            if stacktrace:
                print(stacktrace)
        logs_path = self.config.firebase_server_logs()
        logs_reference = firebase_admin.db.reference(logs_path)
        logs_reference.push(
            {
                "message": message,
                "error": type(error).__name__,
                "stacktrace": stacktrace,
                "timestamp": datetime.datetime.now().isoformat(),
            }
        )

    @override
    def push_notification_error(
        self,
        message: str,
        error: Exception | None = None,
        stacktrace: str | None = None,
    ):
        if self.verbose:
            print(f"PUSH NOTIFICATION ERROR: {message} ({error})")
            if stacktrace:
                print(stacktrace)
        logs_path = self.config.firebase_push_notification_logs()
        logs_reference = firebase_admin.db.reference(logs_path)
        logs_reference.push(
            {
                "message": message,
                "error": type(error).__name__,
                "stacktrace": stacktrace,
                "timestamp": datetime.datetime.now().isoformat(),
            }
        )

    @override
    def push_notification_debug(self, message: str):
        if self.verbose:
            print(f"PUSH NOTIFICATION INFO: {message}")
