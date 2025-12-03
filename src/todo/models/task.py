"""Task model for the todo application."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional
from uuid import uuid4


class TaskStatus(Enum):
    """Task status enumeration."""

    INCOMPLETE = "incomplete"
    COMPLETE = "complete"


@dataclass
class Task:
    """Task model representing a todo item."""

    title: str
    description: str = ""
    status: TaskStatus = TaskStatus.INCOMPLETE
    id: str = field(default_factory=lambda: str(uuid4()))
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)

    def __post_init__(self) -> None:
        """Validate task data after initialization."""
        if not self.title or not self.title.strip():
            raise ValueError("Title cannot be empty")
