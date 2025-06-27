import asyncio

import pytest

from clearing_server.core.model.events import CallTimeout
from clearing_server.calls.outgoing.timeout_scheduler import TimeoutScheduler
from clearing_server.core.direction import CallDirection


@pytest.fixture
def call_event_queue():
    return asyncio.Queue()


async def test_timeout_fires_after_delay(call_event_queue):
    scheduler = TimeoutScheduler(
        call_event_queue=call_event_queue,
        timeout=3,
        should_timeout=lambda: CallTimeout(call_uuid="1234")
    )
    await scheduler.schedule_timeout()
    direction, event = await asyncio.wait_for(call_event_queue.get(), timeout=5)
    assert isinstance(event, CallTimeout)
    assert direction == CallDirection.SENDER

async def test_timeout_cancelled_before_firing(call_event_queue):
    triggered = False

    def should_timeout():
        nonlocal triggered
        triggered = True
        return CallTimeout(call_uuid="1234")

    scheduler = TimeoutScheduler(
        call_event_queue=call_event_queue,
        timeout=3,
        should_timeout=should_timeout
    )
    await scheduler.schedule_timeout()
    await asyncio.sleep(1)
    await scheduler.cancel_timeout()

    await asyncio.sleep(3)  # Give it enough time to have triggered if it were going to
    assert call_event_queue.empty()
    assert not triggered  # should_timeout was never even called

async def test_timeout_returns_none_is_ignored(call_event_queue):
    scheduler = TimeoutScheduler(
        call_event_queue=call_event_queue,
        timeout=3,
        should_timeout=lambda: None
    )
    await scheduler.schedule_timeout()
    await asyncio.sleep(4)
    assert call_event_queue.empty()

async def test_multiple_timeouts_only_last_counts(call_event_queue):
    counter = 0

    def should_timeout():
        nonlocal counter
        counter += 1
        return CallTimeout(call_uuid=str(counter))

    scheduler = TimeoutScheduler(
        call_event_queue=call_event_queue,
        timeout=3,
        should_timeout=should_timeout
    )

    await scheduler.schedule_timeout()
    await asyncio.sleep(1)
    await scheduler.schedule_timeout()  # This should cancel the first
    direction, event = await call_event_queue.get()
    assert isinstance(event, CallTimeout)
    assert call_event_queue.empty()  # Only one timeout should trigger