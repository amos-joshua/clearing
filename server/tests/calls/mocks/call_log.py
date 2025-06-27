from typing import override

from clearing_server.core.log_base import LogBase, CallIdentifiable


class MockLog(LogBase):
    def __init__(self, verbose = False):
        self.entries = []
        self.verbose = verbose
        self.server_entries = []

    def _print(self, message: str):
        if self.verbose:
            print(message)

    def warning_entry_count(self):
        return len([entry for entry in self.entries if entry[0] == 'WARNINGS'])

    def error_entry_count(self):
        return len([entry for entry in self.entries if entry[0] == 'ERROR'])

    @override
    def info(self, call: CallIdentifiable, message: str):
        self.entries.append(('INFO', call.uuid, message))
    
    @override
    def warn(self, call: CallIdentifiable, message: str):
        print(f"WARN: {message}")
        self.entries.append(('WARNING', call.uuid, message))
        
    @override
    def error(self, call: CallIdentifiable, message: str, error: Exception | None = None, stacktrace: str | None = None):
        self._print(f"ERROR: {message}")
        if stacktrace is not None:
            self._print(stacktrace)
        self.entries.append(('ERROR', call.uuid, message, error, stacktrace))

    @override
    def state_change(
        self, call: CallIdentifiable, old_state: str, new_state: str, trigger: str
    ):
        self.entries.append(('STATE_CHANGE', old_state, new_state, trigger))

    @override
    def outgoing_event(self, call: CallIdentifiable, dest_queue: str, event: str):
        self.entries.append(('OUTGOING_EVENT', call.uuid, dest_queue, event))

    @override
    def incoming_event(self, call: CallIdentifiable, source_queue: str, event: str):
        self.entries.append(('INCOMING_EVENT', call.uuid, source_queue, event))

    @override
    def server_error(self, message: str, error: Exception | None = None, stacktrace: str | None = None):
        self.server_entries.append(
            (
                message,
                error,
                stacktrace
            )
        )