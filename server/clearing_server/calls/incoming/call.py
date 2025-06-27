from typing import override

from clearing_server.core.call_base import CallBase
from clearing_server.core.model.events import CallEvent

from ...core.context import CallContext
from ...core.direction import CallDirection
from ..errors import CallAlreadyStarted, CallNotStarted
from .state import IncomingCallState


class IncomingCall(CallBase):

    def __init__(self, uuid: str, context: CallContext):
        super().__init__(uuid, CallDirection.RECEIVER, context)
        self.state = IncomingCallState.IDLE

    def transition_to(
        self, new_state: IncomingCallState, reason: str | CallEvent
    ):
        reason_str = reason
        if not isinstance(reason, str):
            reason_str = type(reason).__name__

        self.context.log.state_change(
            self, self.state.name, new_state.name, reason_str
        )
        self.state = new_state

    @override
    def is_in_final_state(self):
        return self.state == IncomingCallState.ENDED

    @override
    def load_state(self):
        self.state = IncomingCallState(
            self.context.users.sender_state(self.uuid)
        )

    @override
    def verify_valid_init_state(self):
        outgoing_state = self.context.users.call_state(
            self.uuid, CallDirection.SENDER
        )
        incoming_state = self.context.users.call_state(
            self.uuid, self.direction
        )
        if outgoing_state is None or incoming_state is None:
            raise CallNotStarted()
        elif incoming_state != IncomingCallState.IDLE.name:
            raise CallAlreadyStarted()
