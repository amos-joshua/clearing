from enum import Enum


class OutgoingCallState(Enum):
    IDLE = 0
    CALLING = 1
    RINGING = 2
    ONGOING = 3
    UNANSWERED = 4
    REJECTED = 5
    ENDED = 6
