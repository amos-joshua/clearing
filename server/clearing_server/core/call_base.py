from .call_identifiable import CallIdentifiable
from .context import CallContext
from .direction import CallDirection
from .model.events import CallEvent


class CallBase(CallIdentifiable):
    def __init__(
        self,
        uuid: str,
        direction: CallDirection,
        context: CallContext,
    ):
        super().__init__(uuid, direction)
        self.context = context

    def is_in_final_state(self) -> bool:
        raise NotImplemented()

    def message_broker_sink(self, event: CallEvent):
        self.context.log.outgoing_event(
            self, dest_queue="message_broker", event=type(event).__name__
        )
        return self.context.sinks.message_broker_sink(event)

    def client_sink(self, event: CallEvent):
        self.context.log.outgoing_event(
            self, dest_queue="client", event=type(event).__name__
        )
        return self.context.sinks.client_sink(event)

    def push_notifications_sink(self, event: CallEvent):
        self.context.log.outgoing_event(
            self, dest_queue="push_notification", event=type(event).__name__
        )
        return self.context.sinks.push_notifications_sink(event)

    async def close(self):
        pass

    def load_state(self):
        raise NotImplemented()

    def verify_valid_init_state(self):
        raise NotImplemented()
