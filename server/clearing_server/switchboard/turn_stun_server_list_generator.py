import base64
import hashlib
import hmac
import time
import traceback
from typing import override

from clearing_server.core.model.config import ServerConfig
from clearing_server.core.turn_stun_server_list_generator_base import (
    TurnStunServerListGeneratorBase,
)
from clearing_server.core.user_repository_base import UserRepositoryBase


class TurnStunServerListGenerator(TurnStunServerListGeneratorBase):
    def __init__(self, config: ServerConfig, users: UserRepositoryBase):
        self.config = config
        self.users = users

    @override
    def generate_list(self, user_uid: str) -> list[dict]:
        ice_servers = [
            {
                "urls": [
                    "stun:stun1.l.google.com:19302",
                    "stun:stun2.l.google.com:19302",
                ],
            }
        ]

        daily_count = self.users.user_stats_daily_call_count(user_uid)
        if daily_count < self.config.clearing_turn_daily_credential_limit:
            try:
                authorized_turn = self._generate_credentials(user_uid)
                ice_servers.insert(0, authorized_turn)
            except Exception as exc:
                self.users.log.server_error(
                    f"Error generating TURN credentials for user {user_uid}",
                    exc,
                    traceback.format_exc(),
                )
        else:
            self.users.log.server_error(
                f"User {user_uid} has reached the daily TURN credential limit {self.config.clearing_turn_daily_credential_limit}",
            )

        return ice_servers

    def _generate_credentials(self, user_uid: str) -> dict:
        expiry = (
            int(time.time())
            + self.config.clearing_turn_credential_lifetime_seconds
        )
        realm = self.config.clearing_turn_realm
        username = f"{expiry}:{realm}"

        digest = hmac.new(
            self.config.clearing_turn_secret.encode(),
            username.encode(),
            hashlib.sha1,
        ).digest()
        password = base64.b64encode(digest).decode()

        return {
            {
                "urls": [self.config.clearing_turn_server_url],
                "username": username,
                "credential": password,
            }
        }
