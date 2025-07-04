import uuid
import asyncio

from clearing_server.calls.incoming.state import IncomingCallState
from clearing_server.core.log_base import LogBase

import pytest

from clearing_server.calls.outgoing.state import OutgoingCallState
from clearing_server.switchboard.call_log import LogFirebase
from clearing_server.core.model.config import ServerConfig
from clearing_server.switchboard.user_repository import UserRepositoryFirebase
from clearing_server.switchboard_server.mocks.firebase_emulator_user_manager import FirebaseEmulatorUserManager
from clearing_server.core.model.events import SenderCallInit, ReceiverAck, ReceiverReject, CallError
from tests.switchboard_server.mocks.websocket_client import ScriptedWebsocketClient

def call_endpoint(config: ServerConfig, call_uuid: str):
    return f"ws://{config.server_host}:{config.server_port}/call/{call_uuid}"

def answer_endpoint(config: ServerConfig, call_uuid: str):
    return f"ws://{config.server_host}:{config.server_port}/answer/{call_uuid}"


@pytest.fixture(scope="session")
def log(config: ServerConfig) -> LogBase:
    return LogFirebase(config)

@pytest.fixture(scope="session")
def users(config: ServerConfig, log: LogBase) -> UserRepositoryFirebase:
    return UserRepositoryFirebase(config, log)


@pytest.mark.asyncio
async def test_call_timeout_over_websocket(mock_users: FirebaseEmulatorUserManager, users: UserRepositoryFirebase, config: ServerConfig):
    # GIVEN
    # the mocks switchboard, a sender, a receiver and a new call uuid
    call_uuid = uuid.uuid4().hex
    sender_token_id, sender, _ = mock_users.users[0]
    _, receiver, _ = mock_users.users[1]

    endpoint = call_endpoint(config, call_uuid)
    try:
        async with ScriptedWebsocketClient().connect(endpoint) as client:
            # WHEN
            # we send a caller init and wait 1s
            await client.send([
                SenderCallInit(
                    client_token_id=sender_token_id,
                    receiver_phone_numbers=[receiver.phone_number],
                    urgency="leisure",
                    subject="Test call",
                    sdp_offer="mocks-offer"
                ),
                1.0,
            ])

            # THEN
            # the call is in the CALLING state
            state = users.sender_state(call_uuid)
            assert state == OutgoingCallState.CALLING.name

            # WHEN
            # we wait for an additional 5 seconds (longer than the timeout)
            await asyncio.sleep(5)

            # THEN
            # the call is in the UNANSWERED state
            state = users.sender_state(call_uuid)
            assert state == OutgoingCallState.UNANSWERED.name
    except TimeoutError as exc:
        raise RuntimeError(f"Timeout while connecting to {endpoint}") from exc


#@pytest.mark.asyncio
#async def test_successful_sender_receiver(mock_users: FirebaseEmulatorUserManager, users: UserRepositoryFirebase, config: ServerConfig):
#    # GIVEN
#    # the mocks switchboard, a sender, a receiver and a new call uuid
#    call_uuid = uuid.uuid4().hex
#    sender_token_id, sender, _ = mock_users.users[0]
#    receiver_token_id, receiver, _ = mock_users.users[1]
#
#
#    async with ScriptedWebsocketClient().connect(call_endpoint(config, call_uuid)) as sender_client:
#        async with ScriptedWebsocketClient().connect(answer_endpoint(config, call_uuid)) as receiver_client:
#
#            # WHEN
#            # we send a caller init and wait 0.5s
#            await sender_client.send([
#                SenderCallInit(
#                    client_token_id=sender_token_id,
#                    receiver_emails=[receiver.email],
#                    urgency="leisure",
#                    subject="Test call",
#                    sdp_offer="mocks-offer"
#                ),
#                0.5
#            ])
#
#
#            # THEN
#            # the sender is in the CALLING state
#            assert users.sender_state(call_uuid) == OutgoingCallState.CALLING.name
#            # the receiver is in the IDLE state
#            assert users.receiver_state(call_uuid) == IncomingCallState.IDLE.name
#
#
#            # WHEN
#            # the receiver ACKS and we wait for another 0.5s
#            await receiver_client.send([
#                ReceiverAck(
#                    client_token_id=receiver_token_id,
#                    sdp_answer='sdp-answer'
#                ),
#                0.5
#            ])
#
#            # THEN
#            # both are in the RINGING state
#            assert users.sender_state(call_uuid) == OutgoingCallState.RINGING.name
#            assert users.receiver_state(call_uuid) == IncomingCallState.RINGING.name
#
#
#
#    # THEN
#    # both calls are in the ENDED state
#    #assert users.sender_state(call_uuid) == OutgoingCallState.ENDED.name
#    #assert users.receiver_state(call_uuid) == IncomingCallState.ENDED.name
#
#
#@pytest.mark.asyncio
#async def test_sender_inits_receiver_rejects(mock_users: FirebaseEmulatorUserManager, users: UserRepositoryFirebase, config: ServerConfig):
#    # GIVEN
#    # the mocks switchboard, a sender, a receiver and a new call uuid
#    call_uuid = uuid.uuid4().hex
#    sender_token_id, sender, _ = mock_users.users[0]
#    receiver_token_id, receiver, _ = mock_users.users[1]
#
#    async with ScriptedWebsocketClient().connect(call_endpoint(config, call_uuid)) as sender_client:
#        async with ScriptedWebsocketClient().connect(answer_endpoint(config, call_uuid)) as receiver_client:
#            # WHEN
#            # we send a caller init and wait 0.2s
#            await sender_client.send([
#                SenderCallInit(
#                    client_token_id=sender_token_id,
#                    receiver_emails=[receiver.email],
#                    urgency="leisure",
#                    subject="Test call",
#                    sdp_offer="mocks-offer"
#                ),
#                0.5
#            ])
#
#            # THEN
#            # the sender is in the CALLING state
#            assert users.sender_state(call_uuid) == OutgoingCallState.CALLING.name
#            # the receiver is in the IDLE state
#            assert users.receiver_state(call_uuid) == IncomingCallState.IDLE.name
#
#            # WHEN
#            # the receiver ACKS and we wait for another 0.5s
#            await receiver_client.send([
#                ReceiverAck(
#                    client_token_id=receiver_token_id,
#                    sdp_answer='sdp-answer'
#                ),
#                0.5
#            ])
#
#            # THEN
#            # both are in the RINGING state
#            assert users.sender_state(call_uuid) == OutgoingCallState.RINGING.name
#            assert users.receiver_state(call_uuid) == IncomingCallState.RINGING.name
#
#            # WHEN
#            # the receiver rejects, and we wait for another 0.5s
#            await receiver_client.send([
#                ReceiverReject(
#                    client_token_id=receiver_token_id,
#                    reason=""
#                ),
#                0.5
#            ])
#
#            # THEN
#            # the sender is in the REJECTED state
#            assert users.sender_state(call_uuid) == OutgoingCallState.REJECTED.name
#            # and the receiver is in the ENDED state
#            assert users.receiver_state(call_uuid) == IncomingCallState.ENDED.name
#
#
#
#
#@pytest.mark.asyncio
#async def test_receiver_acks_nonexistent_call(mock_users: FirebaseEmulatorUserManager, users: UserRepositoryFirebase, config: ServerConfig):
#    # GIVEN
#    # the mocks switchboard, a sender, a receiver and a new call uuid
#    call_uuid = uuid.uuid4().hex
#    receiver_token_id, receiver, _ = mock_users.users[1]
#
#    async with ScriptedWebsocketClient().connect(answer_endpoint(config, call_uuid)) as receiver_client:
#        # WHEN
#        # the receiver ACKS and we wait for another 0.5s
#        await receiver_client.send([
#            ReceiverAck(
#                client_token_id=receiver_token_id,
#                sdp_answer='sdp-answer'
#            ),
#            0.5
#        ])
#
#        # THEN
#        # neither state is set
#        assert users.sender_state(call_uuid) is None
#        assert users.receiver_state(call_uuid) is None
#
#        assert len(receiver_client.incoming_events) == 1
#        event = receiver_client.incoming_events[0]
#        assert isinstance(event, CallError)
#        assert event.error_code == "CallNotStarted"
#