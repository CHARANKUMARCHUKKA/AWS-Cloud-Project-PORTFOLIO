import os

from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

DATABASE_URL = (
    f"mysql+pymysql://{os.environ['MYSQL_USER']}:"
    f"{os.environ['MYSQL_PASSWORD']}@mysql:3306/"
    f"{os.environ['MYSQL_DATABASE']}"
)

engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)

SessionLocal = sessionmaker(
    bind=engine,
    autoflush=False,
    autocommit=False,
)


class Base(DeclarativeBase):
    pass
