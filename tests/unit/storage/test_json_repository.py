"""Tests for JsonTaskRepository."""

import json
import os
from typing import Generator

import pytest

from todo.models.task import Task, TaskStatus
from todo.storage.json_repository import JsonTaskRepository


class TestJsonTaskRepository:
    """Test JsonTaskRepository implementation."""

    @pytest.fixture
    def test_file(self) -> Generator[str, None, None]:
        """Fixture to provide a temporary test file path."""
        file_path = "test_tasks.json"
        yield file_path
        if os.path.exists(file_path):
            os.remove(file_path)

    def test_init_creates_empty_repo_if_file_missing(self, test_file: str) -> None:
        """Test initialization when file doesn't exist."""
        repo = JsonTaskRepository(test_file)
        assert repo.get_all() == []

    def test_add_saves_to_file(self, test_file: str) -> None:
        """Test that adding a task saves it to the file."""
        repo = JsonTaskRepository(test_file)
        task = Task(title="Test task")

        repo.add(task)

        # Verify file exists and contains data
        assert os.path.exists(test_file)
        with open(test_file, "r") as f:
            data = json.load(f)
            assert len(data) == 1
            assert data[0]["id"] == task.id
            assert data[0]["title"] == "Test task"

    def test_persistence_between_instances(self, test_file: str) -> None:
        """Test that data persists between repository instances."""
        # First instance adds a task
        repo1 = JsonTaskRepository(test_file)
        task = Task(title="Persistent task")
        repo1.add(task)

        # Second instance loads the task
        repo2 = JsonTaskRepository(test_file)
        retrieved = repo2.get(task.id)

        assert retrieved is not None
        assert retrieved.id == task.id
        assert retrieved.title == "Persistent task"

    def test_update_saves_changes(self, test_file: str) -> None:
        """Test that updates are saved to file."""
        repo = JsonTaskRepository(test_file)
        task = Task(title="Original")
        repo.add(task)

        task.title = "Updated"
        repo.update(task)

        # Verify file content
        with open(test_file, "r") as f:
            data = json.load(f)
            assert data[0]["title"] == "Updated"

    def test_delete_removes_from_file(self, test_file: str) -> None:
        """Test that deletion removes task from file."""
        repo = JsonTaskRepository(test_file)
        task = Task(title="To delete")
        repo.add(task)

        repo.delete(task.id)

        # Verify file content
        with open(test_file, "r") as f:
            data = json.load(f)
            assert len(data) == 0

    def test_load_handles_corrupted_file(self, test_file: str) -> None:
        """Test that corrupted file is handled gracefully."""
        with open(test_file, "w") as f:
            f.write("{invalid json")

        repo = JsonTaskRepository(test_file)
        assert repo.get_all() == []

    def test_load_handles_malformed_task_data(self, test_file: str) -> None:
        """Test that tasks with missing fields are skipped."""
        data = [
            {"id": "1", "title": "Valid"},  # Missing other fields
            {"id": "2", "title": "Valid 2", "description": "", "status": "incomplete",
             "created_at": "2023-01-01T00:00:00", "updated_at": "2023-01-01T00:00:00"}
        ]
        with open(test_file, "w") as f:
            json.dump(data, f)

        repo = JsonTaskRepository(test_file)
        tasks = repo.get_all()

        # Should only load the valid task
        assert len(tasks) == 1
        assert tasks[0].id == "2"
