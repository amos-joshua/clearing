from clearing_server.core.event_sinks import EventSinks
from clearing_server.core.model.events import CallEvent

class MockPushNotificationsSink:
    def __init__(self):
        self.events: list[CallEvent] = []

    async def __call__(self, event: CallEvent):
        self.events.append(event)


class MockCallEventSink:
    def __init__(self):
        self.events = []

    async def __call__(self, event: CallEvent):
        self.events.append(event)

class MockEventSinks(EventSinks):
    def __init__(self):
        self.mock_client_sink = MockCallEventSink()
        self.mock_message_broker_sink = MockCallEventSink()
        self.mock_push_notifications_sink = MockPushNotificationsSink()
        super().__init__(client_sink=self.mock_client_sink, message_broker_sink=self.mock_message_broker_sink, push_notifications_sink=self.mock_push_notifications_sink)