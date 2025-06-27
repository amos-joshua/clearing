from clearing_server.core.model.config import ServerConfig
from clearing_server.firebase_env.firebase import firebase_init
from clearing_server.switchboard_server.mocks.firebase_emulator_user_manager import (
    FirebaseEmulatorUserManager,
)


def bootstrap_db_dev_env():
    config = ServerConfig(
        _env_file=".env",
        version="dev",
        environment="dev",
        call_timeout_seconds=25.0,
        clear_db_on_startup=True,
    )

    print("Clearing existing database...")
    firebase_init(config)

    mock_users = FirebaseEmulatorUserManager(config)
    mock_users.create_mock_user_list1(create_devices=False)

    print("Created users:")
    for user in mock_users.users:
        print(f"  - {user[1].email}")


if __name__ == "__main__":
    bootstrap_db_dev_env()
