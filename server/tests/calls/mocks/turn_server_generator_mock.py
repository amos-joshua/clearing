from clearing_server.core.turn_stun_server_list_generator_base import TurnStunServerListGeneratorBase

class TurnStunServerListGeneratorMock(TurnStunServerListGeneratorBase):
    def __init__(self):
        self.turn_servers = [{
            "urls": ["stun.example.com:3478"]
            }
        ]

    def generate_list(self, user_uid: str) -> list[dict]:
        return self.turn_servers