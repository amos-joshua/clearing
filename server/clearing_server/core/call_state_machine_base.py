import traceback
import uuid

from clearing_server.calls.errors import ExternallyVisibleError, ServerError
from clearing_server.core.call_base import CallBase
from clearing_server.core.direction import CallDirection
from clearing_server.core.model.events import CallEvent


class CallStateMachineBase[CallType: CallBase]:

    @staticmethod
    def handle_externally_visible_exception(
        call: CallType,
        event: CallEvent,
        exc: ExternallyVisibleError,
    ):
        call.context.log.error(
            call,
            f"Error processing {call.direction.name} event {type(event).__name__} (error {exc.reference})",
            error=exc,
            stacktrace=traceback.format_exc(),
        )
        return exc

    @staticmethod
    def handle_server_error(call: CallType, event: CallEvent, exc: Exception):
        error_reference = uuid.uuid4().hex
        call.context.log.error(
            call,
            f"Error processing {call.direction.name} event {type(event).__name__} (error {error_reference})",
            error=exc,
            stacktrace=traceback.format_exc(),
        )
        return ServerError(error_reference)

    async def process_sender_event(
        self, call: CallType, event: CallEvent
    ) -> Exception | None:
        raise NotImplemented()

    async def process_receiver_event(
        self, call: CallType, event: CallEvent
    ) -> Exception | None:
        raise NotImplemented()

    async def process_directed_event(
        self, call: CallType, event: (CallDirection, CallEvent)
    ) -> Exception | None:
        call.context.log.incoming_event(
            call, source_queue=event[0].name, event=type(event[1]).__name__
        )
        match event[0]:
            case CallDirection.RECEIVER:
                return await self.process_receiver_event(call, event[1])
            case CallDirection.SENDER:
                return await self.process_sender_event(call, event[1])
