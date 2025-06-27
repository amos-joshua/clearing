from enum import StrEnum, auto
from typing import Annotated, List, Literal, Union

from pydantic import BaseModel, Field, TypeAdapter


class CallEvents(StrEnum):
    SENDER_CALL_INIT = auto()
    SENDER_ICE_CANDIDATES = auto()
    SENDER_HANG_UP = auto()
    SENDER_DISCONNECTED = auto()
    RECEIVER_ACK = auto()
    RECEIVER_HANG_UP = auto()
    RECEIVER_REJECT = auto()
    RECEIVER_ACCEPT = auto()
    RECEIVER_DISCONNECTED = auto()
    CALL_TIMEOUT = auto()
    INCOMING_CALL_INIT = auto()
    ERROR = auto()

    @staticmethod
    def parse_json(data: bytes | str):
        str_data = data if isinstance(data, bytes) else data.encode()
        return TypeAdapter(CallEvent).validate_json(str_data)

    @staticmethod
    def parse_python(data: dict):
        return TypeAdapter(CallEvent).validate_python(data)


class AuthenticatedEventBase(BaseModel):
    client_token_id: str


class SenderCallInit(AuthenticatedEventBase):
    call_event: Literal[CallEvents.SENDER_CALL_INIT] = (
        CallEvents.SENDER_CALL_INIT
    )
    receiver_emails: List[str] = Field(
        description="List of receiver email addresses"
    )
    urgency: Literal["leisure", "important", "urgent"]
    subject: str
    sdp_offer: str = Field(description="WebRTC sdp offer")


class SenderIceCandidates(BaseModel):
    call_event: Literal[CallEvents.SENDER_ICE_CANDIDATES] = (
        CallEvents.SENDER_ICE_CANDIDATES
    )
    ice_candidates: list[str]


class SenderHangUp(BaseModel):
    call_event: Literal[CallEvents.SENDER_HANG_UP] = CallEvents.SENDER_HANG_UP


class SenderDisconnected(BaseModel):
    call_event: Literal[CallEvents.SENDER_DISCONNECTED] = (
        CallEvents.SENDER_DISCONNECTED
    )


class IncomingCallInit(BaseModel):
    call_event: Literal[CallEvents.INCOMING_CALL_INIT] = (
        CallEvents.INCOMING_CALL_INIT
    )
    call_uuid: str
    caller_display_name: str
    receiver_device_token_ids: list[str]
    caller_email: str = Field(..., description="Sender's email")
    urgency: Literal["leisure", "important", "urgent"]
    subject: str
    sdp_offer: str = Field(
        ..., description="Session Description Protocol (SDP) offer"
    )

    @staticmethod
    def for_call(
        call_uuid: str,
        sender_email: str,
        sender_name: str,
        device_token_ids: list[str],
        event: SenderCallInit,
    ):
        return IncomingCallInit(
            call_uuid=call_uuid,
            receiver_device_token_ids=device_token_ids,
            caller_email=sender_email,
            caller_display_name=sender_name,
            subject=event.subject,
            urgency=event.urgency,
            sdp_offer=event.sdp_offer,
        )


class ReceiverAck(AuthenticatedEventBase):
    call_event: Literal[CallEvents.RECEIVER_ACK] = CallEvents.RECEIVER_ACK
    sdp_answer: str


class ReceiverAccept(BaseModel):
    call_event: Literal[CallEvents.RECEIVER_ACCEPT] = CallEvents.RECEIVER_ACCEPT
    timestamp: str


class ReceiverReject(AuthenticatedEventBase):
    call_event: Literal[CallEvents.RECEIVER_REJECT] = CallEvents.RECEIVER_REJECT
    reason: str = ""


class ReceiverDisconnected(BaseModel):
    call_event: Literal[CallEvents.RECEIVER_DISCONNECTED] = (
        CallEvents.RECEIVER_DISCONNECTED
    )


class CallTimeout(BaseModel):
    call_event: Literal[CallEvents.CALL_TIMEOUT] = CallEvents.CALL_TIMEOUT


class ReceiverHangUp(BaseModel):
    call_event: Literal[CallEvents.RECEIVER_HANG_UP] = (
        CallEvents.RECEIVER_HANG_UP
    )


class CallError(BaseModel):
    call_event: Literal[CallEvents.ERROR] = CallEvents.ERROR
    error_code: str  # NOTE: this should be one of the EXTERNALLY_VISIBLE exception class names, e.g. ServerError
    error_message: str


CallEvent = Annotated[
    Union[
        ReceiverAck,
        ReceiverAccept,
        ReceiverReject,
        ReceiverHangUp,
        ReceiverDisconnected,
        SenderCallInit,
        SenderIceCandidates,
        SenderDisconnected,
        IncomingCallInit,
        CallTimeout,
        SenderHangUp,
        CallError,
    ],
    Field(discriminator="call_event"),
]
