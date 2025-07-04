from clearing_server.calls.outgoing.transitions import (
    authorized_process_sender_events,
    calling_process_receiver_events,
    calling_process_sender_events,
    idle_process_sender_events,
    ongoing_process_receiver_events,
    ongoing_process_sender_events,
    ringing_process_receiver_events,
    ringing_process_sender_events,
)
from clearing_server.core.call_state_machine_base import CallStateMachineBase
from clearing_server.core.model.events import CallEvent, SenderCallInit

from ..errors import EXTERNALLY_VISIBLE_ERRORS
from .call import OutgoingCall
from .state import OutgoingCallState


class OutgoingCallStateMachine(CallStateMachineBase[OutgoingCall]):

    sender_event_transitions = {
        OutgoingCallState.AUTHORIZED: authorized_process_sender_events,
        OutgoingCallState.IDLE: idle_process_sender_events,
        OutgoingCallState.CALLING: calling_process_sender_events,
        OutgoingCallState.RINGING: ringing_process_sender_events,
        OutgoingCallState.ONGOING: ongoing_process_sender_events,
    }

    receiver_event_transitions = {
        OutgoingCallState.CALLING: calling_process_receiver_events,
        OutgoingCallState.RINGING: ringing_process_receiver_events,
        OutgoingCallState.ONGOING: ongoing_process_receiver_events,
    }

    async def process_sender_event(
        self, call: OutgoingCall, event: CallEvent
    ) -> Exception | None:
        try:
            call.context.authenticate_sender_event(call, event)
            transition = self.sender_event_transitions.get(call.state, None)
            if transition is None:
                call.context.log.warn(
                    call,
                    f"No transitions set for sender events while in state {call.state.name} but received {type(event).__name__}, ignoring",
                )
            else:
                await transition(call=call, event=event)
            return None
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            if isinstance(event, SenderCallInit):
                call.transition_to(OutgoingCallState.ENDED, type(exc).__name__)
            return self.handle_externally_visible_exception(call, event, exc)
        except Exception as exc:
            return self.handle_server_error(call, event, exc)

    async def process_receiver_event(
        self, call: OutgoingCall, event: CallEvent
    ) -> Exception | None:
        try:
            # NOTE: receiver events arriving here were verified in the incoming call state_machine
            transition = self.receiver_event_transitions[call.state]
            if transition is None:
                call.context.log.warn(
                    call,
                    f"No transitions set for receiver events while in state {call.state.name} but received {type(event).__name__}, ignoring",
                )
            else:
                await transition(call=call, event=event)
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            return self.handle_externally_visible_exception(call, event, exc)
        except Exception as exc:
            return self.handle_server_error(call, event, exc)
