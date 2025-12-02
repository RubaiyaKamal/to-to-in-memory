"""Tests for TaskRepository - RED phase (tests written first)."""

import pytest

from todo.models.task import Task, TaskStatus
from todo.storage.repository import InMemoryTaskRepository


class TestInMemoryTaskRepository:
    """Test InMemoryTaskRepository implementation."""

    def test_add_task_returns_task(self) -> None:
        """Test that adding a task returns the task."""
        repo = InMemoryTaskRepository()
        task = Task(title="Test task")

        result = repo.add(task)

        assert result == task
        assert result.id == task.id

    def test_add_task_stores_task(self) -> None:
        """Test that adding a task stores it in the repository."""
        repo = InMemoryTaskRepository()
        task = Task(title="Test task")

        repo.add(task)
        retrieved = repo.get(task.id)

        assert retrieved is not None
        assert retrieved.id == task.id
        assert retrieved.title == "Test task"

    def test_get_nonexistent_task_returns_none(self) -> None:
        """Test that getting a non-existent task returns None."""
        repo = InMemoryTaskRepository()

        result = repo.get("nonexistent-id")

        assert result is None

    def test_get_all_returns_empty_list_initially(self) -> None:
        """Test that get_all returns empty list for new repository."""
        repo = InMemoryTaskRepository()

        result = repo.get_all()

        assert result == []

    def test_get_all_returns_all_tasks(self) -> None:
        """Test that get_all returns all added tasks."""
        repo = InMemoryTaskRepository()
        task1 = Task(title="Task 1")
        task2 = Task(title="Task 2")
        task3 = Task(title="Task 3")

        repo.add(task1)
        repo.add(task2)
        repo.add(task3)

        result = repo.get_all()

        assert len(result) == 3
        assert task1 in result
        assert task2 in result
        assert task3 in result

    def test_update_existing_task_returns_updated_task(self) -> None:
        """Test that updating an existing task returns the updated task."""
        repo = InMemoryTaskRepository()
        task = Task(title="Original title")
        repo.add(task)

        updated_task = Task(
            title="Updated title",
            description="New description",
            status=TaskStatus.COMPLETE,
            id=task.id,
            created_at=task.created_at,
            updated_at=task.updated_at
        )

        result = repo.update(updated_task)

        assert result.id == task.id
        assert result.title == "Updated title"
        assert result.description == "New description"
        assert result.status == TaskStatus.COMPLETE

    def test_update_existing_task_persists_changes(self) -> None:
        """Test that updating a task persists the changes."""
        repo = InMemoryTaskRepository()
        task = Task(title="Original title")
        repo.add(task)

        updated_task = Task(
            title="Updated title",
            id=task.id,
            created_at=task.created_at,
            updated_at=task.updated_at
        )
        repo.update(updated_task)

        retrieved = repo.get(task.id)

        assert retrieved is not None
        assert retrieved.title == "Updated title"

    def test_update_nonexistent_task_raises_error(self) -> None:
        """Test that updating a non-existent task raises KeyError."""
        repo = InMemoryTaskRepository()
        task = Task(title="Test task")

        with pytest.raises(KeyError, match="Task with ID .* not found"):
            repo.update(task)

    def test_delete_existing_task_returns_true(self) -> None:
        """Test that deleting an existing task returns True."""
        repo = InMemoryTaskRepository()
        task = Task(title="Test task")
        repo.add(task)

        result = repo.delete(task.id)

        assert result is True

    def test_delete_existing_task_removes_task(self) -> None:
        """Test that deleting a task removes it from the repository."""
        repo = InMemoryTaskRepository()
        task = Task(title="Test task")
        repo.add(task)

        repo.delete(task.id)
        retrieved = repo.get(task.id)

        assert retrieved is None

    def test_delete_nonexistent_task_returns_false(self) -> None:
        """Test that deleting a non-existent task returns False."""
        repo = InMemoryTaskRepository()

        result = repo.delete("nonexistent-id")

        assert result is False

    def test_repository_instances_are_independent(self) -> None:
        """Test that different repository instances don't share data."""
        repo1 = InMemoryTaskRepository()
        repo2 = InMemoryTaskRepository()

        task = Task(title="Test task")
        repo1.add(task)

        assert repo1.get(task.id) is not None
        assert repo2.get(task.id) is None

    def test_add_multiple_tasks_with_different_ids(self) -> None:
        """Test that multiple tasks can be added with different IDs."""
        repo = InMemoryTaskRepository()
        tasks = [Task(title=f"Task {i}") for i in range(5)]

        for task in tasks:
            repo.add(task)

        all_tasks = repo.get_all()
        assert len(all_tasks) == 5

        # Verify all IDs are unique
        ids = [task.id for task in all_tasks]
        assert len(ids) == len(set(ids))
