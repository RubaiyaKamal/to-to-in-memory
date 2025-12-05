# Backend Guidelines

## Stack
- **Framework**: FastAPI
- **ORM**: SQLModel (combines SQLAlchemy + Pydantic)
- **Database**: Neon Serverless PostgreSQL
- **Authentication**: JWT token verification
- **Server**: Uvicorn (ASGI)
- **Language**: Python 3.13+
- **Package Manager**: UV

## Project Structure
```
backend/
├── main.py              # FastAPI app entry point
├── models.py            # SQLModel database models
├── db.py                # Database connection and session
├── auth.py              # JWT verification middleware
├── routes/              # API route handlers
│   ├── __init__.py
│   ├── tasks.py        # Task CRUD endpoints
│   └── health.py       # Health check endpoint
├── tests/               # Test files
│   ├── test_auth.py
│   ├── test_tasks.py
│   └── test_db.py
├── .env                 # Environment variables (not committed)
├── .env.example         # Environment variables template
├── pyproject.toml       # UV project configuration
└── README.md
```

## FastAPI Patterns

### Application Setup
```python
# main.py
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from routes import tasks, health
from db import init_db
import os

app = FastAPI(title="Todo API", version="1.0.0")

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=os.getenv("CORS_ORIGINS", "http://localhost:3000").split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router)
app.include_router(tasks.router, prefix="/api")

@app.on_event("startup")
def on_startup():
    init_db()
```

### Route Handlers
```python
# routes/tasks.py
from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select
from db import get_session
from models import Task, TaskCreate, TaskUpdate, TaskResponse
from auth import verify_jwt

router = APIRouter()

@router.get("/{user_id}/tasks", response_model=list[TaskResponse])
def get_tasks(
    user_id: str,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt)
):
    # Verify user_id matches authenticated user
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Query tasks for user
    statement = select(Task).where(Task.user_id == user_id).order_by(Task.created_at.desc())
    tasks = session.exec(statement).all()
    return tasks

@router.post("/{user_id}/tasks", response_model=TaskResponse, status_code=201)
def create_task(
    user_id: str,
    task_data: TaskCreate,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt)
):
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    task = Task(user_id=user_id, **task_data.model_dump())
    session.add(task)
    session.commit()
    session.refresh(task)
    return task
```

## SQLModel Usage

### Database Models
```python
# models.py
from sqlmodel import SQLModel, Field
from datetime import datetime
from typing import Optional

class Task(SQLModel, table=True):
    __tablename__ = "tasks"

    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str = Field(foreign_key="users.id", index=True)
    title: str = Field(max_length=200)
    description: Optional[str] = Field(default=None)
    completed: bool = Field(default=False)
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)
```

### Request/Response Models
```python
# models.py
from pydantic import BaseModel, Field

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)

class TaskUpdate(BaseModel):
    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)

class TaskResponse(BaseModel):
    id: int
    user_id: str
    title: str
    description: Optional[str]
    completed: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True
```

### Database Connection
```python
# db.py
from sqlmodel import SQLModel, create_engine, Session
import os

DATABASE_URL = os.getenv("DATABASE_URL")
engine = create_engine(DATABASE_URL, echo=True)

def init_db():
    """Create all tables"""
    SQLModel.metadata.create_all(engine)

def get_session():
    """Get database session (dependency)"""
    with Session(engine) as session:
        yield session
```

## JWT Authentication

### JWT Verification
```python
# auth.py
from jose import jwt, JWTError
from fastapi import HTTPException, Header
import os

SECRET_KEY = os.getenv("BETTER_AUTH_SECRET")
ALGORITHM = "HS256"

def verify_jwt(authorization: str = Header(...)) -> str:
    """
    Verify JWT token and return user_id.

    Args:
        authorization: Authorization header (Bearer <token>)

    Returns:
        user_id: Authenticated user ID

    Raises:
        HTTPException: 401 if token is invalid or missing
    """
    try:
        # Extract token from "Bearer <token>"
        if not authorization.startswith("Bearer "):
            raise HTTPException(status_code=401, detail="Invalid authorization header")

        token = authorization.replace("Bearer ", "")

        # Decode and verify JWT
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")

        if user_id is None:
            raise HTTPException(status_code=401, detail="Invalid token payload")

        return user_id

    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
```

### Using JWT in Routes
```python
from auth import verify_jwt

@router.get("/{user_id}/tasks")
def get_tasks(
    user_id: str,
    authenticated_user_id: str = Depends(verify_jwt)  # Automatically verifies JWT
):
    # Ensure user_id in path matches authenticated user
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Proceed with logic
    ...
```

## Error Handling

### HTTP Exceptions
```python
from fastapi import HTTPException

# 400 Bad Request
raise HTTPException(status_code=400, detail="Title is required")

# 401 Unauthorized
raise HTTPException(status_code=401, detail="Invalid token")

# 403 Forbidden
raise HTTPException(status_code=403, detail="Forbidden")

# 404 Not Found
raise HTTPException(status_code=404, detail="Task not found")

# 500 Internal Server Error (automatically handled by FastAPI)
```

### Custom Exception Handler
```python
# main.py
from fastapi import Request
from fastapi.responses import JSONResponse

@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"}
    )
```

## Validation

### Pydantic Validation
```python
from pydantic import BaseModel, Field, validator

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)

    @validator("title")
    def title_must_not_be_empty(cls, v):
        if not v.strip():
            raise ValueError("Title cannot be empty")
        return v.strip()

    @validator("description")
    def description_strip(cls, v):
        if v is not None and not v.strip():
            return None
        return v.strip() if v else None
```

### Database Constraints
- Use SQLModel Field constraints (max_length, foreign_key, etc.)
- Database enforces constraints (NOT NULL, UNIQUE, FOREIGN KEY)
- Application validates before database operations

## Testing

### Test Structure
```python
# tests/test_tasks.py
import pytest
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_create_task():
    response = client.post(
        "/api/user-123/tasks",
        json={"title": "Test Task", "description": "Test Description"},
        headers={"Authorization": "Bearer valid-jwt-token"}
    )
    assert response.status_code == 201
    assert response.json()["title"] == "Test Task"

def test_create_task_unauthorized():
    response = client.post(
        "/api/user-123/tasks",
        json={"title": "Test Task"}
    )
    assert response.status_code == 401
```

### Running Tests
```bash
# Run all tests
uv run pytest -v

# Run with coverage
uv run pytest -v --cov=. --cov-report=term-missing

# Run specific test file
uv run pytest tests/test_tasks.py -v
```

## Environment Variables

### Required Variables
```bash
# .env
DATABASE_URL=postgresql://user:password@host.neon.tech/dbname?sslmode=require
BETTER_AUTH_SECRET=your-secret-key-min-32-chars-same-as-frontend
CORS_ORIGINS=http://localhost:3000,https://yourdomain.com
```

### Usage
```python
import os

DATABASE_URL = os.getenv("DATABASE_URL")
SECRET_KEY = os.getenv("BETTER_AUTH_SECRET")
CORS_ORIGINS = os.getenv("CORS_ORIGINS", "http://localhost:3000").split(",")
```

## Database Operations

### Create
```python
task = Task(user_id=user_id, title="New Task", completed=False)
session.add(task)
session.commit()
session.refresh(task)  # Get auto-generated ID and timestamps
```

### Read
```python
# Get all tasks for user
statement = select(Task).where(Task.user_id == user_id)
tasks = session.exec(statement).all()

# Get specific task
task = session.get(Task, task_id)
if not task or task.user_id != user_id:
    raise HTTPException(status_code=404, detail="Task not found")
```

### Update
```python
task = session.get(Task, task_id)
if not task or task.user_id != user_id:
    raise HTTPException(status_code=404, detail="Task not found")

task.title = "Updated Title"
task.updated_at = datetime.utcnow()
session.add(task)
session.commit()
session.refresh(task)
```

### Delete
```python
task = session.get(Task, task_id)
if not task or task.user_id != user_id:
    raise HTTPException(status_code=404, detail="Task not found")

session.delete(task)
session.commit()
```

## API Documentation

FastAPI automatically generates interactive API documentation:

- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc
- **OpenAPI JSON**: http://localhost:8000/openapi.json

## Running the Application

### Development
```bash
# Install dependencies
uv sync --dev

# Run with hot reload
uv run uvicorn main:app --reload --port 8000

# Run with specific host
uv run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

### Production
```bash
# Install production dependencies only
uv sync

# Run with multiple workers
uv run uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

## Common Patterns

### User Isolation
**Always** filter queries by authenticated user_id:
```python
# ✅ Correct
statement = select(Task).where(Task.user_id == authenticated_user_id)

# ❌ Wrong - returns all users' tasks
statement = select(Task)
```

### Timestamp Updates
Update `updated_at` on modifications:
```python
from datetime import datetime

task.title = new_title
task.updated_at = datetime.utcnow()
session.commit()
```

### Response Models
Always use response models for type safety:
```python
@router.get("/tasks", response_model=list[TaskResponse])
def get_tasks(...):
    return tasks  # Automatically validated and serialized
```

## Debugging

### Enable SQL Logging
```python
# db.py
engine = create_engine(DATABASE_URL, echo=True)  # Logs all SQL queries
```

### Common Issues

**Issue**: "Invalid token" errors
- **Solution**: Verify `BETTER_AUTH_SECRET` matches frontend
- **Solution**: Check token format (must be "Bearer <token>")
- **Solution**: Verify token hasn't expired

**Issue**: Database connection errors
- **Solution**: Check `DATABASE_URL` format
- **Solution**: Verify Neon database is accessible
- **Solution**: Check SSL mode (`?sslmode=require`)

**Issue**: CORS errors
- **Solution**: Add frontend URL to `CORS_ORIGINS`
- **Solution**: Verify CORS middleware is configured

## Best Practices

1. **Always verify JWT** - Use `Depends(verify_jwt)` on protected routes
2. **Always check user ownership** - Verify `user_id` matches authenticated user
3. **Use Pydantic models** - Validate all inputs
4. **Use SQLModel** - Never write raw SQL
5. **Handle errors gracefully** - Return appropriate HTTP status codes
6. **Log important events** - Use Python logging module
7. **Write tests** - Test all endpoints and edge cases
8. **Use type hints** - Enable static type checking with mypy
9. **Keep routes thin** - Move business logic to separate functions
10. **Document endpoints** - Use FastAPI docstrings for auto-documentation
