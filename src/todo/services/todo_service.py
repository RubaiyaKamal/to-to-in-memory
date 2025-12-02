"""TodoService - Business logic for todo operations."""

from datetime import datetime

from todo.models.task import Task, TaskStatus
from todo.storage.repository import TaskRepository


class TodoService:
    """Service layer for todo operations."""

    def __init__(self, repository: TaskRepository) -> None:
        """
        Initialize TodoService with a repository.

        Args:
            repository: TaskRepository implementation for data storage
        """
        self._repository = repository

    def add_task(self, title: str, description: str = "") -> Task:
        """
        Add a new task.

        Args:
            title: Task title (required, non-empty)
            description: Task description (optional)

        Returns:
            The created task

        Raises:
            ValueError: If title is empty
        """
        task = Task(title=title, description=description)
        return self._repository.add(task)

    def list_tasks(self) -> list[Task]:
        """
        Get all tasks.

        Returns:
            List of all tasks
        """
        return self._repository.get_all()

    def get_task(self, task_id: str) -> Task:
        """
        Get a task by ID.

        Args:
            task_id: Task ID to retrieve

        Returns:
            The requested task

        Raises:
            ValueError: If task not found
        """
        task = self._repository.get(task_id)
        if task is None:
            raise ValueError(f"Task with ID {task_id} not found")
        return task

    def update_task(
        self,
        task_id: str,
        title: str | None = None,
        description: str | None = None
    ) -> Task:
        """
        Update a task's title and/or description.

        Args:
            task_id: Task ID to update
            title: New title (optional)
            description: New description (optional)

        Returns:
            The updated task

        Raises:
            ValueError: If task not found or title is empty
        """
        task = self.get_task(task_id)

        # Update fields if provided
        new_title = title if title is not None else task.title
        new_description = description if description is not None else task.description

        # Create updated task with new timestamp
        updated_task = Task(
            title=new_title,
            description=new_description,
            status=task.status,
            id=task.id,
            created_at=task.created_at,
            updated_at=datetime.now()
        )

        return self._repository.update(updated_task)

    def delete_task(self, task_id: str) -> None:
        """
        Delete a task by ID.

        Args:
            task_id: Task ID to delete

        Raises:
            ValueError: If task not found
        """
        # Verify task exists
        self.get_task(task_id)

        # Delete the task
        self._repository.delete(task_id)

    def mark_complete(self, task_id: str) -> Task:
        """
        Mark a task as complete.

        Args:
            task_id: Task ID to mark complete

        Returns:
            The updated task

        Raises:
            ValueError: If task not found
        """
        task = self.get_task(task_id)

        updated_task = Task(
            title=task.title,
            description=task.description,
            status=TaskStatus.COMPLETE,
            id=task.id,
            created_at=task.created_at,
            updated_at=datetime.now()
        )

        return self._repository.update(updated_task)

    def mark_incomplete(self, task_id: str) -> Task:
        """
        Mark a task as incomplete.

        Args:
            task_id: Task ID to mark incomplete

        Returns:
            The updated task

        Raises:
            ValueError: If task not found
        """
        task = self.get_task(task_id)

        updated_task = Task(
            title=task.title,
            description=task.description,
            status=TaskStatus.INCOMPLETE,
            id=task.id,
            created_at=task.created_at,
            updated_at=datetime.now()
        )

        return self._repository.update(updated_task)
