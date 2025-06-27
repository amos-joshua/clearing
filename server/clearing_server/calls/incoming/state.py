from enum import Enum


class IncomingCallState(Enum):
    IDLE = 0
    RINGING = 1
    ONGOING = 2
    ENDED = 3
