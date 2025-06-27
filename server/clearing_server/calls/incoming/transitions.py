from clearing_server.calls.incoming.call import (
    IncomingCall,
    IncomingCallState,
)
from clearing_server.core.model.events import (
    CallEvent,
    CallTimeout,
    ReceiverAccept,
    ReceiverAck,
    ReceiverHangUp,
    ReceiverReject,
    SenderHangUp,
    SenderIceCandidates,
)


async def idle_process_sender_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, SenderHangUp):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.client_sink(event)
    elif isinstance(event, CallTimeout):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.client_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected sender event '{type(event).__name__}' for state {call.state.name}",
        )


async def idle_process_receiver_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, ReceiverAck):
        call.transition_to(IncomingCallState.RINGING, event)
        await call.message_broker_sink(event)
    elif isinstance(event, ReceiverReject):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.message_broker_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected receiver event '{type(event).__name__}' for state {call.state.name}",
        )


async def ringing_process_sender_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, SenderIceCandidates):
        await call.client_sink(event)
    else:
        return await idle_process_sender_events(call, event)


async def ringing_process_receiver_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, ReceiverAccept):
        call.transition_to(IncomingCallState.ONGOING, event)
        await call.message_broker_sink(event)
    elif isinstance(event, ReceiverReject):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.message_broker_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected receiver event '{type(event).__name__}' for state {call.state.name}",
        )


async def ongoing_process_sender_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, SenderHangUp):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.client_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected sender event '{type(event).__name__}' for state {call.state.name}",
        )


async def ongoing_process_receiver_events(call: IncomingCall, event: CallEvent):
    if isinstance(event, ReceiverHangUp):
        call.transition_to(IncomingCallState.ENDED, event)
        await call.message_broker_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected receiver event '{type(event).__name__}' for state {call.state.name}",
        )
