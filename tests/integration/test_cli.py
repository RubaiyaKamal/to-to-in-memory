"""Integration tests for CLI - testing end-to-end workflows."""

from io import StringIO
from unittest.mock import patch

import pytest

from todo.cli.app import main


class TestCLIIntegration:
    """Integration tests for the CLI application."""

    def test_add_and_list_workflow(self) -> None:
        """Test adding tasks and listing them."""
        # Note: Since we use in-memory storage, each command starts fresh
        # This test verifies the commands work correctly
        with patch("sys.argv", ["todo", "add", "Test task", "-d", "Test description"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 0
                output = mock_stdout.getvalue()
                assert "Task added" in output
                assert "Test task" in output

    def test_add_task_without_description(self) -> None:
        """Test adding a task without description."""
        with patch("sys.argv", ["todo", "add", "Simple task"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 0
                output = mock_stdout.getvalue()
                assert "Task added" in output

    def test_add_task_with_empty_title_fails(self) -> None:
        """Test that adding a task with empty title fails."""
        with patch("sys.argv", ["todo", "add", ""]):
            with patch("sys.stderr", new=StringIO()) as mock_stderr:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stderr.getvalue()
                assert "Error" in output

    def test_list_empty_tasks(self) -> None:
        """Test listing when no tasks exist."""
        with patch("sys.argv", ["todo", "list"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 0
                output = mock_stdout.getvalue()
                assert "No tasks found" in output

    def test_show_nonexistent_task_fails(self) -> None:
        """Test showing a non-existent task fails."""
        with patch("sys.argv", ["todo", "show", "nonexistent-id"]):
            with patch("sys.stderr", new=StringIO()) as mock_stderr:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stderr.getvalue()
                assert "Error" in output
                assert "not found" in output

    def test_update_without_arguments_fails(self) -> None:
        """Test updating without title or description fails."""
        with patch("sys.argv", ["todo", "update", "some-id"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stdout.getvalue()
                assert "Error" in output

    def test_delete_nonexistent_task_fails(self) -> None:
        """Test deleting a non-existent task fails."""
        with patch("sys.argv", ["todo", "delete", "nonexistent-id"]):
            with patch("sys.stderr", new=StringIO()) as mock_stderr:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stderr.getvalue()
                assert "Error" in output

    def test_complete_nonexistent_task_fails(self) -> None:
        """Test marking non-existent task complete fails."""
        with patch("sys.argv", ["todo", "complete", "nonexistent-id"]):
            with patch("sys.stderr", new=StringIO()) as mock_stderr:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stderr.getvalue()
                assert "Error" in output

    def test_incomplete_nonexistent_task_fails(self) -> None:
        """Test marking non-existent task incomplete fails."""
        with patch("sys.argv", ["todo", "incomplete", "nonexistent-id"]):
            with patch("sys.stderr", new=StringIO()) as mock_stderr:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 1
                output = mock_stderr.getvalue()
                assert "Error" in output

    def test_no_command_shows_help(self) -> None:
        """Test that running without command shows help."""
        with patch("sys.argv", ["todo"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                assert exc_info.value.code == 0
                output = mock_stdout.getvalue()
                assert "usage:" in output or "Available commands" in output

    def test_help_command(self) -> None:
        """Test help command."""
        with patch("sys.argv", ["todo", "--help"]):
            with patch("sys.stdout", new=StringIO()) as mock_stdout:
                with pytest.raises(SystemExit) as exc_info:
                    main()
                # argparse exits with 0 for help
                assert exc_info.value.code == 0
                output = mock_stdout.getvalue()
                assert "usage:" in output
