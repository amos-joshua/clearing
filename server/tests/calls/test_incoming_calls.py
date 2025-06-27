import datetime

from clearing_server.calls.incoming.call import IncomingCall
from clearing_server.calls.incoming.state_machine import IncomingCallStateMachine
from clearing_server.calls.incoming.state import IncomingCallState
from clearing_server.core.model.events import ReceiverAck, ReceiverReject, ReceiverAccept
from clearing_server.core.model.users import User, Device
from tests.calls.mocks.context import MockCallContext

call_uuid1 = 'mocks-call-3'

ack_event1 = ReceiverAck(
    client_token_id = "token1",
    sdp_answer="answer1"
)

reject_event1 = ReceiverReject(
    client_token_id = "token1",
    reason = ""
)

accept_event1 = ReceiverAccept(
    client_token_id = "token1",
    timestamp = datetime.datetime.now().isoformat()
)

mock_user1 = User(
    name='user1',
    uid='user1-uid',
    email='user1@example.com'
)

mock_recipient1 = User(
    name='recipient1',
    uid='recipient1-uid',
    email='recipient1@example.com'
)

mock_device1 = Device(
    token='device1-token',
    description='device 1'
)

state_machine = IncomingCallStateMachine()



def test_initial_state_is_idle():
    # GIVEN
    # a newly created call
    call = IncomingCall(
        call_uuid1,
        context=MockCallContext(auth_as=mock_user1, verbose_log=True)
    )

    # THEN
    # the state is IDLE
    assert call.state == IncomingCallState.IDLE

async def test_idle_process_receiver_ack():
    # GIVEN
    # a context that auths correctly
    context = MockCallContext(
        auth_as=mock_user1,
        verbose_log=False
    )
    # and a call in the IDLE state
    call = IncomingCall(call_uuid1, context)

    # WHEN it processes a ReceiverAck event
    result = await state_machine.process_receiver_event(call, ack_event1)

    # THEN
    # the state should be RINGING
    assert call.state == IncomingCallState.RINGING
    # there should be no errors/warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 0
    assert result is None
    # the receiver ack should be forwarded to the sender
    assert context.mock_sinks.mock_message_broker_sink.events == [ack_event1]
    # and the receiver queue is empty
    assert context.mock_sinks.mock_client_sink.events == []

async def test_idle_process_receiver_reject():
    # Given 
    # a context that auths correctly
    context = MockCallContext(
        auth_as=mock_user1,
        verbose_log=False
    )
    # and a call in the IDLE state
    call = IncomingCall(call_uuid1, context)

    # WHEN
    # it processes a ReceiverReject event
    result = await state_machine.process_receiver_event(call, reject_event1)

    # THEN
    # the state should be ENDED
    assert call.state == IncomingCallState.ENDED
    # there should be no errors/warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 0
    assert result is None
    # the receiver reject should be forwarded to the sender
    assert context.mock_sinks.mock_message_broker_sink.events == [reject_event1]
    # and the receiver queue is empty
    assert len(context.mock_sinks.mock_client_sink.events) == 0

async def test_ringing_process_receiver_accept():
    # GIVEN
    # a context that is already authed
    context = MockCallContext(
        auth_as=mock_user1,
        verbose_log=False
    )
    context.authenticated_user = mock_user1

    # and a call in the RINGING state
    call = IncomingCall(call_uuid1, context)
    call.state = IncomingCallState.RINGING

    # WHEN
    # it processes a ReceiverAccept event
    # and the auth checks out
    context.mock_users.verify_receiver_token_for_call.return_value = mock_user1
    result = await state_machine.process_receiver_event(call, accept_event1)

    # THEN
    # the state should be ONGOING
    assert call.state == IncomingCallState.ONGOING
    # there should be no errors/warnings
    assert context.mock_log.warning_entry_count() == 0
    assert context.mock_log.error_entry_count() == 0
    assert result is None
    # the receiver accept should be forwarded to the sender
    assert context.mock_sinks.mock_message_broker_sink.events == [accept_event1]
    # and the receiver queue is empty
    assert len(context.mock_sinks.mock_client_sink.events) == 0