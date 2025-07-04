import firebase_admin.db
import requests

from clearing_server.core.model.config import ServerConfig
from clearing_server.core.model.users import Device, User


class FirebaseEmulatorUserManager:
    def __init__(self, config: ServerConfig):
        self.config = config
        self.auth_endpoint = f"{self.config.firebase_emulator_host}:{self.config.firebase_emulator_auth_port}"
        self.users: list[(str, User, Device | None)] = []

    def create_user(
        self,
        display_name: str,
        phone_number: str,
        email: str,
        password: str,
        create_device: bool,
        is_admin=False,
    ):
        base_url = (
            f"http://{self.auth_endpoint}/identitytoolkit.googleapis.com/v1"
        )

        resp = requests.post(
            f"{base_url}/accounts:signUp?key=fake-api-key",  # key is ignored in emulator
            json={
                "email": email,
                "displayName": display_name,
                "password": password,
                "returnSecureToken": True,
            },
            headers={"Content-Type": "application/json"},
        )

        data = resp.json()
        error = data.get("error", None)
        if error:
            raise RuntimeError(
                f"Could not create user ({display_name}, {email}, {password}): {error}"
            )

        resp = requests.post(
            f"{base_url}/projects/callability-56e94/accounts:update",  # key is ignored in emulator
            json={
                "localId": data["localId"],
                "emailVerified": True,
                "phoneNumber": phone_number,
            },
            headers={"Content-Type": "application/json", "Authorization": "Bearer owner"},
        )

        error = resp.json().get("error", None)
        if error:
            raise RuntimeError(
                f"Could not update user {display_name}/{data["localId"]} with phone number {phone_number}: {resp.json()}"
            )


        user = User(
            name=data["displayName"], phone_number=phone_number, email=data["email"], uid=data["localId"]
        )
        device = (
            self._create_mock_device_entry_for_user(user)
            if create_device
            else None
        )
        self.users.append((data["idToken"], user, device))

        if is_admin:
            firebase_admin.db.reference(
                self.config.user_permissions_path(user.uid)
            ).update({"admin": True})

    def _create_mock_device_entry_for_user(self, user: User) -> Device:
        user_path = self.config.firebase_user_path(user)
        ersatz_device_id = user.phone_number.encode().hex()
        ersatz_device_label = f"Device name {user.name[-1]}"
        user_data = firebase_admin.db.reference(user_path)
        user_data.update({"devices": {ersatz_device_id: ersatz_device_label}})
        return Device(token=ersatz_device_id, description=ersatz_device_label)

    def delete_all_users(self):
        delete_url = f"http://{self.auth_endpoint}/emulator/v1/projects/{self.config.firebase_project_id}/accounts"
        requests.delete(
            delete_url, headers={"Content-Type": "application/json"}
        )
        users_path = self.config.firebase_users_path()
        firebase_admin.db.reference(users_path).delete()

    def create_mock_user_list1(self, create_devices: bool):
        self.delete_all_users()
        self.create_user(
            display_name="Admin",
            email="admin@example.com",
            phone_number="+15550000",
            password="password0",
            create_device=create_devices,
            is_admin=True,
        )
        self.create_user(
            display_name="User1",
            email="user1@example.com",
            phone_number="+15550001",
            password="password1",
            create_device=create_devices,
        )
        self.create_user(
            display_name="User2",
            phone_number="+15550002",
            email="user2@example.com",
            password="password2",
            create_device=create_devices,
        )
        self.create_user(
            display_name="User3",
            phone_number="+15550003",
            email="user3@example.com",
            password="password3",
            create_device=create_devices,
        )
