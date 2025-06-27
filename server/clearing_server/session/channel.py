import asyncio
from dataclasses import dataclass, field
from typing import AsyncIterator, Callable

from clearing_server.core.direction import CallDirection
from clearing_server.core.event_sinks import AsyncConsumer
from clearing_server.session.utils import cancel_and_await


@dataclass(slots=True)
class CallChannel:
    direction: CallDirection
    event_source: AsyncIterator
    event_sink: AsyncConsumer
    on_queue_error: Callable[[Exception], None]

    _feed_queue_task: asyncio.Task | None = field(default=None, init=False)

    async def _feed_queue(self, queue: asyncio.Queue):
        try:
            async for event in self.event_source:
                await queue.put((self.direction, event))
        except Exception as exc:
            self.on_queue_error(exc)

    def start(self, send_events_to: asyncio.Queue):
        self._feed_queue_task = asyncio.create_task(
            self._feed_queue(send_events_to)
        )

    async def stop(self):
        await cancel_and_await(self._feed_queue_task)
