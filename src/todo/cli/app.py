"""Command-line interface for todo application."""

import argparse
import sys

from todo.cli.formatter import format_error, format_success, format_task, format_task_list
from todo.services.todo_service import TodoService
from todo.storage.json_repository import JsonTaskRepository


def create_parser() -> argparse.ArgumentParser:
    """Create and configure the argument parser."""
    parser = argparse.ArgumentParser(
        prog="todo",
        description="A command-line todo application with in-memory storage"
    )

    subparsers = parser.add_subparsers(dest="command", help="Available commands")

    # Add command
    add_parser = subparsers.add_parser("add", help="Add a new task")
    add_parser.add_argument("title", help="Task title")
    add_parser.add_argument(
        "-d", "--description",
        default="",
        help="Task description"
    )

    # List command
    subparsers.add_parser("list", help="List all tasks")

    # Show command
    show_parser = subparsers.add_parser("show", help="Show a specific task")
    show_parser.add_argument("task_id", help="Task ID")

    # Update command
    update_parser = subparsers.add_parser("update", help="Update a task")
    update_parser.add_argument("task_id", help="Task ID")
    update_parser.add_argument("-t", "--title", help="New title")
    update_parser.add_argument("-d", "--description", help="New description")

    # Delete command
    delete_parser = subparsers.add_parser("delete", help="Delete a task")
    delete_parser.add_argument("task_id", help="Task ID")

    # Complete command
    complete_parser = subparsers.add_parser("complete", help="Mark a task as complete")
    complete_parser.add_argument("task_id", help="Task ID")

    # Incomplete command
    incomplete_parser = subparsers.add_parser(
        "incomplete",
        help="Mark a task as incomplete"
    )
    incomplete_parser.add_argument("task_id", help="Task ID")

    return parser


def main() -> None:
    """Main entry point for the CLI application."""
    parser = create_parser()
    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(0)

    # Initialize service with JSON repository for persistence
    repository = JsonTaskRepository()
    service = TodoService(repository)

    try:
        if args.command == "add":
            task = service.add_task(args.title, args.description)
            print(format_success(f"Task added with ID: {task.id}"))
            print(format_task(task))

        elif args.command == "list":
            tasks = service.list_tasks()
            print(format_task_list(tasks))

        elif args.command == "show":
            task = service.get_task(args.task_id)
            print(format_task(task))

        elif args.command == "update":
            if not args.title and not args.description:
                print(format_error("Please provide --title and/or --description"))
                sys.exit(1)

            task = service.update_task(args.task_id, args.title, args.description)
            print(format_success("Task updated"))
            print(format_task(task))

        elif args.command == "delete":
            service.delete_task(args.task_id)
            print(format_success(f"Task {args.task_id} deleted"))

        elif args.command == "complete":
            task = service.mark_complete(args.task_id)
            print(format_success("Task marked as complete"))
            print(format_task(task))

        elif args.command == "incomplete":
            task = service.mark_incomplete(args.task_id)
            print(format_success("Task marked as incomplete"))
            print(format_task(task))

        sys.exit(0)

    except ValueError as e:
        print(format_error(str(e)), file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(format_error(f"Unexpected error: {e}"), file=sys.stderr)
        sys.exit(2)


if __name__ == "__main__":
    main()
