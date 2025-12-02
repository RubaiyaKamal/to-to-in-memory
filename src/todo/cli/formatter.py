"""CLI output formatter."""

from todo.models.task import Task, TaskStatus


def format_task(task: Task) -> str:
    """
    Format a single task for display.

    Args:
        task: Task to format

    Returns:
        Formatted task string
    """
    status_symbol = "✓" if task.status == TaskStatus.COMPLETE else "○"
    lines = [
        f"[{status_symbol}] {task.title}",
        f"    ID: {task.id}",
        f"    Status: {task.status.value}",
    ]

    if task.description:
        lines.append(f"    Description: {task.description}")

    return "\n".join(lines)


def format_task_list(tasks: list[Task]) -> str:
    """
    Format a list of tasks for display.

    Args:
        tasks: List of tasks to format

    Returns:
        Formatted task list string
    """
    if not tasks:
        return "No tasks found."

    header = f"\nTotal tasks: {len(tasks)}\n" + "=" * 50
    task_strings = [format_task(task) for task in tasks]

    return header + "\n\n" + "\n\n".join(task_strings)


def format_success(message: str) -> str:
    """
    Format a success message.

    Args:
        message: Success message

    Returns:
        Formatted success message
    """
    return f"✓ {message}"


def format_error(message: str) -> str:
    """
    Format an error message.

    Args:
        message: Error message

    Returns:
        Formatted error message
    """
    return f"✗ Error: {message}"
