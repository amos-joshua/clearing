from enum import Enum


class OutgoingCallState(Enum):
    IDLE = 0
    AUTHORIZED = 1
    CALLING = 2
    RINGING = 3
    ONGOING = 4
    UNANSWERED = 5
    REJECTED = 6
    BUSY = 7
    ENDED = 8
