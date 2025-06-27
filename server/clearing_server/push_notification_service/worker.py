import asyncio
import traceback

import aio_pika
from aio_pika.abc import AbstractRobustConnection

from clearing_server.core.log_base import LogBase
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.user_repository_base import UserRepositoryBase
from clearing_server.message_queues.rabbitmq_call_channel import (
    PUSH_NOTIFICATIONS_QUEUE,
    RabbitMQSource,
)
from clearing_server.push_notification_service.processor import (
    PushNotificationProcessor,
)


class PushNotificationWorker:
    MAX_RECONNECT_ATTEMPTS = 5
    RECONNECT_WINDOW = 30  # seconds
    RECONNECT_DELAY = 3  # seconds

    def __init__(
        self,
        config: ServerConfig,
        user_repository: UserRepositoryBase,
        log: LogBase,
    ):
        self.config = config
        self.log = log
        self.processor = PushNotificationProcessor(
            user_repository,
            log,
            sender_max_device_tokens_per_call=config.sender_max_device_tokens_per_call,
        )
        self._reconnect_attempts = (
            []
        )  # List of timestamps of reconnection attempts

    def _can_reconnect(self) -> bool:
        """Check if we can attempt another reconnection based on recent attempts."""
        now = asyncio.get_event_loop().time()
        # Remove attempts older than RECONNECT_WINDOW
        self._reconnect_attempts = [
            t
            for t in self._reconnect_attempts
            if now - t < self.RECONNECT_WINDOW
        ]
        return len(self._reconnect_attempts) < self.MAX_RECONNECT_ATTEMPTS

    async def connect(self) -> AbstractRobustConnection:
        """Establish connection to RabbitMQ."""
        try:
            connection = await aio_pika.connect_robust(self.config.rabbit_mq_url)
            return connection
        except Exception as exc:
            self.log.push_notification_error(
                f"Failed to connect to RabbitMQ: {exc}",
                exc,
                traceback.format_exc(),
            )
            raise

    async def run(self):
        """Main worker loop."""
        while True:  # Add reconnection loop
            try:
                print(f"Connecting to RabbitMQ {self.config.rabbit_mq_url}...")
                connection = await self.connect()
                channel = await connection.channel()
                print(f"Connected")
                source = RabbitMQSource(channel, PUSH_NOTIFICATIONS_QUEUE)
                self._reconnect_attempts = []

                try:
                    async for event in source.listen():
                        await self.processor.process_event(event)
                except aio_pika.exceptions.QueueEmpty as exc:
                    self.log.push_notification_error(
                        "Queue was deleted while consuming",
                        exc,
                        traceback.format_exc(),
                    )
                except aio_pika.exceptions.ChannelClosed as exc:
                    self.log.push_notification_error(
                        "RabbitMQ channel was closed",
                        exc,
                        traceback.format_exc(),
                    )
                    raise  # Trigger reconnection
                except aio_pika.exceptions.ConnectionClosed as exc:
                    self.log.push_notification_error(
                        "RabbitMQ connection was closed",
                        exc,
                        traceback.format_exc(),
                    )
                    raise  # Trigger reconnection
                except Exception as exc:
                    self.log.push_notification_error(
                        f"Unexpected error while processing messages: {exc}",
                        exc,
                        traceback.format_exc(),
                    )
                    raise  # Trigger reconnection
                finally:
                    await connection.close()
            except Exception as exc:
                if not self._can_reconnect():
                    self.log.push_notification_error(
                        f"Aborting after {self.MAX_RECONNECT_ATTEMPTS} reconnection attempts in {self.RECONNECT_WINDOW}s",
                        exc,
                        traceback.format_exc(),
                    )
                    return  # Exit the worker loop

                self._reconnect_attempts.append(asyncio.get_event_loop().time())
                await asyncio.sleep(self.RECONNECT_DELAY)
                continue
