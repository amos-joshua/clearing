import importlib.metadata
import os
import pprint

from pydantic import ValidationError

from clearing_server.core.log_base import LogBase
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.user_repository_base import UserRepositoryBase
from clearing_server.firebase_env.firebase import firebase_init
from clearing_server.switchboard.call_log import LogFirebase
from clearing_server.switchboard.user_repository import UserRepositoryFirebase


def load_config(quiet=False) -> ServerConfig:
    env_file_path = os.environ.get("CLEARING_DOT_ENV", None)
    if env_file_path and not os.path.isfile(env_file_path):
        print(f"WARNING: file at {env_file_path} does not exist")

    try:
        pkg_version = importlib.metadata.version("clearing_server")
    except importlib.metadata.PackageNotFoundError:
        pkg_version = "dev-latest"

    try:
        config = ServerConfig(version=pkg_version, _env_file=env_file_path)
        if not quiet:
            print("== Server config ==")
            pprint.pprint(config.model_dump(), indent=2)
            print("")
    except ValidationError as e:
        errors = []
        for error in e.errors():
            loc = " -> ".join(str(i) for i in error["loc"])
            msg = error["msg"]
            errors.append(f"❌ {loc}: {msg}")
        raise ValueError("\n".join(errors))
    return config


def load_root_dependencies() -> (
    tuple[ServerConfig, UserRepositoryBase, LogBase]
):
    config = load_config()

    firebase_init(config)
    log = LogFirebase(config)
    users = UserRepositoryFirebase(config, log)
    return config, users, log
