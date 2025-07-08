import traceback
import asyncio

from clearing_server.core.user_repository_base import UserRepositoryBase

from clearing_server.core.model.config import ServerConfig
from clearing_server.core.call_identifiable import CallIdentifiable


class TurnStunServerListGeneratorBase:
    def __init__(self, config: ServerConfig, users: UserRepositoryBase):
        self.config = config
        self.users = users

    async def generate_list(self, user_uid: str, call: CallIdentifiable) -> list[dict]:
        ice_servers = [
            {
                "urls": [
                    "stun:stun1.l.google.com:19302",
                    "stun:stun2.l.google.com:19302",
                ],
            }
        ]

        daily_count = self.users.user_stats_daily_call_count(user_uid)
        if daily_count < self.config.turn_daily_credential_limit:
            try:
                authorized_turn = await asyncio.wait_for(
                    self._generate_credentials(user_uid, call),
                    timeout=self.config.turn_credential_generation_timeout_seconds
                )
                ice_servers = authorized_turn + ice_servers
            except asyncio.TimeoutError:
                self.users.log.error(
                    call,
                    f"Timeout generating TURN credentials after {self.config.turn_credential_generation_timeout_seconds} seconds",
                )
            except Exception as exc:
                self.users.log.error(
                    call,
                    f"Error generating TURN credentials",
                    error=exc,
                    stacktrace=traceback.format_exc(),
                )
                
        else:
            self.users.log.warn(
                call,
                f"User {user_uid} has reached the daily TURN credential limit {self.config.turn_daily_credential_limit}",
            )

        return ice_servers

    async def _generate_credentials(self, user_uid: str, call: CallIdentifiable) -> list[dict]:
        raise NotImplementedError()


