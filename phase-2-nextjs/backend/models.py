"""Database models and request/response schemas."""

from datetime import datetime
from typing import Optional

from pydantic import BaseModel, Field
from sqlmodel import Field as SQLField
from sqlmodel import SQLModel


# Database Models
class User(SQLModel, table=True):
    """User model (managed by Better Auth)."""

    __tablename__ = "users"

    id: str = SQLField(primary_key=True)
    email: str = SQLField(unique=True, index=True, max_length=255)
    name: Optional[str] = SQLField(default=None, max_length=255)
    password_hash: str = SQLField(max_length=255)
    created_at: datetime = SQLField(default_factory=datetime.utcnow)
    updated_at: datetime = SQLField(default_factory=datetime.utcnow)


class Task(SQLModel, table=True):
    """Task model."""

    __tablename__ = "tasks"

    id: Optional[int] = SQLField(default=None, primary_key=True)
    user_id: str = SQLField(foreign_key="users.id", index=True)
    title: str = SQLField(max_length=200)
    description: Optional[str] = SQLField(default=None)
    completed: bool = SQLField(default=False)
    priority: Optional[str] = SQLField(default=None, max_length=50)  # Low, Medium, High
    due_date: Optional[datetime] = SQLField(default=None)
    category: Optional[str] = SQLField(default=None, max_length=100)
    created_at: datetime = SQLField(default_factory=datetime.utcnow)
    updated_at: datetime = SQLField(default_factory=datetime.utcnow)


# Request/Response Models
class TaskCreate(BaseModel):
    """Request model for creating a task."""

    title: str = Field(min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)
    priority: Optional[str] = Field(default=None, max_length=50)
    due_date: Optional[datetime] = Field(default=None)
    category: Optional[str] = Field(default=None, max_length=100)

    def model_post_init(self, __context: object) -> None:
        """Strip whitespace from fields."""
        self.title = self.title.strip()
        if self.description:
            self.description = self.description.strip() or None
        if self.category:
            self.category = self.category.strip() or None


class TaskUpdate(BaseModel):
    """Request model for updating a task."""

    title: Optional[str] = Field(default=None, min_length=1, max_length=200)
    description: Optional[str] = Field(default=None, max_length=1000)
    priority: Optional[str] = Field(default=None, max_length=50)
    due_date: Optional[datetime] = Field(default=None)
    category: Optional[str] = Field(default=None, max_length=100)

    def model_post_init(self, __context: object) -> None:
        """Strip whitespace from fields."""
        if self.title:
            self.title = self.title.strip()
        if self.description:
            self.description = self.description.strip() or None
        if self.category:
            self.category = self.category.strip() or None


class TaskResponse(BaseModel):
    """Response model for task data."""

    id: int
    user_id: str
    title: str
    description: Optional[str]
    completed: bool
    priority: Optional[str]
    due_date: Optional[datetime]
    category: Optional[str]
    created_at: datetime
    updated_at: datetime


class Conversation(SQLModel, table=True):
    id: Optional[int] = SQLField(default=None, primary_key=True)
    user_id: str
    created_at: datetime = SQLField(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = SQLField(default_factory=datetime.utcnow, nullable=False)

class Message(SQLModel, table=True):
    id: Optional[int] = SQLField(default=None, primary_key=True)
    user_id: str
    conversation_id: int = SQLField(foreign_key="conversation.id")
    role: str  # "user" or "assistant"
    content: str
    created_at: datetime = SQLField(default_factory=datetime.utcnow, nullable=False)

class ChatRequest(BaseModel):
    message: str
    conversation_id: Optional[int] = None
    language: str = "en"

class ChatResponse(BaseModel):
    conversation_id: int
    response: str
    tool_calls: list[dict] = []


class TaskHistory(SQLModel, table=True):
    """Task history audit log model."""

    __tablename__ = "task_history"

    id: Optional[int] = SQLField(default=None, primary_key=True)
    task_id: int = SQLField(index=True)
    user_id: str = SQLField(index=True)
    action: str = SQLField(max_length=50)  # created, updated, deleted, completed, uncompleted
    field_name: Optional[str] = SQLField(default=None, max_length=100)
    old_value: Optional[str] = SQLField(default=None)
    new_value: Optional[str] = SQLField(default=None)
    changed_at: datetime = SQLField(default_factory=datetime.utcnow)


class TaskHistoryResponse(BaseModel):
    """Response model for task history data."""

    id: int
    task_id: int
    user_id: str
    action: str
    field_name: Optional[str]
    old_value: Optional[str]
    new_value: Optional[str]
    changed_at: datetime
