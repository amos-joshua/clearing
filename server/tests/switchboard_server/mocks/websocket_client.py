import traceback
from contextlib import asynccontextmanager
from typing import Callable, AsyncIterator

import websockets
import asyncio

from websockets import ClientConnection

from clearing_server.core.model.events import CallEvent, CallEvents


class ScriptedWebsocketClient:
    def __init__(
        self):
        self.outgoing_events: list[CallEvent | float | Callable] = []
        self.incoming_events = []
        self.websocket: ClientConnection | None = None
        self._feed_task = None
        self._receive_task = None

    async def send(self, outgoing_events: list[CallEvent | float]):
        if not self.websocket:
            raise RuntimeError("send() called outside of connect() context")
        for event in outgoing_events:
            if isinstance(event, float):
                await asyncio.sleep(event)
            else:
                await self.websocket.send(event.model_dump_json())


    async def _receive_events(self, websocket: ClientConnection):
        while True:
            try:
                data = await websocket.recv()
                try:
                    event = CallEvents.parse_json(data)
                    self.incoming_events.append(event)
                except RuntimeError:
                    self.incoming_events.append(data)
            except websockets.exceptions.ConnectionClosed:
                break

    
    async def run(self, endpoint:str, outgoing_events: list[CallEvent | float]):
        async with self.connect(endpoint):
            await self.send(outgoing_events)


    @asynccontextmanager
    async def connect(self, endpoint: str) -> AsyncIterator['ScriptedWebsocketClient']:
        exception = None
        try:
            self.websocket = await websockets.connect(endpoint)
            self._receive_task = asyncio.create_task(self._receive_events(self.websocket))
            try:
                yield self
            except websockets.exceptions.ConnectionClosed:
                # the client closed the connection while we were sending, but that's ok
                pass
            except Exception as exc:
                print(f"An error occurred inside ScriptedWebsocketClient.connect({endpoint}):")
                traceback.print_exc()
                exception = exc
            self._receive_task.cancel()
            try:
                await self._receive_task
            except asyncio.CancelledError:
                pass

        finally:
            if  self.websocket:
                await self.websocket.close()


        if exception:
            raise RuntimeError(f"failure in ScriptedWebsocketClient.connect({endpoint})")



