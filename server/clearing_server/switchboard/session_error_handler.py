import traceback
import uuid

from starlette.websockets import WebSocket

from clearing_server.calls.errors import ExternallyVisibleError
from clearing_server.core.log_base import LogBase
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.model.events import CallError


class SwitchboardErrorHandler:

    def __init__(self, config: ServerConfig, log: LogBase):
        self.config = config
        self.log = log

    async def handle_externally_visible_exception(
        self,
        websocket: WebSocket,
        call_uuid: str,
        error: ExternallyVisibleError,
    ):
        call_error = CallError(
            call_uuid=call_uuid,
            error_code=type(error).__name__,
            error_message=error.message,
        )
        self.log.server_error(
            f"Call {call_uuid} encountered an externally-visible error (reference {error.reference})",
            error=error,
            stacktrace=traceback.format_exc(),
        )
        try:
            await websocket.send_json(call_error.model_dump())
        except RuntimeError:
            pass

    async def handle_server_error(
        self, websocket: WebSocket, call_uuid: str, error: Exception
    ):
        reference = uuid.uuid4().hex
        call_error = CallError(
            call_uuid=call_uuid,
            error_code="Server error",
            error_message=f"The server encountered an error ({reference})",
        )
        self.log.server_error(
            f"Call {call_uuid} encountered a server error (reference {reference})",
            error=error,
            stacktrace=traceback.format_exc(),
        )
        try:
            await websocket.send_json(call_error.model_dump())
        except RuntimeError:
            pass
