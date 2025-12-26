import os
from sqlalchemy import create_engine, text

# Use the exact string provided by the user
DATABASE_URL = "postgresql://neondb_owner:npg_1BgzXWJx9TeM@ep-holy-voice-a50d2u4k.us-east-2.aws.neon.tech/neondb?sslmode=require"

print(f"Testing Database Connection: {DATABASE_URL.split('@')[1] if '@' in DATABASE_URL else 'INVALID_FORMAT'}")

try:
    engine = create_engine(DATABASE_URL)
    with engine.connect() as connection:
        result = connection.execute(text("SELECT 1"))
        print("SUCCESS: Database connection established!")
except Exception as e:
    print(f"FAILURE: {e}")
