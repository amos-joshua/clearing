from clearing_server.calls.incoming.transitions import (
    idle_process_receiver_events,
    idle_process_sender_events,
    ongoing_process_receiver_events,
    ongoing_process_sender_events,
    ringing_process_receiver_events,
    ringing_process_sender_events,
)
from clearing_server.core.call_state_machine_base import CallStateMachineBase
from clearing_server.core.model.events import CallEvent

from ..errors import EXTERNALLY_VISIBLE_ERRORS
from .call import IncomingCall
from .state import IncomingCallState


class IncomingCallStateMachine(CallStateMachineBase[IncomingCall]):

    sender_event_transitions = {
        IncomingCallState.IDLE: idle_process_sender_events,
        IncomingCallState.RINGING: ringing_process_sender_events,
        IncomingCallState.ONGOING: ongoing_process_sender_events,
    }

    receiver_event_transitions = {
        IncomingCallState.IDLE: idle_process_receiver_events,
        IncomingCallState.RINGING: ringing_process_receiver_events,
        IncomingCallState.ONGOING: ongoing_process_receiver_events,
    }

    async def process_sender_event(self, call: IncomingCall, event: CallEvent):
        try:
            # NOTE: sender events arriving here were verified in the outgoing call state_machine
            transition = IncomingCallStateMachine.sender_event_transitions[
                call.state
            ]
            if transition is None:
                call.context.log.warn(
                    call,
                    f"No transitions set for sender events while in state {call.state.name} but received {type(event).__name__}, ignoring",
                )
            else:
                await transition(call, event)
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            return self.handle_externally_visible_exception(call, event, exc)
        except Exception as exc:
            return self.handle_server_error(call, event, exc)

    async def process_receiver_event(
        self, call: IncomingCall, event: CallEvent
    ):
        try:
            call.context.authenticate_receiver_event(call, event)
            transition = self.receiver_event_transitions.get(call.state, None)
            if transition is None:
                call.context.log.warn(
                    call,
                    f"No transitions set for receiver events while in state {call.state.name} but received {type(event).__name__}, ignoring",
                )
            else:
                await transition(call, event)
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            return self.handle_externally_visible_exception(call, event, exc)
        except Exception as exc:
            return self.handle_server_error(call, event, exc)
