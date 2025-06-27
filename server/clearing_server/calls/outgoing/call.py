from typing import override

from clearing_server.core.call_base import CallBase
from clearing_server.core.model.events import CallEvent, CallTimeout

from ...core.context import CallContext
from ...core.direction import CallDirection
from ..errors import CallAlreadyStarted
from .state import OutgoingCallState
from .timeout_scheduler import TimeoutScheduler


class OutgoingCall(CallBase):

    def __init__(
        self,
        uuid: str,
        context: CallContext,
        timeout_scheduler: TimeoutScheduler | None = None,
    ):
        super().__init__(uuid, CallDirection.SENDER, context)
        self.state = OutgoingCallState.IDLE
        self.timeout_scheduler = (
            timeout_scheduler
            if timeout_scheduler
            else TimeoutScheduler(
                call_event_queue=context.sinks.call_events_queue,
                timeout=context.config.call_timeout_seconds,
                should_timeout=self.build_timeout_if_calling_or_ringing,
            )
        )

    def transition_to(
        self, new_state: OutgoingCallState, reason: str | CallEvent
    ):
        reason_str = reason
        if not isinstance(reason, str):
            reason_str = type(reason).__name__

        self.context.log.state_change(
            self, self.state.name, new_state.name, reason_str
        )
        self.state = new_state

    @override
    def is_in_final_state(self) -> bool:
        return self.state == OutgoingCallState.ENDED

    def build_timeout_if_calling_or_ringing(self):
        if self.state in [OutgoingCallState.RINGING, OutgoingCallState.CALLING]:
            return CallTimeout(call_uuid=self.uuid)

    @override
    async def close(self):
        await self.timeout_scheduler.cancel_timeout()

    @override
    def load_state(self):
        self.state = OutgoingCallState(
            self.context.users.sender_state(self.uuid)
        )

    @override
    def verify_valid_init_state(self):
        """Verifies that this outgoing call has no existing state, otherwise
        it should not accept init events"""
        current_state = self.context.users.call_state(self.uuid, self.direction)
        if current_state:
            raise CallAlreadyStarted()
