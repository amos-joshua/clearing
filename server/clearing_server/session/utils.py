import asyncio


async def cancel_and_await(task: asyncio.Task | None):
    if task:
        task.cancel()
        try:
            await task
        except asyncio.CancelledError:
            pass
