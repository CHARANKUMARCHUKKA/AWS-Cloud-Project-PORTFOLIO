from pathlib import Path

from alembic import command
from alembic.config import Config
from sqlalchemy import create_engine, inspect


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def migration_config(database_url: str) -> Config:
    config = Config(str(PROJECT_ROOT / "alembic.ini"))
    config.set_main_option("script_location", str(PROJECT_ROOT / "migrations"))
    config.set_main_option("sqlalchemy.url", database_url)
    return config


def test_initial_migration_matches_task_schema(tmp_path):
    database_path = tmp_path / "migration-test.db"
    database_url = f"sqlite:///{database_path.as_posix()}"

    command.upgrade(migration_config(database_url), "head")

    inspector = inspect(create_engine(database_url))
    columns = {column["name"]: column for column in inspector.get_columns("tasks")}

    assert set(columns) == {"id", "title", "completed"}
    assert columns["id"]["primary_key"] == 1
    assert columns["id"]["nullable"] is False
    assert columns["title"]["type"].length == 200
    assert columns["title"]["nullable"] is False
    assert columns["completed"]["nullable"] is False
    assert columns["completed"]["default"] is None
    assert {index["name"] for index in inspector.get_indexes("tasks")} == {"ix_tasks_id"}
