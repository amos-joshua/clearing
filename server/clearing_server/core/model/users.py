from pydantic import BaseModel


class User(BaseModel):
    name: str
    uid: str
    phone_number: str
    email: str | None = None


class Device(BaseModel):
    token: str
    description: str
