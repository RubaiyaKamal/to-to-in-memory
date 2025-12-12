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

    class Config:
        """Pydantic config."""

        from_attributes = True
