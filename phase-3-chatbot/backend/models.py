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

class ChatResponse(SQLModel):
    conversation_id: int
    response: str
    tool_calls: List[dict] = []
