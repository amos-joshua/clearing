import datetime
import traceback
from typing import Any, override

import firebase_admin.auth
import firebase_admin.db

from clearing_server.calls.errors import CallParticipantAuthenticationFailure
from clearing_server.calls.incoming.state import IncomingCallState
from clearing_server.calls.outgoing.state import OutgoingCallState
from clearing_server.core.direction import CallDirection
from clearing_server.core.log_base import CallIdentifiable, LogBase
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.model.users import Device, User
from clearing_server.core.user_repository_base import UserRepositoryBase


class UserRepositoryFirebase(UserRepositoryBase):
    SENDER_UID_KEY = "sender-uid"
    RECIPIENTS_KEY = "recipients"

    @staticmethod
    def _get_call_structure() -> dict:
        return {
            "created-at": datetime.datetime.now().isoformat(),
            CallDirection.SENDER.name: {
                "log": {},
                "state": OutgoingCallState.IDLE.name,
                "devices": {},
            },
            CallDirection.RECEIVER.name: {
                "log": {},
                "state": IncomingCallState.IDLE.name,
                "devices": {},
            },
        }

    def __init__(self, config: ServerConfig, call_log: LogBase):
        super().__init__(call_log)
        self.config = config

    @staticmethod
    def _verify_token(client_token) -> User:
        try:
            decoded_token = firebase_admin.auth.verify_id_token(client_token)
        except:
            raise CallParticipantAuthenticationFailure()
        return User(
            name=decoded_token.get("name", decoded_token["email"]),
            uid=decoded_token["uid"],
            email=decoded_token["email"],
        )

    @override
    def verify_sender_token_for_call(
        self, call_uuid: str, client_token
    ) -> User:
        self.touch_call(call_uuid)
        sender = self._verify_token(client_token)
        call_reference, call_data = self._call_data(
            call_uuid, CallDirection.SENDER
        )
        known_sender = call_data.get(self.SENDER_UID_KEY, None)
        if known_sender is None:
            call_reference.update({self.SENDER_UID_KEY: sender.uid})
        elif known_sender != sender.uid:
            self.log.warn(
                CallIdentifiable(call_uuid, CallDirection.SENDER),
                f"Could not auth sender '{sender.uid}' for this call which was created by '{known_sender}'",
            )
            raise CallParticipantAuthenticationFailure()
        return sender

    @override
    def verify_admin_token(self, token: str) -> User:
        user = self._verify_token(token)
        user_permissions_path = self.config.user_permissions_path(user.uid)
        user_permissions = firebase_admin.db.reference(
            user_permissions_path
        ).get()
        if user_permissions is None:
            raise CallParticipantAuthenticationFailure()
        if user_permissions.get("admin", False):
            return user
        raise CallParticipantAuthenticationFailure()

    @override
    def verify_receiver_token_for_call(
        self, call_uuid: str, client_token
    ) -> User:
        recipient = self._verify_token(client_token)
        recipients = self._call_recipient_uids(call_uuid)
        if not recipient.uid in recipients:
            self.log.warn(
                CallIdentifiable(call_uuid, CallDirection.RECEIVER),
                f"Cannot authorize user '{recipient.uid}' as call receiver: not among {len(recipients)} call recipients",
            )
            raise CallParticipantAuthenticationFailure()
        return recipient

    @override
    def users_for_emails(self, call_uuid: str, emails: list[str]) -> list[User]:
        users = []
        for email in emails:
            try:
                user_data = firebase_admin.auth.get_user_by_email(email)
                if user_data:
                    users.append(
                        User(
                            name=user_data.display_name,
                            email=user_data.email,
                            uid=user_data.uid,
                        )
                    )
                else:
                    raise RuntimeError(
                        f"Expected user_data to be a UserRecord but found {type(user_data).__name__}"
                    )
            except Exception as exc:
                self.log.error(
                    CallIdentifiable(call_uuid, CallDirection.SENDER),
                    f"Could not retrieve user corresponding to email '{email}'",
                    error=exc,
                    stacktrace=traceback.format_exc(),
                )
        return users

    @override
    def devices_for_users(
        self, call_uuid: str, users: list[User]
    ) -> list[Device]:
        devices = []
        for user in users:
            try:
                user_path = self.config.firebase_user_path(user)
                user_data = firebase_admin.db.reference(user_path).get()
                if isinstance(user_data, dict):
                    user_devices = user_data.get("devices")
                    if isinstance(user_devices, dict):
                        devices.extend(
                            (
                                Device(
                                    token=device_token,
                                    description=user_devices[device_token],
                                )
                                for device_token in user_devices
                            )
                        )
                    else:
                        raise RuntimeError(
                            f"Expected devices for user {user.uid} to be a dict but found {type(user_devices).__name__}, skipping"
                        )
                else:
                    raise RuntimeError(
                        f"Expected user data for user {user.uid} to be a dict but found {type(user_data).__name__}, skipping"
                    )
            except Exception as exc:
                self.log.error(
                    CallIdentifiable(call_uuid, CallDirection.SENDER),
                    f"Could not retrieve devices for user {user}",
                    error=exc,
                    stacktrace=traceback.format_exc(),
                )
        return devices

    @override
    def update_recipients_for_call(
        self, call_uuid: str, recipients: list[User]
    ):
        call_path = self.config.firebase_directed_call_path(
            call_uuid, CallDirection.SENDER
        )
        call_reference = firebase_admin.db.reference(call_path)
        recipient_uids = [recipient.uid for recipient in recipients]
        call_reference.update({self.RECIPIENTS_KEY: recipient_uids})

    def _call_recipient_uids(self, call_uuid: str) -> list[User]:
        call_ref = firebase_admin.db.reference(
            self.config.firebase_directed_call_path(
                call_uuid, CallDirection.SENDER
            )
        )
        call = call_ref.get()
        try:
            if isinstance(call, dict):
                recipient_uids = call.get("recipients", None)
                if isinstance(recipient_uids, list):
                    return recipient_uids
                else:
                    raise RuntimeError(
                        f"Expected SENDER data to contain a list of uids for key 'recipients', but found {type(recipient_uids).__name__}"
                    )
            else:
                raise RuntimeError(
                    f"No SENDER data found for call, expected a dict but found {type(call).__name__}"
                )
        except Exception as exc:
            self.log.error(
                CallIdentifiable(call_uuid, CallDirection.SENDER),
                f"Could not retrieve recipient uids for call {call_uuid}",
                error=exc,
                stacktrace=traceback.format_exc(),
            )

    @override
    def call_state(self, call_uuid: str, direction: CallDirection) -> Any:
        _, call_data = self._try_call_data(call_uuid, direction)
        return call_data.get("state", None) if call_data else None

    @override
    def touch_call(self, call_uuid: str):
        self._call_data(call_uuid)

    def _try_call_data(
        self, call_uuid: str, direction: CallDirection | None = None
    ) -> tuple[firebase_admin.db.Reference, dict | None]:
        if direction:
            call_path = self.config.firebase_directed_call_path(
                call_uuid, direction
            )
        else:
            call_path = self.config.firebase_call_root_path(call_uuid)
        call_reference = firebase_admin.db.reference(call_path)
        call_data = call_reference.get()
        if call_data is None or isinstance(call_data, dict):
            return call_reference, call_data

        raise RuntimeError(
            f"Invalid call data at '{call_path}', expected a dict but found {type(call_data).__name__}"
        )

    def _call_data(
        self, call_uuid: str, direction: CallDirection | None = None
    ) -> tuple[firebase_admin.db.Reference, dict]:
        call_reference, call_data = self._try_call_data(call_uuid, direction)
        if call_data is None:
            call_structure = self._get_call_structure()
            call_data = (
                call_structure[direction.name]
                if direction
                else call_structure
            )
            call_reference.update(call_data)
        return call_reference, call_data

    @override
    def user_info_by_email(self, email: str) -> dict:
        user = firebase_admin.auth.get_user_by_email(email)
        return self._user_properties_as_dict(user)

    @override
    def user_info_by_uid(self, uid: str) -> dict:
        user = firebase_admin.auth.get_user(uid)
        return self._user_properties_as_dict(user)

    @staticmethod
    def _user_properties_as_dict(user: firebase_admin.auth.UserRecord) -> dict:
        properties = {}
        for name in dir(user.__class__):
            attr = getattr(user.__class__, name)
            if isinstance(attr, property):
                properties[name] = getattr(user, name)
        return properties