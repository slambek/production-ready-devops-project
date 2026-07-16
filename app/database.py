import os

from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql+psycopg2://devops_user:change_me@localhost:5432/devops_db",
)

engine: Engine = create_engine(
    DATABASE_URL,
    pool_pre_ping=True,
)


def check_database_connection() -> bool:
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))

        return True
    except Exception:
        return False
