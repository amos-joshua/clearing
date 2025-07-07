
from clearing_server.core.context import CallContext
from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.model.users import User, Device
from clearing_server.core.model.config import ServerConfig
from tests.calls.mocks.turn_server_generator_mock import TurnStunServerListGeneratorMock
from tests.calls.mocks.call_log import MockLog
from tests.calls.mocks.sinks import MockEventSinks
from tests.calls.mocks.users import mock_users_repository


class MockCallContext(CallContext):

    def __init__(self, auth_as: User | Exception, recipients: list[User] | None = None, devices: list[Device] | None = None, config: ServerConfig | None = None, verbose_log=False, initial_sender_state: str | None = None, initial_receiver_state: str | None = None):
        self.mock_sinks = MockEventSinks()
        self.mock_users = mock_users_repository(auth_as, recipients, devices, initial_sender_state, initial_receiver_state)
        self.mock_log = MockLog(verbose=verbose_log)
        config = config if config else ServerConfig(
            version="mocks",
            environment="test",
            call_timeout_seconds=5.0,
            server_host='127.0.0.1',
            server_port='314159'
        )
        super().__init__(sinks=self.mock_sinks, users=self.mock_users, log=self.mock_log, config=config, turn_server_generator=TurnStunServerListGeneratorMock(config, self.mock_users))


class MockCallContextWithSinks(CallContext):

    def __init__(self, auth_as: User | Exception, sinks:  EventSinks, recipients: list[User] | None = None, devices: list[Device] | None = None,  initial_sender_state: str | None = None, initial_receiver_state: str | None = None, config: ServerConfig | None = None, verbose_log=False):
        self.mock_users = mock_users_repository(auth_as, recipients, devices, initial_sender_state, initial_receiver_state)
        self.mock_log = MockLog(verbose=verbose_log)
        config = config if config else ServerConfig(
            version="mocks",
            environment="test",
            call_timeout_seconds=5.0,
            server_host='127.0.0.1',
            server_port='314159'
        )

        super().__init__(sinks=sinks, users=self.mock_users, log=self.mock_log, config=config, turn_server_generator=TurnStunServerListGeneratorMock(config, self.mock_users))

