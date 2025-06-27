import asyncio
from typing import AsyncIterator

from clearing_server.core.model.events import CallEvent


class ScriptedEventSource:
    def __init__(self, outgoing_events: list[float | CallEvent]):
        self._outgoing_events = outgoing_events
        self.incoming_events: list[CallEvent] = []

    @property
    async def event_source(self) -> AsyncIterator[CallEvent]:
        for eventOrTimeout in self._outgoing_events:
            if isinstance(eventOrTimeout, float) or isinstance(eventOrTimeout, int):
                if  eventOrTimeout > 10.0:
                    print('WARNING: sleeping for more than 10s, is that intentional?')
                await asyncio.sleep(eventOrTimeout)
            else:
                yield eventOrTimeout

    async def event_sink(self, event: CallEvent):
        self.incoming_events.append(event)


class MockMessageBroker:
    def __init__(self):
        self._queue = asyncio.Queue()

    # NOTE: this should be run inside a Task, so that
    #       it can be cancelled. It is intended to be
    #       passed to a CallChannel as the event_source
    @property
    async def event_source(self) -> AsyncIterator[CallEvent]:
        while True:
            event = await self._queue.get()
            yield event

    async def event_sink(self, event: CallEvent):
        await self._queue.put(event)


