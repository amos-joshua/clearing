from typing import AsyncIterator, Callable

from starlette.websockets import WebSocket, WebSocketDisconnect

from clearing_server.core.direction import CallDirection
from clearing_server.core.model.events import (
    CallEvent,
    CallEvents,
    ReceiverDisconnected,
    SenderDisconnected,
)

_RUNTIME_ERROR_MESSAGE_WHEN_REMOTE_WEBSOCKET_CLOSES_FIRST = "Unexpected ASGI message 'websocket.close', after sending 'websocket.close' or response already completed"


class WebSocketChannel:

    def __init__(
        self,
        websocket: WebSocket,
        call_uuid: str,
        direction: CallDirection,
        on_send_error: Callable[[str], None],
        log_debug: Callable[[str], None] | None = None,
    ):
        self.websocket = websocket
        self.call_uuid = call_uuid
        self.direction = direction
        self.on_send_error = on_send_error
        self.log_debug = log_debug

    async def sink(self, event: CallEvent):
        try:
            data = event.model_dump()
            if self.log_debug:
                self.log_debug(f"Sending event to websocket: {data}")
            await self.websocket.send_json(data)
        except RuntimeError as exc:
            self.on_send_error(f"error sending to websocket: {exc}")

    @property
    async def source(self) -> AsyncIterator[CallEvent]:
        while True:
            try:
                data = await self.websocket.receive_json()
                if self.log_debug:
                    self.log_debug(f"Received event data from websocket: {data}")
                yield CallEvents.parse_python(data)
            except WebSocketDisconnect:
                match self.direction:
                    case CallDirection.SENDER:
                        yield SenderDisconnected()
                    case CallDirection.RECEIVER:
                        yield ReceiverDisconnected()
                break

    @staticmethod
    async def close_websocket(websocket: WebSocket):
        try:
            await websocket.close()
        except RuntimeError as exc:
            if (
                _RUNTIME_ERROR_MESSAGE_WHEN_REMOTE_WEBSOCKET_CLOSES_FIRST
                in str(exc)
            ):
                pass
            else:
                raise
