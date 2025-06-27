import asyncio

from clearing_server.push_notification_service.worker import (
    PushNotificationWorker,
)
from clearing_server.switchboard.switchboard_init import load_root_dependencies


def main():
    config, users, log = load_root_dependencies()
    worker = PushNotificationWorker(config, users, log)
    asyncio.run(worker.run())


if __name__ == "__main__":
    main()
