import uuid


class RecipientNotRegistered(Exception):
    """The given recipient is not registered on the switchboard"""

    def __init__(self, message: str):
        self.reference = uuid.uuid4().hex
        self.message = message

    def __str__(self):
        return self.message


class CallParticipantAuthenticationFailure(Exception):
    """The caller could not be authenticated"""

    def __init__(self):
        self.reference = uuid.uuid4().hex

    def __str__(self):
        return "Caller could not be authenticated"


class UnexpectedEvent(Exception):
    """Unexpected event"""

    def __init__(self, event):
        self.reference = uuid.uuid4().hex
        self.event_name = type(event).__name__

    def __str__(self):
        return f"Unexpected event {self.event_name}"


class ServerError(Exception):
    """An internal switchboard error with an opaque client-visible id"""

    def __init__(self, reference: str):
        self.reference = reference


class CallAlreadyStarted(Exception):
    def __init__(self):
        self.message = "call already started"
        self.reference = uuid.uuid4().hex

    def __repr__(self):
        return "Call already started"


class CallNotStarted(Exception):
    def __init__(self):
        self.message = "call not started"
        self.reference = uuid.uuid4().hex

    def __repr__(self):
        return "Call not started"


EXTERNALLY_VISIBLE_ERRORS = (
    CallParticipantAuthenticationFailure,
    UnexpectedEvent,
    RecipientNotRegistered,
    CallAlreadyStarted,
    CallNotStarted,
)

ExternallyVisibleError = (
    CallParticipantAuthenticationFailure
    | UnexpectedEvent
    | RecipientNotRegistered
    | CallAlreadyStarted
    | CallNotStarted
)
