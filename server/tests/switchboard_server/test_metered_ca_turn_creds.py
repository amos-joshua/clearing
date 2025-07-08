from clearing_server.switchboard.call_log import LogFirebase

from clearing_server.core.log_base import LogBase

from clearing_server.core.direction import CallDirection

from clearing_server.core.call_identifiable import CallIdentifiable


import pytest

from clearing_server.core.model.config import ServerConfig
from clearing_server.switchboard.turn_stun_server_list_generator import TurnStunServerListGeneratorMeteredCa
from clearing_server.switchboard.user_repository import UserRepositoryFirebase
from clearing_server.switchboard_server.mocks.firebase_emulator_user_manager import FirebaseEmulatorUserManager
from tests.calls.mocks.log import MockLog


#@pytest.fixture(scope="session")
#def users(config: ServerConfig, log: LogBase) -> UserRepositoryFirebase:
#    return UserRepositoryFirebase(config, log)
#
#@pytest.fixture(scope="session")
#def log(config: ServerConfig) -> LogBase:
#    return MockLog(verbose=True)
#
#@pytest.mark.asyncio
#async def test_metered_ca_turn_credential_generation(mock_users: FirebaseEmulatorUserManager, users: UserRepositoryFirebase, config: ServerConfig):
#    cred_generator = TurnStunServerListGeneratorMeteredCa(config, users)
#    creds = await cred_generator.generate_list('1234', CallIdentifiable('abcdef', CallDirection.SENDER))
#    assert creds == []

