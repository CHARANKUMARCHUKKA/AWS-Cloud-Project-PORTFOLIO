FROM python:3.12-slim AS dependency-builder

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

RUN python -m venv "$VIRTUAL_ENV"

COPY requirements/runtime.txt requirements/constraints.txt ./requirements/
RUN pip install --requirement requirements/runtime.txt


FROM dependency-builder AS migration-builder

COPY requirements/migrations.txt ./requirements/migrations.txt
RUN pip install --requirement requirements/migrations.txt


FROM python:3.12-slim AS migration

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

COPY --from=migration-builder "$VIRTUAL_ENV" "$VIRTUAL_ENV"
RUN groupadd --system --gid 10001 appuser \
    && useradd --system --uid 10001 --gid appuser --no-create-home appuser

COPY --chown=appuser:appuser alembic.ini ./
COPY --chown=appuser:appuser migrations/ ./migrations/
COPY --chown=appuser:appuser app/ ./app/

USER appuser:appuser

CMD ["alembic", "upgrade", "head"]


FROM python:3.12-slim AS runtime

ENV VIRTUAL_ENV=/opt/venv \
    PATH="/opt/venv/bin:$PATH" \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

RUN groupadd --system --gid 10001 appuser \
    && useradd --system --uid 10001 --gid appuser --no-create-home appuser

WORKDIR /app

COPY --from=dependency-builder "$VIRTUAL_ENV" "$VIRTUAL_ENV"
COPY --chown=appuser:appuser app/ ./app/

USER appuser:appuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD python -c "import urllib.request; urllib.request.urlopen('http://127.0.0.1:8000/health', timeout=2)" || exit 1

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
