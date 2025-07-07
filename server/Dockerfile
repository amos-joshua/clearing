FROM python:3.12-slim AS builder

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl build-essential gcc libffi-dev libpq-dev \
    && rm -rf /var/lib/apt/lists/*

RUN curl -sSL https://install.python-poetry.org | python3 - && \
    /root/.local/bin/poetry self update 2.0.1 && \
    ln -s /root/.local/bin/poetry /usr/local/bin/poetry

COPY pyproject.toml poetry.lock /app/

COPY . /app
RUN poetry config virtualenvs.create false && \
    poetry install --no-interaction --no-ansi




FROM python:3.12-slim AS runtime

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1
WORKDIR /app

COPY --from=builder /usr/local/lib/python3.12 /usr/local/lib/python3.12
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /app /app


FROM runtime AS clearing-switchboard

ENV CLEARING_WEB_WORKERS=1
CMD ["sh", "-c", "uvicorn clearing_server.switchboard_server.app:app --host 0.0.0.0 --port 8175 --workers ${CLEARING_WEB_WORKERS}"]

FROM runtime AS clearing-push-notification-service
CMD ["sh", "-c", "python -m clearing_server.push_notification_service.service"]
