from pydantic import BaseModel


class User(BaseModel):
    name: str
    uid: str
    email: str
    phone_number: str


class Device(BaseModel):
    token: str
    description: str
