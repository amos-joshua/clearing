from unittest.mock import MagicMock

from clearing_server.calls.outgoing.call import OutgoingCall
from clearing_server.calls.outgoing.timeout_scheduler import TimeoutScheduler
from clearing_server.core.context import CallContext


def mock_outgoing_call(uuid: str, context: CallContext) -> OutgoingCall:
    timeout_scheduler = MagicMock(spec=TimeoutScheduler)
    timeout_scheduler.schedule_timeout.return_value = None
    call = OutgoingCall(uuid, context)
    call.timeout_scheduler = timeout_scheduler
    return call
