"""Tests for TodoService - RED phase (tests written first)."""

import pytest

from todo.models.task import TaskStatus
from todo.services.todo_service import TodoService
from todo.storage.repository import InMemoryTaskRepository


class TestTodoService:
    """Test TodoService business logic."""

    def test_add_task_with_title_only(self) -> None:
        """Test adding a task with only a title."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Buy groceries")

        assert task.title == "Buy groceries"
        assert task.description == ""
        assert task.status == TaskStatus.INCOMPLETE
        assert task.id is not None

    def test_add_task_with_title_and_description(self) -> None:
        """Test adding a task with title and description."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Buy groceries", "Milk, eggs, bread")

        assert task.title == "Buy groceries"
        assert task.description == "Milk, eggs, bread"

    def test_add_task_with_empty_title_raises_error(self) -> None:
        """Test that adding a task with empty title raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Title cannot be empty"):
            service.add_task("")

    def test_add_task_persists_in_repository(self) -> None:
        """Test that added task is persisted in repository."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        retrieved = repo.get(task.id)

        assert retrieved is not None
        assert retrieved.id == task.id

    def test_list_tasks_returns_empty_list_initially(self) -> None:
        """Test that list_tasks returns empty list for new service."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        tasks = service.list_tasks()

        assert tasks == []

    def test_list_tasks_returns_all_tasks(self) -> None:
        """Test that list_tasks returns all added tasks."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        service.add_task("Task 1")
        service.add_task("Task 2")
        service.add_task("Task 3")

        tasks = service.list_tasks()

        assert len(tasks) == 3

    def test_get_task_returns_existing_task(self) -> None:
        """Test that get_task returns an existing task."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        added_task = service.add_task("Test task")
        retrieved_task = service.get_task(added_task.id)

        assert retrieved_task.id == added_task.id
        assert retrieved_task.title == "Test task"

    def test_get_task_raises_error_for_nonexistent_task(self) -> None:
        """Test that get_task raises ValueError for non-existent task."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Task with ID .* not found"):
            service.get_task("nonexistent-id")

    def test_update_task_title(self) -> None:
        """Test updating a task's title."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Original title")
        updated = service.update_task(task.id, title="Updated title")

        assert updated.title == "Updated title"
        assert updated.description == ""

    def test_update_task_description(self) -> None:
        """Test updating a task's description."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        updated = service.update_task(task.id, description="New description")

        assert updated.title == "Test task"
        assert updated.description == "New description"

    def test_update_task_both_title_and_description(self) -> None:
        """Test updating both title and description."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Original")
        updated = service.update_task(
            task.id,
            title="Updated title",
            description="Updated description"
        )

        assert updated.title == "Updated title"
        assert updated.description == "Updated description"

    def test_update_task_persists_changes(self) -> None:
        """Test that task updates are persisted."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Original")
        service.update_task(task.id, title="Updated")

        retrieved = service.get_task(task.id)
        assert retrieved.title == "Updated"

    def test_update_nonexistent_task_raises_error(self) -> None:
        """Test that updating a non-existent task raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Task with ID .* not found"):
            service.update_task("nonexistent-id", title="Test")

    def test_update_task_with_empty_title_raises_error(self) -> None:
        """Test that updating a task with empty title raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")

        with pytest.raises(ValueError, match="Title cannot be empty"):
            service.update_task(task.id, title="")

    def test_delete_task_removes_task(self) -> None:
        """Test that delete_task removes the task."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        service.delete_task(task.id)

        with pytest.raises(ValueError):
            service.get_task(task.id)

    def test_delete_nonexistent_task_raises_error(self) -> None:
        """Test that deleting a non-existent task raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Task with ID .* not found"):
            service.delete_task("nonexistent-id")

    def test_mark_complete_changes_status(self) -> None:
        """Test that mark_complete changes task status to COMPLETE."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        completed = service.mark_complete(task.id)

        assert completed.status == TaskStatus.COMPLETE

    def test_mark_complete_persists_status(self) -> None:
        """Test that mark_complete persists the status change."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        service.mark_complete(task.id)

        retrieved = service.get_task(task.id)
        assert retrieved.status == TaskStatus.COMPLETE

    def test_mark_incomplete_changes_status(self) -> None:
        """Test that mark_incomplete changes task status to INCOMPLETE."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")
        service.mark_complete(task.id)
        incomplete = service.mark_incomplete(task.id)

        assert incomplete.status == TaskStatus.INCOMPLETE

    def test_mark_complete_nonexistent_task_raises_error(self) -> None:
        """Test that marking non-existent task complete raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Task with ID .* not found"):
            service.mark_complete("nonexistent-id")

    def test_mark_incomplete_nonexistent_task_raises_error(self) -> None:
        """Test that marking non-existent task incomplete raises ValueError."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        with pytest.raises(ValueError, match="Task with ID .* not found"):
            service.mark_incomplete("nonexistent-id")

    def test_toggle_status_multiple_times(self) -> None:
        """Test toggling task status multiple times."""
        repo = InMemoryTaskRepository()
        service = TodoService(repo)

        task = service.add_task("Test task")

        # Mark complete
        task = service.mark_complete(task.id)
        assert task.status == TaskStatus.COMPLETE

        # Mark incomplete
        task = service.mark_incomplete(task.id)
        assert task.status == TaskStatus.INCOMPLETE

        # Mark complete again
        task = service.mark_complete(task.id)
        assert task.status == TaskStatus.COMPLETE
