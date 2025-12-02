"""Task model and status enum."""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from uuid import uuid4


class TaskStatus(Enum):
    """Task completion status."""

    INCOMPLETE = "incomplete"
    COMPLETE = "complete"


@dataclass
class Task:
    """
    Represents a todo task.

    Attributes:
        id: Unique identifier (UUID)
        title: Task title (required, non-empty)
        description: Task description (optional)
        status: Completion status (default: INCOMPLETE)
        created_at: Creation timestamp
        updated_at: Last update timestamp
    """

    title: str
    description: str = ""
    status: TaskStatus = TaskStatus.INCOMPLETE
    id: str = field(default_factory=lambda: str(uuid4()))
    created_at: datetime = field(default_factory=datetime.now)
    updated_at: datetime = field(default_factory=datetime.now)

    def __post_init__(self) -> None:
        """Validate task data after initialization."""
        if not self.title or self.title.strip() == "":
            raise ValueError("Title cannot be empty")
