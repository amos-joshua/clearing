import os

import uvicorn

from clearing_server.switchboard.switchboard_init import load_config

config = load_config(quiet=True)


def serve():
    uvicorn.run(
        "clearing_server.switchboard_server.app:app",
        host=config.server_host,
        port=config.server_port,
        reload=config.is_dev_env,
    )


if __name__ == "__main__":
    serve()
