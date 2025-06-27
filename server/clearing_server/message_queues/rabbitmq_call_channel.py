import aio_pika
from aio_pika import IncomingMessage
from aio_pika.abc import AbstractChannel, AbstractQueue

from clearing_server.core.direction import CallDirection
from clearing_server.core.model.events import (
    CallEvent,
    CallEvents,
    IncomingCallInit,
)


def _get_queue_name(direction: CallDirection, call_uuid: str) -> str:
    return f"call.from-{direction.name}.{call_uuid}"


PUSH_NOTIFICATIONS_QUEUE = "push-notification-requests"


class RabbitMQSink:

    def __init__(self, channel: AbstractChannel, queue_name: str):
        self.channel = channel
        self.queue_name = queue_name

    async def send(self, event: CallEvent):
        data = event.model_dump_json().encode()
        await self.channel.default_exchange.publish(
            aio_pika.Message(body=data), routing_key=self.queue_name
        )


class RabbitMQSource:
    def __init__(self, channel: AbstractChannel, queue_name: str):
        self.channel = channel
        self.queue_name = queue_name
        self._queue_obj: AbstractQueue | None = None

    async def listen(self):
        if not self._queue_obj:
            self._queue_obj = await self.channel.declare_queue(
                self.queue_name, auto_delete=True
            )

        async with self._queue_obj.iterator() as queue_iter:
            async for message in queue_iter:  # type: IncomingMessage
                async with message.process():
                    event = CallEvents.parse_json(message.body)
                    yield event


class RabbitMQCallChannel:
    def __init__(
        self,
        channel: AbstractChannel,
        call_uuid: str,
        direction: CallDirection,
    ):
        self.sink = RabbitMQSink(channel, _get_queue_name(direction, call_uuid))
        self.push_notification_sink = RabbitMQSink(
            channel, PUSH_NOTIFICATIONS_QUEUE
        )
        self.source_impl = RabbitMQSource(
            channel, _get_queue_name(direction.opposite(), call_uuid)
        )

    async def push_notification_sink(self, call_init: IncomingCallInit):
        await self.push_notification_sink.send(call_init)

    async def sink(self, event: CallEvent):
        await self.sink.send(event)

    @property
    async def source(self):
        async for event in self.source_impl.listen():
            yield event
