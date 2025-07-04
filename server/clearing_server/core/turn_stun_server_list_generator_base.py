class TurnStunServerListGeneratorBase:
    def generate_list(self, user_uid: str) -> list[dict]:
        raise NotImplementedError()
