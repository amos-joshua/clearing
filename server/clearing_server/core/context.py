from clearing_server.calls.errors import CallParticipantAuthenticationFailure
from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.log_base import CallIdentifiable, LogBase
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.model.events import (
    AuthenticatedEventBase,
    CallEvent,
)
from clearing_server.core.model.users import User
from clearing_server.core.turn_stun_server_list_generator_base import (
    TurnStunServerListGeneratorBase,
)
from clearing_server.core.user_repository_base import UserRepositoryBase


class CallContext:
    def __init__(
        self,
        sinks: EventSinks,
        users: UserRepositoryBase,
        log: LogBase,
        config: ServerConfig,
        turn_server_generator: TurnStunServerListGeneratorBase,
    ):
        self.log = log
        self.sinks = sinks
        self.users = users
        self.config = config
        self.authenticated_user: User | None = None
        self.turn_server_generator = turn_server_generator

    def authenticate_receiver_event(
        self, call: CallIdentifiable, event: CallEvent
    ):
        if self.authenticated_user:
            return

        if not isinstance(event, AuthenticatedEventBase):
            self.log.warn(
                call,
                f"Received an unauthenticated event of type {type(event).__name__} but call has not yet been authenticated",
            )
            raise CallParticipantAuthenticationFailure()

        self.authenticated_user = self.users.verify_receiver_token_for_call(
            call.uuid, event.client_token_id
        )

    def authenticate_sender_event(
        self, call: CallIdentifiable, event: CallEvent
    ):
        if self.authenticated_user:
            return

        if not isinstance(event, AuthenticatedEventBase):
            self.log.warn(
                call,
                f"Received an unauthenticated event of type {type(event).__name__} but call has not yet been authenticated",
            )
            raise CallParticipantAuthenticationFailure()

        self.authenticated_user = self.users.verify_sender_token_for_call(
            call.uuid, event.client_token_id
        )
