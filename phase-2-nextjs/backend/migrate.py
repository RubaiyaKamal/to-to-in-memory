"""Add new columns to tasks table."""

import os
from pathlib import Path

from dotenv import load_dotenv
from sqlalchemy import create_engine, text

# Get the directory where this file is located
BASE_DIR = Path(__file__).resolve().parent

# Load environment variables from .env file in the same directory
env_path = BASE_DIR / ".env"
load_dotenv(dotenv_path=env_path)

# Get database URL from environment
DATABASE_URL = os.getenv("DATABASE_URL")
if not DATABASE_URL:
    raise ValueError("DATABASE_URL environment variable is not set")

# Create engine
engine = create_engine(DATABASE_URL)

# SQL to add new columns
migration_sql = """
ALTER TABLE tasks
ADD COLUMN IF NOT EXISTS priority VARCHAR(50),
ADD COLUMN IF NOT EXISTS due_date TIMESTAMP,
ADD COLUMN IF NOT EXISTS category VARCHAR(100);
"""

print("Running migration to add new columns to tasks table...")
with engine.connect() as conn:
    conn.execute(text(migration_sql))
    conn.commit()
    print("✓ Migration completed successfully!")
    print("  - Added column: priority (VARCHAR 50)")
    print("  - Added column: due_date (TIMESTAMP)")
    print("  - Added column: category (VARCHAR 100)")
