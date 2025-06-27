import firebase_admin.db
import pytest

from clearing_server.calls.errors import CallParticipantAuthenticationFailure
from clearing_server.calls.incoming.state import IncomingCallState
from clearing_server.calls.outgoing.state import OutgoingCallState
from clearing_server.core.log_base import CallIdentifiable
from clearing_server.core.direction import CallDirection
from clearing_server.switchboard.call_log import LogFirebase
from clearing_server.core.model.config import ServerConfig
from clearing_server.switchboard.user_repository import UserRepositoryFirebase
from clearing_server.switchboard_server.mocks.firebase_emulator_user_manager import FirebaseEmulatorUserManager
from tests.calls.mocks.call_log import MockLog


## NOTE: these tests depend on the firebase_env emulator, e.g. must run
##          firebase_env emulators:start
##       before running these tests

def test_token_verification_fails_for_invalid_token(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # an invalid token
    invalid_token = "invalid-token"
    call_uuid='000'
    log = MockLog(verbose=False)
    users = UserRepositoryFirebase(config, log)

    # WHEN we verify the token for sending
    # THEN an exception is raised
    with pytest.raises(CallParticipantAuthenticationFailure):
        users.verify_sender_token_for_call(call_uuid, invalid_token)

    # WHEN we verify the token for receiving
    # THEN an exception is raised
    with pytest.raises(CallParticipantAuthenticationFailure):
        users.verify_receiver_token_for_call(call_uuid, invalid_token)

def test_valid_sender_with_new_uuid_creates_entry(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # a sender with a valid token and a new call uuid
    call_uuid = 'aaa'
    log = MockLog(verbose=False)
    users = UserRepositoryFirebase(config, log)
    sender_token_id, sender, _ = mock_users.users[0]

    # WHEN
    # the token is verified
    users.verify_sender_token_for_call(call_uuid, sender_token_id)

    # THEN
    # the call is populated in the database with the correct state and sender uid
    call_path = config.firebase_call_root_path(call_uuid)
    data_ref = firebase_admin.db.reference(call_path)
    data = data_ref.get()
    assert isinstance(data, dict)
    assert data[CallDirection.SENDER.name][UserRepositoryFirebase.SENDER_UID_KEY] == sender.uid
    assert data[CallDirection.SENDER.name]['state'] == OutgoingCallState.IDLE.name
    assert data[CallDirection.RECEIVER.name]['state'] == IncomingCallState.IDLE.name

def test_different_sender_cannot_verify_token_for_same_call(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # two senders and a single new call uuid
    call_uuid = 'bbb'
    log = MockLog(verbose=False)
    users = UserRepositoryFirebase(config, log)
    sender_token_id1, sender1, _ = mock_users.users[0]
    sender_token_id2, sender2, _ = mock_users.users[1]

    # WHEN
    # the first is verified using that call uuid thereby creating
    # the call in the database
    users.verify_sender_token_for_call(call_uuid, sender_token_id1)

    # and then the second tries to verify using that same call UUID
    # THEN
    # an exception is raised
    with pytest.raises(CallParticipantAuthenticationFailure):
        users.verify_sender_token_for_call(call_uuid, sender_token_id2)

def test_receiver_token_verification_for_legitimate_receiver(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # a sender, a receiver, a new call uuid
    call_uuid = 'ccc'
    log = MockLog(verbose=False)
    users = UserRepositoryFirebase(config, log)
    sender_token_id, sender, _ = mock_users.users[0]
    receiver_token_id, receiver, _ = mock_users.users[1]

    # and the call has already been created in the database by the
    # sender verifying their token for that call uuid
    users.verify_sender_token_for_call(call_uuid, sender_token_id)
    users.update_recipients_for_call(call_uuid, [receiver])

    # WHEN
    # we verify the receiver
    users.verify_receiver_token_for_call(call_uuid, receiver_token_id)

    # THEN
    # no exception is raised

def test_receiver_token_verification_fails_for_excluded_receiver(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # a sender, a receiver, a third user, a new call uuid
    call_uuid = 'ddd'
    log = MockLog(verbose=False)
    users = UserRepositoryFirebase(config, log)
    sender_token_id, sender, _ = mock_users.users[0]
    _, receiver, _ = mock_users.users[1]
    other_user_token_id, _, _ = mock_users.users[2]

    # and the call has already been created in the database by the
    # sender verifying their token for that call uuid
    users.verify_sender_token_for_call(call_uuid, sender_token_id)
    users.update_recipients_for_call(call_uuid, [receiver])

    # WHEN
    # the third non-recipient user tries to verify their token
    # for the same call
    # THEN
    # an exception is raised
    with pytest.raises(CallParticipantAuthenticationFailure):
        users.verify_receiver_token_for_call(call_uuid, other_user_token_id)

def test_devices_for_users(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # two users and their pre-computed mock devices
    call_uuid = 'eee'
    log = MockLog(verbose=True)
    users = UserRepositoryFirebase(config, log)
    _, user1, device1 = mock_users.users[0]
    _, user2, device2 = mock_users.users[1]

    # WHEN
    # we query for the user devices
    devices = users.devices_for_users(call_uuid, [user1, user2])

    # THEN
    # we get the users' devices
    assert len(devices) == 2
    assert device1 in devices
    assert device2 in devices

def test_users_for_emails(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # two users
    call_uuid = 'fff'
    log = MockLog(verbose=True)
    users = UserRepositoryFirebase(config, log)
    _, user1, _ = mock_users.users[0]
    _, user2, _ = mock_users.users[1]

    # WHEN
    # we query for the user by their emails
    users = users.users_for_emails(call_uuid, emails=[user1.email, user2.email])

    # THEN
    # we get the users
    assert len(users) == 2
    assert user1 in users
    assert user2 in users

def test_state_change_logging(config: ServerConfig, mock_users: FirebaseEmulatorUserManager):
    # GIVEN
    # a sender with a valid token and a new call uuid
    call_uuid = 'ggg'
    log = LogFirebase(config=config)
    users = UserRepositoryFirebase(config, log)
    sender_token_id, sender, _ = mock_users.users[0]

    # WHEN
    # the token is verified
    users.verify_sender_token_for_call(call_uuid, sender_token_id)

    # and then a state change is reported
    log.state_change(
        CallIdentifiable(call_uuid, CallDirection.SENDER),
        OutgoingCallState.IDLE.name,
        OutgoingCallState.CALLING.name,
        trigger='mocks'
    )

    # THEN
    # the call's new state is reflected in the database
    call_path = config.firebase_directed_call_path(call_uuid, CallDirection.SENDER)
    data_ref = firebase_admin.db.reference(call_path)
    data = data_ref.get()
    assert isinstance(data, dict)
    assert data['state'] == 'CALLING'


