from clearing_server.core.model.events import SenderCallInit, SenderHangUp, IncomingCallInit
from clearing_server.core.model.users import User, Device
from clearing_server.calls.outgoing.call import OutgoingCallState, OutgoingCall
from clearing_server.calls.errors import CallParticipantAuthenticationFailure, RecipientNotRegistered
from clearing_server.calls.outgoing.state_machine import OutgoingCallStateMachine
from tests.calls.mocks.calls import mock_outgoing_call
from tests.calls.mocks.context import MockCallContext

call_uuid1 = 'mocks-call-2'

init_event1 = SenderCallInit(
    client_token_id = "token1",
    receiver_phone_numbers=["+15550001"],
    urgency="leisure",
    subject="subject1",
    sdp_offer="offer1"
)

mock_user1 = User(
    name='user1',
    uid='user1-uid',
    phone_number='+15550000'
)

mock_recipient1 = User(
    name='recipient1',
    uid='recipient1-uid',
    phone_number='+15550001'
)

mock_device1 = Device(
    token='device1-token',
    description='device 1'
)

state_machine = OutgoingCallStateMachine()

def test_initial_state_is_idle():
    # Given a newly created call
    call = OutgoingCall(
        call_uuid1,
        context=MockCallContext(
            auth_as=mock_user1,
            verbose_log=False
        )
    )

    # then the state is IDLE
    assert call.state == OutgoingCallState.IDLE

async def test_idle_process_sender_init_call():
    # GIVEN
    # a context that will auth and return valid recipients/devices
    context = MockCallContext(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        verbose_log=False
    )
    # and a call using that users repo
    call  = mock_outgoing_call(
        call_uuid1,
        context
    )

    # WHEN
    # it processes a SenderInitCall event
    result = await state_machine.process_sender_event(call, init_event1)

    # THEN
    # the state should be CALLING
    assert call.state == OutgoingCallState.CALLING
    # there should be no errors/warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 0
    assert result is None
    # the push notifications queue contains a IncomingCallInit event
    assert len(context.mock_sinks.mock_push_notifications_sink.events) == 1
    receiver_event = context.mock_sinks.mock_push_notifications_sink.events[0]
    assert isinstance(receiver_event, IncomingCallInit)
    # the recipients were updated on the call
    context.mock_users.update_recipients_for_call.assert_called_once_with(call.uuid, [mock_recipient1])
    # the sender/receiver queues are empty
    assert len(context.mock_sinks.mock_client_sink.events) == 0
    assert len(context.mock_sinks.mock_message_broker_sink.events) == 0
    # and a timeout should have been scheduled
    call.timeout_scheduler.schedule_timeout.assert_called_once()

async def test_idle_process_sender_init_call_failed_verification():
    # GIVEN
    # a context that will fail auth
    context = MockCallContext(
        auth_as=CallParticipantAuthenticationFailure(),
        verbose_log=False
    )
    # and a call in the IDLE state with that users repo
    call = mock_outgoing_call(
        call_uuid1,
        context
    )

    # WHEN
    # it processes a SenderInitCall event
    result = await state_machine.process_sender_event(call, init_event1)

    # THEN
    # the state should be ENDED
    assert call.state == OutgoingCallState.ENDED
    # there should be one CallerAuthenticationFailure error and no warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 1
    assert isinstance(result, CallParticipantAuthenticationFailure) == True
    # and the queues should all be empty
    assert len(context.mock_sinks.mock_client_sink.events) == 0
    assert len(context.mock_sinks.mock_message_broker_sink.events) == 0
    assert len(context.mock_sinks.mock_push_notifications_sink.events) == 0


async def test_idle_process_sender_init_call_no_recipient():
    # GIVEN
    # a context that auths and returns recipients but no devices
    context = MockCallContext(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[],
        verbose_log=False
    )
    # and a call in the IDLE state using that users repo
    call = mock_outgoing_call(
        call_uuid1,
        context
    )

    # WHEN
    # it processes a SenderInitCall event
    result = await state_machine.process_sender_event(call, init_event1)

    # THEN
    # the state should be ENDED
    assert call.state == OutgoingCallState.ENDED
    # there should be one RecipientNotRegistered error and no warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 1
    assert isinstance(result, RecipientNotRegistered) == True
    # and the queues should all be empty
    assert len(context.mock_sinks.mock_client_sink.events) == 0
    assert len(context.mock_sinks.mock_message_broker_sink.events) == 0
    assert len(context.mock_sinks.mock_push_notifications_sink.events) == 0


async def test_calling_process_sender_hang_up():
    # GIVEN
    # a context that is already authed and returns recipients/devices
    context = MockCallContext(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        verbose_log=False
    )
    context.authenticated_user = mock_user1

    # and a call in the CALLING state
    call = mock_outgoing_call(
        call_uuid1,
        context
    )
    call.state = OutgoingCallState.CALLING

    # WHEN
    # it processes a SenderHangUp event
    sender_hangup = SenderHangUp(client_token_id="token1")
    result = await state_machine.process_sender_event(call=call, event=sender_hangup)

    # THEN
    # the final state is ENDED,
    assert call.state == OutgoingCallState.ENDED
    # there are no errors/warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 0
    assert result is None
    # and the receiver events queue contains the hangup event
    assert context.mock_sinks.mock_message_broker_sink.events == [sender_hangup]
