import traceback

from firebase_admin import messaging

from clearing_server.core.log_base import LogBase
from clearing_server.core.model.events import CallEvents, IncomingCallInit
from clearing_server.core.user_repository_base import UserRepositoryBase


class PushNotificationProcessor:

    def __init__(
        self,
        user_repository: UserRepositoryBase,
        log: LogBase,
        sender_max_device_tokens_per_call: int,
    ):
        self.user_repository = user_repository
        self.log = log
        self.sender_max_device_tokens_per_call = (
            sender_max_device_tokens_per_call
        )

    async def process_event(self, event: CallEvents) -> None:
        """Process an incoming event."""
        try:
            if not isinstance(event, IncomingCallInit):
                self.log.push_notification_error(
                    f"Received non-IncomingCallInit event: {type(event)}"
                )
                return

            device_token_ids = event.receiver_device_token_ids
            if len(device_token_ids) == 0:
                self.log.push_notification_error(
                    f"IncomingCallInit for {event.caller_email} has no device token ids"
                )
                return

            if len(device_token_ids) > self.sender_max_device_tokens_per_call:
                self.log.push_notification_error(
                    f"IncomingCallInit for {event.caller_email} has more than {self.sender_max_device_tokens_per_call} device token ids, limiting to first {self.sender_max_device_tokens_per_call} tokens"
                )
                event.receiver_device_token_ids = device_token_ids[
                    : self.sender_max_device_tokens_per_call
                ]

            await self.send_push_notification(event)

        except Exception as e:
            self.log.push_notification_error(
                f"Error processing event: {e}\n{traceback.format_exc()}",
                e,
                traceback.format_exc(),
            )

    async def send_push_notification(self, event: IncomingCallInit):
        """Send push notification using Firebase Cloud Messaging."""
        try:
            data = event.model_dump()
            del data["receiver_device_token_ids"]

            message = messaging.MulticastMessage(
                data=data,
                tokens=event.receiver_device_token_ids,
                android=messaging.AndroidConfig(priority="high"),
            )

            batch_response = await messaging.send_each_for_multicast_async(
                message
            )
            if batch_response.failure_count > 0:
                for response in batch_response.responses:
                    self.log.push_notification_error(
                        f"Failed to send push notification for {event.caller_email}, got exception for message {response.message_id}: {response.exception}"
                    )
            else:
                self.log.push_notification_debug(
                    f"Sent push notification to {len(event.receiver_device_token_ids)} devices"
                )

        except Exception as exc:
            self.log.push_notification_error(
                f"Failed to send push notification for {event.caller_email}: {exc}",
                exc,
                traceback.format_exc(),
            )
