"""Database connection and session management."""

import os
from typing import Generator

from dotenv import load_dotenv
from sqlmodel import Session, SQLModel, create_engine

# Load environment variables
load_dotenv()

# Get database URL from environment
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
