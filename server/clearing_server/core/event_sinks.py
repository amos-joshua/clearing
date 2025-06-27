import asyncio
from typing import Any, Awaitable, Callable

AsyncConsumer = Callable[[Any], Awaitable[None]]


class EventSinks:
    def __init__(
        self,
        client_sink: AsyncConsumer,
        message_broker_sink: AsyncConsumer,
        push_notifications_sink: AsyncConsumer,
    ):
        self.client_sink = client_sink
        self.message_broker_sink = message_broker_sink
        self.push_notifications_sink = push_notifications_sink
        self.call_events_queue = asyncio.Queue()

    @staticmethod
    def for_incoming_call(
        receiver_client_sink: AsyncConsumer,
        sender_message_broker_sink: AsyncConsumer,
        push_notifications_sink: AsyncConsumer,
    ):
        return EventSinks(
            client_sink=receiver_client_sink,
            message_broker_sink=sender_message_broker_sink,
            push_notifications_sink=push_notifications_sink,
        )

    @staticmethod
    def for_outgoing_call(
        sender_client_sink: AsyncConsumer,
        receiver_message_broker_sink: AsyncConsumer,
        push_notifications_sink: AsyncConsumer,
    ):
        return EventSinks(
            client_sink=sender_client_sink,
            message_broker_sink=receiver_message_broker_sink,
            push_notifications_sink=push_notifications_sink,
        )
