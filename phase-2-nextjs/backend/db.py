"""Database connection and session management."""

import os
from pathlib import Path
from typing import Generator

from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine

# Get the directory where this file is located
BASE_DIR = Path(__file__).resolve().parent

# 1. First, check if DATABASE_URL is already in system environment (Render)
DATABASE_URL = os.getenv("DATABASE_URL")

# 2. If not, try loading from .env file (Local)
if not DATABASE_URL:
    load_dotenv(dotenv_path=BASE_DIR / ".env")
    DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set")


# Create engine
engine = create_engine(DATABASE_URL, echo=True)


def init_db() -> None:
    """Create all database tables."""
    SQLModel.metadata.create_all(engine)


def get_session() -> Generator[Session, None, None]:
    """
    Get database session.

    Yields:
        Session: SQLModel database session
    """
    with Session(engine) as session:
        yield session
