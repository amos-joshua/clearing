from unittest.mock import MagicMock

from clearing_server.core.direction import CallDirection
from clearing_server.core.model.users import User, Device
from clearing_server.core.user_repository_base import UserRepositoryBase

def mock_users_repository(auth_as: User | Exception, recipients: list[User] | None = None, devices: list[Device] | None = None, initial_sender_state: str | None = None, initial_receiver_state: str | None = None):
    users = MagicMock(spec=UserRepositoryBase)
    if isinstance(auth_as, User):
        users.verify_sender_token_for_call.return_value = auth_as
    else:
        users.verify_sender_token_for_call.side_effect = auth_as
    users.users_for_emails.return_value = recipients if recipients else []
    users.devices_for_users.return_value = devices if devices else []
    users.call_state.side_effect = lambda uuid, direction: initial_sender_state if direction == CallDirection.SENDER else initial_receiver_state
    #users.sender_state.return_value = initial_sender_state
    #users.receiver_state.return_value = initial_receiver_state
    return users
