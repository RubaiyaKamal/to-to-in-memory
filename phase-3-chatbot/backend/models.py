from typing import Optional, List
from datetime import datetime
from sqlmodel import Field, SQLModel

class Task(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str
    title: str
    description: Optional[str] = None
    priority: Optional[str] = "medium" # low, medium, high
    due_date: Optional[str] = None
    category: Optional[str] = "general" # work, personal, etc.
    completed: bool = False
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

class Conversation(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

class Message(SQLModel, table=True):
    id: Optional[int] = Field(default=None, primary_key=True)
    user_id: str
    conversation_id: int = Field(foreign_key="conversation.id")
    role: str  # "user" or "assistant"
    content: str
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

class ChatRequest(SQLModel):
    message: str
    conversation_id: Optional[int] = None
    language: str = "en"

class ChatResponse(SQLModel):
    conversation_id: int
    response: str
    tool_calls: List[dict] = []

class TaskHistory(SQLModel, table=True):
    """Task history audit log model."""
    __tablename__ = "task_history"

    id: Optional[int] = Field(default=None, primary_key=True)
    task_id: int = Field(index=True)
    user_id: str = Field(index=True)
    action: str = Field(max_length=50)  # created, updated, deleted, completed, uncompleted
    field_name: Optional[str] = Field(default=None, max_length=100)
    old_value: Optional[str] = Field(default=None)
    new_value: Optional[str] = Field(default=None)
    changed_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
