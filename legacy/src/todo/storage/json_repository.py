"""JSON file-based implementation of TaskRepository."""

import json
import os
from datetime import datetime
from typing import Any

from todo.models.task import Task, TaskStatus
from todo.storage.repository import TaskRepository


class JsonTaskRepository(TaskRepository):
    """Repository that persists tasks to a JSON file."""

    def __init__(self, file_path: str = "tasks.json") -> None:
        """
        Initialize the repository.

        Args:
            file_path: Path to the JSON file for storage
        """
        self._file_path = file_path
        self._tasks: dict[str, Task] = {}
        self._load()

    def _serialize_task(self, task: Task) -> dict[str, Any]:
        """Convert a Task object to a dictionary."""
        return {
            "id": task.id,
            "title": task.title,
            "description": task.description,
            "status": task.status.value,
            "created_at": task.created_at.isoformat(),
            "updated_at": task.updated_at.isoformat(),
        }

    def _deserialize_task(self, data: dict[str, Any]) -> Task:
        """Convert a dictionary to a Task object."""
        return Task(
            id=data["id"],
            title=data["title"],
            description=data["description"],
            status=TaskStatus(data["status"]),
            created_at=datetime.fromisoformat(data["created_at"]),
            updated_at=datetime.fromisoformat(data["updated_at"]),
        )

    def _save(self) -> None:
        """Save tasks to the JSON file."""
        data = [self._serialize_task(task) for task in self._tasks.values()]
        with open(self._file_path, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def _load(self) -> None:
        """Load tasks from the JSON file."""
        if not os.path.exists(self._file_path):
            return

        try:
            with open(self._file_path, encoding="utf-8") as f:
                data = json.load(f)
                for item in data:
                    try:
                        task = self._deserialize_task(item)
                        self._tasks[task.id] = task
                    except (ValueError, KeyError):
                        # Skip malformed tasks
                        continue
        except json.JSONDecodeError:
            # If file is corrupted, start with empty state
            # In a production app, we might want to backup the corrupted file
            pass

    def add(self, task: Task) -> Task:
        """Add a task to the repository."""
        self._tasks[task.id] = task
        self._save()
        return task

    def get(self, task_id: str) -> Task | None:
        """Get a task by ID."""
        return self._tasks.get(task_id)

    def get_all(self) -> list[Task]:
        """Get all tasks."""
        return list(self._tasks.values())

    def update(self, task: Task) -> Task:
        """Update an existing task."""
        if task.id not in self._tasks:
            raise KeyError(f"Task with ID {task.id} not found")
        self._tasks[task.id] = task
        self._save()
        return task

    def delete(self, task_id: str) -> bool:
        """Delete a task by ID."""
        if task_id in self._tasks:
            del self._tasks[task_id]
            self._save()
            return True
        return False
