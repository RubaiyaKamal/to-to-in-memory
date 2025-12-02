"""Tests for Task model - RED phase (tests written first)."""

from datetime import datetime
from uuid import UUID

import pytest

from todo.models.task import Task, TaskStatus


class TestTaskStatus:
    """Test TaskStatus enum."""

    def test_task_status_has_incomplete(self) -> None:
        """Test that TaskStatus has INCOMPLETE value."""
        assert TaskStatus.INCOMPLETE.value == "incomplete"

    def test_task_status_has_complete(self) -> None:
        """Test that TaskStatus has COMPLETE value."""
        assert TaskStatus.COMPLETE.value == "complete"


class TestTask:
    """Test Task model."""

    def test_create_task_with_title_only(self) -> None:
        """Test creating a task with only a title."""
        task = Task(title="Buy groceries")

        assert task.title == "Buy groceries"
        assert task.description == ""
        assert task.status == TaskStatus.INCOMPLETE
        assert isinstance(task.id, str)
        assert UUID(task.id)  # Verify it's a valid UUID
        assert isinstance(task.created_at, datetime)
        assert isinstance(task.updated_at, datetime)

    def test_create_task_with_title_and_description(self) -> None:
        """Test creating a task with title and description."""
        task = Task(title="Buy groceries", description="Milk, eggs, bread")

        assert task.title == "Buy groceries"
        assert task.description == "Milk, eggs, bread"
        assert task.status == TaskStatus.INCOMPLETE

    def test_create_task_with_empty_title_raises_error(self) -> None:
        """Test that creating a task with empty title raises ValueError."""
        with pytest.raises(ValueError, match="Title cannot be empty"):
            Task(title="")

    def test_create_task_with_whitespace_title_raises_error(self) -> None:
        """Test that creating a task with whitespace-only title raises ValueError."""
        with pytest.raises(ValueError, match="Title cannot be empty"):
            Task(title="   ")

    def test_task_id_is_unique(self) -> None:
        """Test that each task gets a unique ID."""
        task1 = Task(title="Task 1")
        task2 = Task(title="Task 2")

        assert task1.id != task2.id

    def test_task_status_defaults_to_incomplete(self) -> None:
        """Test that task status defaults to INCOMPLETE."""
        task = Task(title="Test task")
        assert task.status == TaskStatus.INCOMPLETE

    def test_task_can_be_created_with_complete_status(self) -> None:
        """Test that task can be created with COMPLETE status."""
        task = Task(title="Test task", status=TaskStatus.COMPLETE)
        assert task.status == TaskStatus.COMPLETE

    def test_task_timestamps_are_set(self) -> None:
        """Test that created_at and updated_at are set on creation."""
        before = datetime.now()
        task = Task(title="Test task")
        after = datetime.now()

        assert before <= task.created_at <= after
        assert before <= task.updated_at <= after

    def test_task_created_and_updated_at_are_same_on_creation(self) -> None:
        """Test that created_at and updated_at are the same on creation."""
        task = Task(title="Test task")
        # Allow small time difference due to execution time
        time_diff = (task.updated_at - task.created_at).total_seconds()
        assert time_diff < 0.1  # Less than 100ms difference
