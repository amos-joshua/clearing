from enum import Enum


class CallDirection(Enum):
    SENDER = 0
    RECEIVER = 1

    def opposite(self):
        if self == CallDirection.SENDER:
            return CallDirection.RECEIVER
        return CallDirection.SENDER
