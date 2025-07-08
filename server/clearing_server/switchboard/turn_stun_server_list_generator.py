import base64
import hashlib
import hmac
import os
import time
import traceback
from pathlib import Path
from typing import override

import requests

from clearing_server.core.model.config import ServerConfig
from clearing_server.core.turn_stun_server_list_generator_base import (
    TurnStunServerListGeneratorBase,
)
from clearing_server.core.user_repository_base import UserRepositoryBase
from clearing_server.core.call_identifiable import CallIdentifiable


class TurnStunServerListGeneratorSharedSecret(TurnStunServerListGeneratorBase):

    async def _generate_credentials(self, user_uid: str, call: CallIdentifiable) -> list[dict]:
        expiry = (
            int(time.time())
            + self.config.turn_credential_lifetime_seconds
        )
        realm = self.config.turn_realm
        username = f"{expiry}:{realm}"

        digest = hmac.new(
            self.config.turn_shared_secret.encode(),
            username.encode(),
            hashlib.sha1,
        ).digest()
        password = base64.b64encode(digest).decode()

        return [{
            "urls": [self.config.turn_server_url],
            "username": username,
            "credential": password,
        }]


class TurnStunServerListGeneratorMeteredCa(TurnStunServerListGeneratorBase):

    def __init__(self, config: ServerConfig, users: UserRepositoryBase):
        super().__init__(config, users)
        
        self.secret_key = config.metered_api_secret_key
        secret_key_path = Path(config.metered_api_secret_key)
        if secret_key_path.is_absolute() and secret_key_path.exists():
            try:
                with open(secret_key_path, 'r') as f:
                    self.secret_key = f.read().strip()
            except Exception as exc:
                self.users.log.server_error(
                    f"Error reading metered.ca secret key file {secret_key_path}: {exc}",
                    error=exc,
                    stacktrace=traceback.format_exc(),
                )
            

    async def _generate_credentials(self, user_uid: str, call: CallIdentifiable) -> [dict]:
        turn_credentials = self.create_turn_credentials(user_uid, call)
        api_key = turn_credentials["apiKey"]
        ice_servers = self.fetch_ice_servers(api_key)
        return ice_servers

    def create_turn_credentials(self, user_uid: str, call: CallIdentifiable) -> dict:
        url = f"{self.config.metered_create_api_key_url}?secretKey={self.secret_key}"
        payload = {
            "expiryInSeconds": self.config.turn_credential_lifetime_seconds,
            "label": f"{call.uuid}-{call.direction.name}-{user_uid}"
        }
        headers = {
            "Content-Type": "application/json"
        }

        response = requests.post(url, json=payload, headers=headers)

        if response.status_code != 200:
            raise RuntimeError(f"Failed to create TURN credentials against URL {self.config.metered_create_api_key_url}: {response.status_code} {response.text}")

        data = response.json()
        required_keys = {"username", "password", "apiKey"}
        if not required_keys.issubset(data.keys()):
            raise RuntimeError(f"Unexpected TURN credentials response structure: {data}")

        return data


    def fetch_ice_servers(self, api_key: str) -> list[dict]:
        ice_url = f"{self.config.metered_get_authed_turn_servers_url}?apiKey={api_key}"

        response = requests.get(ice_url)
        if response.status_code != 200:
            raise RuntimeError(f"Failed to fetch ICE servers against {self.config.metered_create_api_key_url}: {response.status_code} {response.text}")

        data = response.json()
        if not isinstance(data, list) or not data:
            raise RuntimeError(f"Unexpected ICE servers response structure: {data}")

        return data