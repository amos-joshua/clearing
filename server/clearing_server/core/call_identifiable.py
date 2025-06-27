from clearing_server.core.direction import CallDirection


class CallIdentifiable:

    def __init__(self, uuid: str, direction: CallDirection):
        self.uuid = uuid
        self.direction = direction

    def __repr__(self):
        return f"CallIdentifiable({self.uuid}, {self.direction})"
