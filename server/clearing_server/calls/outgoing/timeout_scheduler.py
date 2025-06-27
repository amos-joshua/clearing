import asyncio
from typing import Callable

from clearing_server.core.direction import CallDirection
from clearing_server.core.model.events import CallTimeout


class TimeoutScheduler:
    def __init__(
        self,
        call_event_queue: asyncio.Queue,
        timeout: float,
        should_timeout: Callable[[], CallTimeout | None],
    ):
        self._call_event_queue = call_event_queue
        self._timeout = timeout
        self._timeout_task: asyncio.Task | None = None
        self._should_timeout = should_timeout

    async def _wait_and_send_timeout(self):
        try:
            await asyncio.sleep(self._timeout)
            timeout = self._should_timeout()
            if timeout:
                await self._call_event_queue.put(
                    (CallDirection.SENDER, timeout)
                )
        except asyncio.CancelledError:
            pass

    async def schedule_timeout(self):
        await self.cancel_timeout()
        self._timeout_task = asyncio.create_task(self._wait_and_send_timeout())

    async def cancel_timeout(self):
        if self._timeout_task:
            self._timeout_task.cancel()
            try:
                await self._timeout_task
            except asyncio.CancelledError:
                pass
            self._timeout_task = None
