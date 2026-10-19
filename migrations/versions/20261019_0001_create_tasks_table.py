"""Create the tasks table.

Revision ID: 20261019_0001
Revises:
Create Date: 2026-10-19 00:00:00
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "20261019_0001"
down_revision: str | None = None
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    op.create_table(
        "tasks",
        sa.Column("id", sa.Integer(), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("completed", sa.Boolean(), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_tasks_id", "tasks", ["id"], unique=False)


def downgrade() -> None:
    op.drop_index("ix_tasks_id", table_name="tasks")
    op.drop_table("tasks")
