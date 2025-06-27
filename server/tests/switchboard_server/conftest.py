import pytest

from clearing_server.core.model.config import ServerConfig
from clearing_server.firebase_env.firebase import firebase_init
from clearing_server.switchboard_server.mocks.firebase_emulator_user_manager import FirebaseEmulatorUserManager



@pytest.fixture(scope="session")
def config() -> ServerConfig:
    config = ServerConfig(
        _env_file='.env.test',
        version='mocks',
        clear_db_on_startup=True
    )
    return config

@pytest.fixture(scope="session", autouse=True)
def firebase_client(config: ServerConfig):
    firebase_init(config)

    yield

@pytest.fixture(scope="session")
def mock_users(firebase_client, config: ServerConfig):
    mockUsers = FirebaseEmulatorUserManager(config=config)
    mockUsers.create_mock_user_list1(create_devices=True)
    return mockUsers
