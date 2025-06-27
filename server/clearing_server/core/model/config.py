from enum import Enum
from typing import List

from pydantic import Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict

from clearing_server.core.call_identifiable import CallIdentifiable
from clearing_server.core.direction import CallDirection
from clearing_server.core.model.users import User


class ServerEnvironment(str, Enum):
    test = "test"
    dev = "dev"
    staging = "staging"
    prod = "prod"


class ServerConfig(BaseSettings):
    model_config = SettingsConfigDict(env_prefix="clearing_")

    version: str
    environment: ServerEnvironment

    dot_env: str | None = Field(
        None,
        description="Path to env file to load environment variables from (optional)",
    )
    call_timeout_seconds: float = Field(
        description="Timeout in seconds for a unanswered call to timeout",
        ge=0,
    )
    sender_max_device_tokens_per_call: int = Field(
        5,
        description="Timeout in seconds for a unanswered call to timeout",
        ge=0,
    )

    server_port: int = Field(description="HTTP server port")
    server_host: str = Field("localhost", description="HTTP server host")
    verbose_log: bool = Field(
        False,
    )

    rabbit_mq_url: str = Field(
        "amqp://guest:guest@localhost/",
        description="Rabbit MQ url",
    )

    # CORS configuration
    switchboard_cors_allowed: List[str] = Field(
        default=["http://localhost:5173"],
        description="List of allowed CORS origins for the switchboard API",
    )

    firebase_project_id: str = Field("demo-project", min_length=1)
    firebase_use_emulator: bool = Field(
        False,
        description="Whether or not to use the firebase emulator. If True, firebase_emulator_host must also be set and there is no need to set a firebase project id or service account key. When False, a valid project id and key must be provided",
    )
    firebase_emulator_host: str | None = Field(
        None,
        description="Host for the firebase emulator, usually localhost or the ip of the dev machine on the local network",
    )
    firebase_emulator_db_port: int = Field(
        -1, description="The port used by the firebase realtime db emulator"
    )
    firebase_emulator_auth_port: int = Field(
        -1, description="The port used by the firebase auth emulator"
    )
    firebase_service_account_key: str | None = Field(
        None,
        description="Path to a firebase service account key, or a string json payload with the key itself",
    )
    firebase_database_url: str | None = Field(
        None,
        description="Optional database URL for firebase realtime database. If null, defaults to default database for project",
    )

    clear_db_on_startup: bool = Field(
        False,
        description="When set to True, the server will clear the database on startup. Only valid for the test and dev environments",
    )

    @property
    def is_dev_env(self):
        return self.environment == ServerEnvironment.dev

    @model_validator(mode="after")
    def validate_prod_values(self):
        if self.environment in ["staging", "prod"]:
            if self.clear_db_on_startup:
                raise ValueError(
                    "clear_db_on_startup can only be used in test, dev"
                )
            if self.firebase_use_emulator:
                raise ValueError(
                    "firebase_use_emulator can only be set for test, dev"
                )
        return self

    @staticmethod
    def firebase_call_root_path(call_uuid: str):
        return f"calls/{call_uuid}"

    @staticmethod
    def firebase_directed_call_path(call_uuid: str, direction: CallDirection):
        return f"calls/{call_uuid}/{direction.name}"

    @staticmethod
    def firebase_users_path():
        return f"users"

    @staticmethod
    def firebase_user_path(user: User):
        return f"users/{user.uid}"

    @staticmethod
    def firebase_root_path(self):
        return self.environment

    @staticmethod
    def firebase_call_log_path(call: CallIdentifiable):
        return f"logs/call/{call.uuid}/{call.direction.name}"

    @staticmethod
    def firebase_server_logs():
        return f"logs/server"

    @staticmethod
    def firebase_push_notification_logs():
        return f"logs/push_notifications"

    @staticmethod
    def user_permissions_path(user_uid: str):
        return f"user_permissions/{user_uid}"

    def firebase_emulator_db_url(self):
        return f"http://{self.firebase_emulator_host}:{self.firebase_emulator_db_port}?ns={self.environment.name}"

    def firebase_emulator_auth_endpoint(self):
        return (
            f"{self.firebase_emulator_host}:{self.firebase_emulator_auth_port}"
        )
