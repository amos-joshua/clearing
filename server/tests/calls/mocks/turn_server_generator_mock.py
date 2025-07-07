from clearing_server.core.call_identifiable import CallIdentifiable

from clearing_server.core.user_repository_base import UserRepositoryBase

from clearing_server.core.model.config import ServerConfig

from clearing_server.core.turn_stun_server_list_generator_base import TurnStunServerListGeneratorBase

class TurnStunServerListGeneratorMock(TurnStunServerListGeneratorBase):
    def __init__(self, config: ServerConfig, users: UserRepositoryBase):
        self.turn_servers = [{
            "urls": ["stun.example.com:3478"]
            }
        ]
        super().__init__(config, users)

    def generate_list(self, user_uid: str, call: CallIdentifiable) -> list[dict]:
        return self.turn_servers