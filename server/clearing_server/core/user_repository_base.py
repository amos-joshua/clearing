from typing import Any

from clearing_server.core.direction import CallDirection
from clearing_server.core.model.users import Device, User

from .log_base import LogBase


class UserRepositoryBase:
    def __init__(self, call_log: LogBase):
        self.log = call_log

    def verify_sender_token_for_call(
        self, call_uuid: str, client_token
    ) -> User:
        raise NotImplemented()

    def verify_admin_token(self, token: str) -> User:
        raise NotImplemented()

    def verify_receiver_token_for_call(
        self, call_uuid: str, client_token
    ) -> User:
        raise NotImplemented()

    def users_for_phone_numbers(self, call_uuid: str, phone_numbers: list[str]) -> list[User]:
        raise NotImplemented()

    def devices_for_users(
        self, call_uuid: str, users: list[User]
    ) -> list[Device]:
        raise NotImplemented()

    def update_recipients_for_call(
        self, call_uuid: str, recipients: list[User]
    ):
        raise NotImplemented()

    def call_state(self, call_uuid: str, direction: CallDirection) -> Any:
        raise NotImplemented()

    def sender_state(self, call_uuid: str):
        return self.call_state(call_uuid, CallDirection.SENDER)

    def receiver_state(self, call_uuid: str):
        return self.call_state(call_uuid, CallDirection.RECEIVER)

    def touch_call(self, call_uuid: str):
        raise NotImplemented()

    def user_info_by_phone_number(self, phone_number: str) -> dict | None:
        raise NotImplemented()

    def user_info_by_uid(self, uid: str) -> dict | None:
        raise NotImplemented()
