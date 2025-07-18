import traceback
from typing import AsyncGenerator

import aio_pika
from aiormq import AMQPConnectionError
from fastapi import Depends, FastAPI, Header, HTTPException, Query, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from starlette.responses import JSONResponse

from clearing_server.calls.errors import EXTERNALLY_VISIBLE_ERRORS
from clearing_server.calls.incoming.state_machine import (
    IncomingCallStateMachine,
)
from clearing_server.calls.outgoing.state_machine import (
    OutgoingCallStateMachine,
)
from clearing_server.core.model.config import ServerConfig
from clearing_server.core.model.events import ReceiverReject
from clearing_server.core.direction import CallDirection
from clearing_server.core.user_repository_base import UserRepositoryBase
from clearing_server.switchboard.session_error_handler import (
    SwitchboardErrorHandler,
)
from clearing_server.switchboard.session_factory import SessionFactory
from clearing_server.switchboard.websocket_channel import WebSocketChannel



def create_app(users: UserRepositoryBase, config: ServerConfig) -> FastAPI:
    app = FastAPI()

    app.add_middleware(
        CORSMiddleware,
        allow_origins=config.switchboard_cors_allowed,
        allow_credentials=True,
        allow_methods=["GET"],
        allow_headers=["*"],
    )

    async def get_mq_connection() -> (
        AsyncGenerator[aio_pika.RobustConnection, None]
    ):
        try:
            connection = await aio_pika.connect_robust(config.rabbit_mq_url)
        except Exception as exc:
            users.log.server_error(
                f"Could not connect to RabbitMQ server at {config.rabbit_mq_url}"
            )
            raise RuntimeError(
                f"Could not connect to RabbitMQ server at {config.rabbit_mq_url}"
            ) from exc
        try:
            yield connection
        finally:
            await connection.close()

    async def get_session_factory(
        connection: aio_pika.RobustConnection = Depends(get_mq_connection),
    ) -> SessionFactory:
        return SessionFactory(connection, users, config)

    async def verify_admin_auth(authorization: str = Header(None)):
        if not authorization:
            raise HTTPException(
                status_code=401, detail="Authorization header required"
            )

        if not authorization.startswith("Bearer "):
            raise HTTPException(
                status_code=401,
                detail="Authorization header must start with 'Bearer '",
            )

        token = authorization[7:]  # Remove "Bearer " prefix
        if not token:
            raise HTTPException(status_code=401, detail="Token is required")

        try:
            users.verify_admin_token(token)
        except Exception as exc:
            users.log.server_error(
                f"Authentication denied for admin endpoint: {exc}",
                exc,
                traceback.format_exc(),
            )
            raise HTTPException(
                status_code=403, detail="Invalid or insufficient permissions"
            )

    @app.get("/info")
    async def info(_: None = Depends(verify_admin_auth)):
        return config.model_dump()

    @app.get("/user/info")
    async def user_info(
        phone_number: str | None = Query(None, description="User's phone number"),
        uid: str | None = Query(None, description="User's Firebase UID"),
        _: None = Depends(verify_admin_auth),
    ):
        if phone_number is not None and uid is not None:
            raise HTTPException(
                status_code=400,
                detail="Only one of 'phone_number' or 'uid' parameter should be provided",
            )

        try:
            if phone_number is not None:
                user_info_dict = users.user_info_by_phone_number(phone_number)
            elif uid is not None:
                user_info_dict = users.user_info_by_uid(uid)
            else:
                raise HTTPException(
                    status_code=400,
                    detail="Either 'phone_number' or 'uid' parameter must be provided",
                )

            if user_info_dict is None:
                raise HTTPException(
                    status_code=404,
                    detail=f"User not found with {'phone_number' if phone_number else 'uid'}: {phone_number or uid}",
                )

            return user_info_dict

        except HTTPException:
            # Re-raise HTTP exceptions as-is
            raise
        except Exception as exc:
            users.log.server_error(
                f"Error retrieving user info for {'phone_number' if phone_number else 'uid'}: {phone_number or uid}",
                exc,
                traceback.format_exc(),
            )
            raise HTTPException(
                status_code=500,
                detail="Internal server error while retrieving user information",
            )

    state_machine_outgoing = OutgoingCallStateMachine()
    state_machine_incoming = IncomingCallStateMachine()
    switchboard_error_handler = SwitchboardErrorHandler(config, users.log)

    @app.websocket("/call/{call_uuid}")
    async def call_endpoint(
        websocket: WebSocket,
        call_uuid: str,
        session_factory: SessionFactory = Depends(get_session_factory),
        debug: bool = Query(False, description="Debug mode (increased server-side logging)"),
    ):
        try:
            await websocket.accept()
            call, session = await session_factory.outgoing(websocket, call_uuid, debug)
            await session.run(call, state_machine_outgoing)
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            await switchboard_error_handler.handle_externally_visible_exception(
                websocket, call_uuid, exc
            )
        except Exception as exc:
            await switchboard_error_handler.handle_server_error(
                websocket, call_uuid, exc
            )
        finally:
            await WebSocketChannel.close_websocket(websocket)

    @app.websocket("/answer/{call_uuid}")
    async def answer(
        websocket: WebSocket,
        call_uuid: str,
        session_factory: SessionFactory = Depends(get_session_factory),
        debug: bool = Query(False, description="Debug mode (increased server-side logging)"),
    ):
        try:
            await websocket.accept()
            call, session = await session_factory.incoming(websocket, call_uuid, debug)
            await session.run(call, state_machine_incoming)
        except EXTERNALLY_VISIBLE_ERRORS as exc:
            await switchboard_error_handler.handle_externally_visible_exception(
                websocket, call_uuid, exc
            )
        except Exception as exc:
            await switchboard_error_handler.handle_server_error(
                websocket, call_uuid, exc
            )
        finally:
            await WebSocketChannel.close_websocket(websocket)

    @app.post("/reject/{call_uuid}")
    async def reject(
        event: ReceiverReject,
        call_uuid: str,
        session_factory: SessionFactory = Depends(get_session_factory),
        debug: bool = Query(False, description="Debug mode (increased server-side logging)"),
    ):
        call = await session_factory.incoming_reject(call_uuid, debug)
        result = await state_machine_incoming.process_directed_event(
            call, (CallDirection.RECEIVER, event)
        )
        if result:
            return JSONResponse(
                status_code=400,
                content={
                    "error": type(result).__name__,
                    "message": str(result),
                },
            )
        return {"status": "ok"}

    return app
