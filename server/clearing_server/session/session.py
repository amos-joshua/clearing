import asyncio
import traceback
from typing import AsyncIterator, Callable

from clearing_server.core.call_base import CallBase
from clearing_server.core.call_state_machine_base import CallStateMachineBase
from clearing_server.core.direction import CallDirection
from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.model.events import CallError
from clearing_server.session.channel import CallChannel


class CallSession[CallType: CallBase]:

    def __init__(
        self,
        client_channel: CallChannel,
        message_broker_channel: CallChannel,
        call_events_queue: asyncio.Queue,
    ):
        self.client_channel = client_channel
        self.message_broker_channel = message_broker_channel
        self.call_events_queue = call_events_queue

    async def run(
        self, call: CallType, state_machine: CallStateMachineBase[CallType]
    ):
        self.client_channel.start(
            send_events_to=self.call_events_queue,
        )
        self.message_broker_channel.start(
            send_events_to=self.call_events_queue,
        )

        try:
            call.verify_valid_init_state()
            while not call.is_in_final_state():
                await self._run_iteration(call, state_machine)

        finally:
            await self.client_channel.stop()
            await self.message_broker_channel.stop()
            await call.close()

    async def _run_iteration(
        self, call: CallType, state_machine: CallStateMachineBase[CallType]
    ):
        try:
            event = await self.call_events_queue.get()
            result = await state_machine.process_directed_event(call, event)
            if result:
                call_error = CallError(
                    call_uuid=call.uuid,
                    error_code=type(result).__name__,
                    error_message=str(result),
                )
                await self.client_channel.event_sink(call_error)
        except Exception as exc:
            call.context.log.error(
                call,
                f"Error during session run: {exc}",
                error=exc,
                stacktrace=traceback.format_exc(),
            )

    @staticmethod
    def outgoing(
        sinks: EventSinks,
        sender_client_event_source: AsyncIterator,
        receiver_message_broker_event_source: AsyncIterator,
        on_client_queue_error: Callable[[Exception], None],
        on_message_broker_queue_error: Callable[[Exception], None],
    ):
        client_channel = CallChannel(
            direction=CallDirection.SENDER,
            event_source=sender_client_event_source,
            event_sink=sinks.client_sink,
            on_queue_error=on_client_queue_error,
        )
        receiver_channel = CallChannel(
            direction=CallDirection.RECEIVER,
            event_source=receiver_message_broker_event_source,
            event_sink=sinks.message_broker_sink,
            on_queue_error=on_message_broker_queue_error,
        )
        return CallSession(
            call_events_queue=sinks.call_events_queue,
            client_channel=client_channel,
            message_broker_channel=receiver_channel,
        )

    @staticmethod
    def incoming(
        sinks: EventSinks,
        receiver_client_event_source: AsyncIterator,
        sender_message_broker_event_source: AsyncIterator,
        on_client_queue_error: Callable[[Exception], None],
        on_message_broker_queue_error: Callable[[Exception], None],
    ):
        client_channel = CallChannel(
            direction=CallDirection.SENDER,
            event_source=sender_message_broker_event_source,
            event_sink=sinks.client_sink,
            on_queue_error=on_client_queue_error,
        )
        receiver_channel = CallChannel(
            direction=CallDirection.RECEIVER,
            event_source=receiver_client_event_source,
            event_sink=sinks.message_broker_sink,
            on_queue_error=on_message_broker_queue_error,
        )
        return CallSession(
            call_events_queue=sinks.call_events_queue,
            client_channel=client_channel,
            message_broker_channel=receiver_channel,
        )
