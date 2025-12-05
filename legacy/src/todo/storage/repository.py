"""Task repository interface and in-memory implementation."""

from abc import ABC, abstractmethod

from todo.models.task import Task


class TaskRepository(ABC):
    """Abstract base class for task storage."""

    @abstractmethod
    def add(self, task: Task) -> Task:
        """
        Add a task to the repository.

        Args:
            task: Task to add

        Returns:
            The added task
        """
        pass

    @abstractmethod
    def get(self, task_id: str) -> Task | None:
        """
        Get a task by ID.

        Args:
            task_id: Task ID to retrieve

        Returns:
            Task if found, None otherwise
        """
        pass

    @abstractmethod
    def get_all(self) -> list[Task]:
        """
        Get all tasks.

        Returns:
            List of all tasks
        """
        pass

    @abstractmethod
    def update(self, task: Task) -> Task:
        """
        Update an existing task.

        Args:
            task: Task with updated data

        Returns:
            The updated task

        Raises:
            KeyError: If task with given ID doesn't exist
        """
        pass

    @abstractmethod
    def delete(self, task_id: str) -> bool:
        """
        Delete a task by ID.

        Args:
            task_id: Task ID to delete

        Returns:
            True if task was deleted, False if not found
        """
        pass


class InMemoryTaskRepository(TaskRepository):
    """In-memory implementation of TaskRepository."""

    def __init__(self) -> None:
        """Initialize the repository with empty storage."""
        self._tasks: dict[str, Task] = {}

    def add(self, task: Task) -> Task:
        """Add a task to the repository."""
        self._tasks[task.id] = task
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
        return task

    def delete(self, task_id: str) -> bool:
        """Delete a task by ID."""
        if task_id in self._tasks:
            del self._tasks[task_id]
            return True
        return False
