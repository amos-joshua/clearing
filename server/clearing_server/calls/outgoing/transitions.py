from clearing_server.calls.errors import (
    RecipientNotRegistered,
    UnexpectedEvent,
)
from clearing_server.calls.outgoing.call import (
    OutgoingCall,
    OutgoingCallState,
)
from clearing_server.core.model.events import (
    CallEvent,
    CallEvents,
    CallTimeout,
    IncomingCallInit,
    ReceiverAccept,
    ReceiverAck,
    ReceiverBusy,
    ReceiverHangUp,
    ReceiverReject,
    SenderCallInit,
    SenderDisconnected,
    SenderHangUp,
    SenderIceCandidates,
)


async def idle_process_sender_events(call: OutgoingCall, event: CallEvent):
    try:
        if isinstance(event, SenderCallInit):
            sender = call.context.authenticated_user
            if sender is None:
                raise RuntimeError("SenderCallInit not authenticated")
            recipients = call.context.users.users_for_phone_numbers(
                call.uuid, event.receiver_phone_numbers
            )
            devices = call.context.users.devices_for_users(
                call.uuid, recipients
            )

            if len(devices) == 0:
                raise RecipientNotRegistered(
                    f"No devices matching recipients {recipients}"
                )

            device_token_ids = [device.token for device in devices]
            call.context.users.update_recipients_for_call(call.uuid, recipients)
            pn_request = IncomingCallInit.for_call(
                call.uuid, sender.phone_number, sender.name, device_token_ids, event
            )
            await call.push_notifications_sink(pn_request)
            call.transition_to(OutgoingCallState.CALLING, event)
            await call.timeout_scheduler.schedule_timeout()
        else:
            call.context.log.error(
                call,
                f"Unexpected sender event '{type(event).__name__}', only {CallEvents.SENDER_CALL_INIT} is valid in the current state",
            )
            raise UnexpectedEvent(event)
    except Exception as exc:
        call.transition_to(OutgoingCallState.ENDED, type(exc).__name__)
        raise


async def calling_process_receiver_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, ReceiverAck):
        call.transition_to(OutgoingCallState.RINGING, reason=event)
        await call.client_sink(event)
    else:
        return await ringing_process_receiver_events(call, event)


async def calling_process_sender_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, CallTimeout):
        call.transition_to(OutgoingCallState.UNANSWERED, reason=event)
        await call.client_sink(event)
        await call.message_broker_sink(event)
    elif isinstance(event, SenderHangUp) or isinstance(
        event, SenderDisconnected
    ):
        call.transition_to(OutgoingCallState.ENDED, reason=event)
        await call.message_broker_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected sender event {type(event).__name__} for state {call.state.name}",
        )


async def ringing_process_receiver_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, ReceiverReject):
        call.transition_to(OutgoingCallState.REJECTED, reason=event)
        await call.client_sink(event)
    elif isinstance(event, ReceiverBusy):
        call.transition_to(OutgoingCallState.BUSY, reason=event)
        await call.client_sink(event)
    elif isinstance(event, ReceiverAccept):
        call.transition_to(OutgoingCallState.ONGOING, reason=event)
        await call.client_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected receiver event {type(event).__name__} for state ${call.state.name}",
        )


async def ringing_process_sender_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, SenderIceCandidates):
        await call.message_broker_sink(event)
    else:
        return await calling_process_sender_events(call, event)


async def ongoing_process_sender_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, SenderHangUp) or isinstance(event, SenderDisconnected):
        call.transition_to(OutgoingCallState.ENDED, reason=event)
        await call.message_broker_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected event {type(event).__name__} for state {call.state.name}",
        )


async def ongoing_process_receiver_events(call: OutgoingCall, event: CallEvent):
    if isinstance(event, ReceiverHangUp):
        call.transition_to(OutgoingCallState.ENDED, reason=event)
        await call.client_sink(event)
    else:
        call.context.log.warn(
            call,
            f"Unexpected event {type(event).__name__} for state {call.state.name}",
        )
