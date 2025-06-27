from clearing_server.switchboard.rest_api import create_app
from clearing_server.switchboard.switchboard_init import load_root_dependencies

config, users, _ = load_root_dependencies()
app = create_app(users, config)
