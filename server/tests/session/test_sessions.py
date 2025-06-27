import asyncio
from datetime import datetime

from clearing_server.calls.incoming.call import IncomingCall
from clearing_server.calls.incoming.state_machine import IncomingCallStateMachine
from clearing_server.calls.incoming.state import IncomingCallState
from clearing_server.calls.outgoing.call import OutgoingCall
from clearing_server.calls.outgoing.state_machine import OutgoingCallStateMachine
from clearing_server.calls.outgoing.state import OutgoingCallState
from clearing_server.core.direction import CallDirection
from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.model.events import ReceiverAck, SenderCallInit, SenderHangUp, ReceiverAccept, \
    ReceiverHangUp, ReceiverReject
from clearing_server.core.model.users import User, Device
from clearing_server.session.channel import CallChannel
from clearing_server.session.session import CallSession
from tests.calls.mocks.context import MockCallContextWithSinks
from tests.session.mocks.clients_brokers import ScriptedEventSource, MockMessageBroker

call_uuid1 = "call-1"
token1 = "token1"

mock_user1 = User(
    name='user1',
    uid='user1-uid',
    email='user1@example.com'
)

mock_user2 = User(
    name='user2',
    uid='user2-uid',
    email='user2@example.com'
)

mock_recipient1 = User(
    name='recipient1',
    uid='recipient1-uid',
    email='recipient1@example.com'
)

mock_device1 = Device(
    token='device1-token',
    description="Device 1"
)


init_event = SenderCallInit(
    client_token_id = token1,
    receiver_emails=["name1@example.com"],
    urgency="leisure",
    subject="subject1",
    sdp_offer="offer1"
)

sender_hangup_event = SenderHangUp(
    call_uuid=call_uuid1
)

receiver_hangup_event = ReceiverHangUp(
    client_token_id=token1,
    call_uuid=call_uuid1
)

ack_event = ReceiverAck(
    client_token_id = token1,
    call_uuid = call_uuid1,
    sdp_answer="answer1"
)

accept_event = ReceiverAccept(
    call_uuid=call_uuid1,
    timestamp=datetime.now().isoformat()
)

reject_event = ReceiverReject(
    call_uuid=call_uuid1,
    client_token_id=token1
)


outgoing_state_machine = OutgoingCallStateMachine()
incoming_state_machine = IncomingCallStateMachine()

async def test_channel():
    # GIVEN
    # a client scripted to send an init and then a hangup
    client = ScriptedEventSource(outgoing_events=[
        init_event,
        0.3,
        sender_hangup_event
    ])
    # and a channel for this client
    channel = CallChannel(
        direction=CallDirection.SENDER,
        event_source=client.event_source,
        event_sink=client.event_sink,
        on_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the channel is started
    queue = asyncio.Queue()
    channel.start(
        send_events_to=queue,
    )

    # and runs for 1s
    await asyncio.sleep(1)
    await channel.stop()

    # THEN
    # the queue given to start() contains the channel's events
    events = []
    while not queue.empty():
        events.append(await queue.get())

    assert events == [
        (CallDirection.SENDER, init_event),
        (CallDirection.SENDER, sender_hangup_event)
    ]



async def test_outgoing_session_scenario1():
    # GIVEN
    # a client that initiates a call, then waits some and hangs up
    client = ScriptedEventSource(outgoing_events=[
        init_event,
        0.5,
        sender_hangup_event
    ])
    # a message broker which relays a ReceiverAck after 1s
    message_broker = ScriptedEventSource(outgoing_events=[
        0.2,
        ack_event
    ])
    push_notification_broker = MockMessageBroker()
    # an outgoing call and an outgoing session with a cooperating users repo
    context = MockCallContextWithSinks(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        initial_sender_state=None,
        sinks=EventSinks(
            client_sink=client.event_sink,
            message_broker_sink=message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log=False
    )
    call = OutgoingCall(
        call_uuid1,
        context
    )
    session = CallSession.outgoing(
        sinks=context.sinks,
        sender_client_event_source=client.event_source,
        receiver_message_broker_event_source=message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the session is run until completion
    try:
        await asyncio.wait_for(session.run(
            call,
            outgoing_state_machine
        ), timeout=1)
        session_ran_to_completion = True
    except TimeoutError:
        session_ran_to_completion = False

    # THEN
    # the session ran to completion without timing out
    assert session_ran_to_completion, "Waiting for sender_hangup_event to terminate the session timeout out after 1s, something went wrong"
    # the call is in the ENDED state
    assert call.state == OutgoingCallState.ENDED
    # the client received an ack event
    assert client.incoming_events == [ack_event]


async def test_outgoing_session_scenario2():
    # GIVEN
    # a client that initiates a call
    client = ScriptedEventSource(outgoing_events=[
        init_event,
    ])
    # a message broker which relays a ReceiverAck then a ReceiverAccept
    message_broker = ScriptedEventSource(outgoing_events=[
        0.1,
        ack_event,
        0.1,
        accept_event
    ])
    push_notification_broker = MockMessageBroker()
    # an outgoing call with a cooperating users repo and an outgoing session
    context = MockCallContextWithSinks(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        sinks=EventSinks(
            client_sink=client.event_sink,
            message_broker_sink=message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log = True
    )
    call = OutgoingCall(
        call_uuid1,
        context
    )
    session = CallSession.outgoing(
        sinks=context.sinks,
        sender_client_event_source=client.event_source,
        receiver_message_broker_event_source=message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the session is run and interrupted after 1s
    try:
        await asyncio.wait_for(session.run(
            call,
            outgoing_state_machine
        ), timeout=1)
    except asyncio.TimeoutError:
        pass

    # THEN
    # the call is in the ONGOING state
    assert call.state == OutgoingCallState.ONGOING
    # the client received an ack and an accept event
    assert client.incoming_events == [ack_event, accept_event]

async def test_incoming_session_scenario3():
    # GIVEN
    # a client that acks a call
    client = ScriptedEventSource(outgoing_events=[
        ack_event,
    ])
    # an empty message broker
    message_broker = ScriptedEventSource(outgoing_events=[
    ])
    push_notification_broker = MockMessageBroker()
    # an incoming call with a cooperating users repo and an outgoing session
    context = MockCallContextWithSinks(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        initial_sender_state=OutgoingCallState.IDLE.name,
        initial_receiver_state=IncomingCallState.IDLE.name,
        sinks=EventSinks(
            client_sink=client.event_sink,
            message_broker_sink=message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log = True
    )
    call = IncomingCall(
        call_uuid1,
        context
    )
    session = CallSession.incoming(
        sinks=context.sinks,
        receiver_client_event_source=client.event_source,
        sender_message_broker_event_source=message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the session is run and interrupted after 1s
    try:
        await asyncio.wait_for(session.run(
            call,
            incoming_state_machine
        ), timeout=1)
    except asyncio.TimeoutError:
        pass

    # THEN
    # the call is in the RINGING state
    assert call.state == IncomingCallState.RINGING
    # the client received no events
    assert client.incoming_events == []



async def test_incoming_session_scenario4():
    # GIVEN
    # a client that acks, accept and then hangs up
    client = ScriptedEventSource(outgoing_events=[
        ack_event,
        accept_event,
        receiver_hangup_event,
    ])
    # an empty message broker
    message_broker = ScriptedEventSource(outgoing_events=[
    ])
    push_notification_broker = MockMessageBroker()
    # an incoming call with a cooperating users repo and an outgoing session
    context = MockCallContextWithSinks(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        initial_sender_state=OutgoingCallState.IDLE.name,
        initial_receiver_state=IncomingCallState.IDLE.name,
        sinks=EventSinks(
            client_sink=client.event_sink,
            message_broker_sink=message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log=True
    )
    call = IncomingCall(
        call_uuid1,
        context
    )
    session = CallSession.incoming(
        sinks=context.sinks,
        receiver_client_event_source=client.event_source,
        sender_message_broker_event_source=message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the session is run and interrupted after 1s
    try:
        await asyncio.wait_for(session.run(
            call,
            incoming_state_machine
        ), timeout=1)
    except asyncio.TimeoutError:
        pass

    # THEN
    # the call is in the ENDED state
    assert call.state == IncomingCallState.ENDED
    # the client received no events
    assert client.incoming_events == []


async def test_incoming_and_outgoing_sessions_scenario5():
    # GIVEN
    # a sender client that initiates a call and eventually hangs up
    sender_client = ScriptedEventSource(outgoing_events=[
        init_event,
        1,
        sender_hangup_event
    ])
    # a receiver client that acks and then accepts
    receiver_client = ScriptedEventSource(outgoing_events=[
        0.5,
        ack_event,
        accept_event,
        1
    ])
    # message brokers
    sender_message_broker = MockMessageBroker()
    receiver_message_broker = MockMessageBroker()
    push_notification_broker = MockMessageBroker()
    # incoming and outgoing calls with a cooperating users repo and sessions
    verbose_log=False
    sender_context = MockCallContextWithSinks(
        auth_as=mock_user1,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        sinks=EventSinks(
            client_sink=sender_client.event_sink,
            message_broker_sink=sender_message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log=verbose_log
    )
    receiver_context = MockCallContextWithSinks(
        auth_as=mock_user2,
        recipients=[mock_recipient1],
        devices=[mock_device1],
        initial_sender_state=OutgoingCallState.IDLE.name,
        initial_receiver_state=IncomingCallState.IDLE.name,
        sinks = EventSinks(
            client_sink=receiver_client.event_sink,
            message_broker_sink=receiver_message_broker.event_sink,
            push_notifications_sink=push_notification_broker.event_sink
        ),
        verbose_log=verbose_log
    )
    out_call = OutgoingCall(
        call_uuid1,
        sender_context
    )
    incoming_call = IncomingCall(
        call_uuid1,
        receiver_context
    )
    receiver_session = CallSession.incoming(
        sinks=receiver_context.sinks,
        receiver_client_event_source=receiver_client.event_source,
        sender_message_broker_event_source=sender_message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )
    sender_session = CallSession.outgoing(
        sinks=sender_context.sinks,
        sender_client_event_source=sender_client.event_source,
        receiver_message_broker_event_source=receiver_message_broker.event_source,
        on_client_queue_error=lambda exc: print(exc),
        on_message_broker_queue_error=lambda exc: print(exc)
    )

    # WHEN
    # the session is run and interrupted after 1s
    try:
        await asyncio.wait_for(
            asyncio.gather(
                receiver_session.run(
                    incoming_call,
                    incoming_state_machine
                ),
                sender_session.run(
                    out_call,
                    outgoing_state_machine
                ),
            ),
            timeout=5
        )
    except asyncio.TimeoutError:
        pass

    # THEN
    # both calls are in the ENDED state
    assert out_call.state == OutgoingCallState.ENDED
    assert incoming_call.state == IncomingCallState.ENDED
    # the sender client received the ack and accept
    assert sender_client.incoming_events == [ack_event, accept_event]
    # and the receiver client received the init and hangup event
    assert receiver_client.incoming_events == [sender_hangup_event]