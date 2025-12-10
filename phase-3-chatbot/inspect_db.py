from sqlalchemy import create_engine, inspect
from backend.models import Task

engine = create_engine("sqlite:///./database.db")
inspector = inspect(engine)
columns = [col['name'] for col in inspector.get_columns('task')]
print("Task Columns:", columns)
