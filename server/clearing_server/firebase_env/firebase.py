import os

import firebase_admin
import firebase_admin.db
import firebase_admin.exceptions

from clearing_server.core.model.config import ServerConfig


def firebase_init(config: ServerConfig):
    if config.firebase_service_account_key:
        cred = firebase_admin.credentials.Certificate(
            config.firebase_service_account_key
        )
    else:
        cred = firebase_admin.credentials.ApplicationDefault()

    firebase_options = {
        "projectId": config.firebase_project_id,
    }
    if config.firebase_use_emulator:
        firebase_options["databaseURL"] = config.firebase_emulator_db_url()
        os.environ["FIREBASE_AUTH_EMULATOR_HOST"] = (
            config.firebase_emulator_auth_endpoint()
        )
    else:
        firebase_options["databaseURL"] = config.firebase_database_url
    try:
        firebase_admin.initialize_app(cred, firebase_options)

        if config.clear_db_on_startup:
            ref = firebase_admin.db.reference("/")
            ref.delete()
    except firebase_admin.exceptions.UnavailableError as exc:
        raise RuntimeError(
            f"Could not connect to the firebase emulator at: {config.firebase_emulator_db_url()}"
        ) from exc
