import traceback

import aio_pika
from starlette.websockets import WebSocket

from clearing_server.calls.incoming.call import IncomingCall
from clearing_server.calls.outgoing.call import OutgoingCall
from clearing_server.core.call_identifiable import CallIdentifiable
from clearing_server.core.context import CallContext
from clearing_server.core.direction import CallDirection
from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.user_repository_base import UserRepositoryBase
from clearing_server.message_queues.rabbitmq_call_channel import (
    RabbitMQCallChannel,
)
from clearing_server.session.session import CallSession
from clearing_server.switchboard.turn_stun_server_list_generator import (
    TurnStunServerListGeneratorSharedSecret,
)
from clearing_server.switchboard.websocket_channel import WebSocketChannel


class SessionFactory:
    def __init__(
        self,
        connection: aio_pika.abc.AbstractRobustConnection,
        users: UserRepositoryBase,
        config: ServerConfig,
    ):
        self.connection = connection
        self.users = users
        self.config = config

    async def _create_channel(self) -> aio_pika.abc.AbstractChannel:
        return await self.connection.channel()

    async def outgoing(
        self, websocket: WebSocket, call_uuid: str, debug: bool
    ) -> tuple[OutgoingCall, CallSession]:
        websocket_channel = WebSocketChannel(
            websocket,
            call_uuid,
            CallDirection.SENDER,
            on_send_error=lambda msg: self._on_websocket_send_error(call, msg),
            log_debug=(lambda msg: self.users.log.debug(call, msg)) if debug else None,
        )

        channel = await self._create_channel()
        rabbitmq_channel = RabbitMQCallChannel(
            channel, call_uuid, CallDirection.SENDER,
            log_debug=(lambda msg: self.users.log.debug(call, msg)) if debug else None,
        )

        sinks = EventSinks.for_outgoing_call(
            sender_client_sink=websocket_channel.sink,
            receiver_message_broker_sink=rabbitmq_channel.sink.send,
            push_notifications_sink=rabbitmq_channel.push_notification_sink.send,
        )

        context = CallContext(
            sinks=sinks,
            users=self.users,
            log=self.users.log,
            config=self.config,
            turn_server_generator=TurnStunServerListGeneratorSharedSecret(
                config=self.config, users=self.users
            ),
            debug=debug,
        )

        call = OutgoingCall(call_uuid, context)

        return (
            call,
            CallSession.outgoing(
                sinks=sinks,
                sender_client_event_source=websocket_channel.source,
                receiver_message_broker_event_source=rabbitmq_channel.source,
                on_client_queue_error=lambda exc: self._on_queue_error(
                    call, "Error reading sender client source", exc
                ),
                on_message_broker_queue_error=lambda exc: self._on_queue_error(
                    call, "Error reading receiver message broker source", exc
                ),
            ),
        )

    async def incoming(
        self, websocket: WebSocket, call_uuid: str, debug: bool
    ) -> tuple[IncomingCall, CallSession]:
        websocket_channel = WebSocketChannel(
            websocket,
            call_uuid,
            CallDirection.RECEIVER,
            on_send_error=lambda msg: self._on_websocket_send_error(call, msg),
            log_debug=(lambda msg: self.users.log.debug(call, msg)) if debug else None,
        )

        channel = await self._create_channel()
        rabbitmq_channel = RabbitMQCallChannel(
            channel, call_uuid, CallDirection.RECEIVER,
            log_debug=(lambda msg: self.users.log.debug(call, msg)) if debug else None,
        )

        sinks = EventSinks.for_incoming_call(
            receiver_client_sink=websocket_channel.sink,
            sender_message_broker_sink=rabbitmq_channel.sink.send,
            push_notifications_sink=rabbitmq_channel.push_notification_sink.send,
        )

        context = CallContext(
            sinks=sinks,
            users=self.users,
            log=self.users.log,
            config=self.config,
            turn_server_generator=TurnStunServerListGeneratorSharedSecret(
                config=self.config, users=self.users
            ),
            debug=debug,
        )

        call = IncomingCall(call_uuid, context)

        return (
            call,
            CallSession.incoming(
                sinks=sinks,
                receiver_client_event_source=websocket_channel.source,
                sender_message_broker_event_source=rabbitmq_channel.source,
                on_client_queue_error=lambda exc: self._on_queue_error(
                    call, "Error reading event from receiver client source", exc
                ),
                on_message_broker_queue_error=lambda exc: self._on_queue_error(
                    call, "Error reading sender message broker source", exc
                ),
            ),
        )

    def _on_queue_error(
        self, call: CallIdentifiable, message: str, exc: Exception
    ):
        self.users.log.error(
            call,
            f"{message}: {exc}",
            error=exc,
            stacktrace="\n".join(traceback.format_exception(exc)),
        )

    def _on_websocket_send_error(self, call: CallIdentifiable, message: str):
        self.users.log.warn(
            call,
            f"Could not send to client: {message} (probable cause: client closed the connection)",
        )

    async def incoming_reject(self, call_uuid: str, debug: bool) -> IncomingCall:
        channel = await self._create_channel()
        rabbitmq_channel = RabbitMQCallChannel(
            channel, call_uuid, CallDirection.RECEIVER
        )

        async def placeholder_sink(_):
            pass

        sinks = EventSinks(
            client_sink=placeholder_sink,
            message_broker_sink=rabbitmq_channel.sink.send,
            push_notifications_sink=placeholder_sink,
        )
        context = CallContext(
            sinks=sinks,
            users=self.users,
            log=self.users.log,
            config=self.config,
            debug=debug,
        )
        call = IncomingCall(call_uuid, context)

        return call
