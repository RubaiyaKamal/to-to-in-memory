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
    add_parser.add_argument("title", nargs="?", help="Task title")
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
    add_parser.add_argument("title", nargs="?", help="Task title")
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
    # If arguments are provided, use the command line interface
    if len(sys.argv) > 1:
        parser = create_parser()
        args = parser.parse_args()

        # Initialize service
        repository = JsonTaskRepository()
        service = TodoService(repository)

        try:
            if args.command == "add":
                # We keep the interactive add check here for "todo add" without args case
                # But if we are here, sys.argv > 1, so "todo add" is 2 args.
                if not args.title:
                    interactive_add(service)
                else:
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

    # Interactive Mode (No arguments)
    else:
        repository = JsonTaskRepository()
        service = TodoService(repository)

        while True:
            print("\n" + "=" * 50)
            print("TODO APPLICATION")
            print("=" * 50)
            print("1. Add Task")
            print("2. List Tasks")
            print("3. Update Task")
            print("4. Delete Task")
            print("5. Mark Task Complete")
            print("6. Mark Task Incomplete")
            print("7. Exit")
            print("-" * 50)

            choice = input("Enter your choice (1-7): ").strip()

            try:
                if choice == "1":
                    interactive_add(service)
                elif choice == "2":
                    interactive_list(service)
                elif choice == "3":
                    interactive_update(service)
                elif choice == "4":
                    interactive_delete(service)
                elif choice == "5":
                    interactive_complete(service)
                elif choice == "6":
                    interactive_incomplete(service)
                elif choice == "7":
                    print("Goodbye!")
                    sys.exit(0)
                else:
                    print(format_error("Invalid choice. Please try again."))
            except Exception as e:
                print(format_error(f"Error: {e}"))
                input("Press Enter to continue...")


def interactive_add(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("ADD NEW TASK")
    print("=" * 50)
    print()

    title = input("Enter task title: ").strip()
    while not title:
        print(format_error("Title cannot be empty"))
        title = input("Enter task title: ").strip()

    description = input("Enter task description (optional, press Enter to skip): ").strip()

    task = service.add_task(title, description)
    print()
    print(format_success(f"Task '{title}' created successfully!"))
    print()
    print(f"ℹ️ Task ID: {task.id}")
    print()
    input("Press Enter to continue...")


def interactive_list(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("TASK LIST")
    print("=" * 50)
    tasks = service.list_tasks()
    print(format_task_list(tasks))
    input("\nPress Enter to continue...")


def interactive_update(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("UPDATE TASK")
    print("=" * 50)

    task_id = input("Enter Task ID to update: ").strip()
    if not task_id:
        return

    try:
        # Check if task exists first
        task = service.get_task(task_id)
        print(f"Updating task: {task.title}")

        new_title = input(f"Enter new title (leave empty to keep '{task.title}'): ").strip()
        new_desc = input(f"Enter new description (leave empty to keep current): ").strip()

        if not new_title and not new_desc:
            print("No changes made.")
        else:
            # Pass None if empty string to indicate no change, but service expects str.
            # The service update_task signature is (task_id, title, description).
            # If I pass empty string, does it overwrite?
            # Let's check service implementation or just pass what we have.
            # Usually CLI args are optional.
            # Let's assume service handles empty strings or we need to handle it.
            # If I look at app.py before:
            # if not args.title and not args.description: print error.
            # So service probably updates whatever is passed.

            # Logic: if empty, pass None? The service likely expects Optional[str].
            # Let's check imports. TodoService is imported.
            # I'll assume for now I should pass None if I want to keep it, or the service handles it.
            # Actually, looking at previous app.py:
            # task = service.update_task(args.task_id, args.title, args.description)
            # argparse defaults are None if not provided? No, default is None usually.
            # So I should pass None if empty.

            final_title = new_title if new_title else None
            final_desc = new_desc if new_desc else None

            updated_task = service.update_task(task_id, final_title, final_desc)
            print(format_success("Task updated successfully!"))
            print(format_task(updated_task))

    except ValueError as e:
        print(format_error(str(e)))

    input("\nPress Enter to continue...")


def interactive_delete(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("DELETE TASK")
    print("=" * 50)

    task_id = input("Enter Task ID to delete: ").strip()
    if not task_id:
        return

    try:
        service.delete_task(task_id)
        print(format_success(f"Task {task_id} deleted successfully!"))
    except ValueError as e:
        print(format_error(str(e)))

    input("\nPress Enter to continue...")


def interactive_complete(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("MARK COMPLETE")
    print("=" * 50)

    task_id = input("Enter Task ID to mark complete: ").strip()
    if not task_id:
        return

    try:
        task = service.mark_complete(task_id)
        print(format_success("Task marked as complete!"))
        print(format_task(task))
    except ValueError as e:
        print(format_error(str(e)))

    input("\nPress Enter to continue...")


def interactive_incomplete(service: TodoService) -> None:
    print("\n" + "=" * 50)
    print("MARK INCOMPLETE")
    print("=" * 50)

    task_id = input("Enter Task ID to mark incomplete: ").strip()
    if not task_id:
        return

    try:
        task = service.mark_incomplete(task_id)
        print(format_success("Task marked as incomplete!"))
        print(format_task(task))
    except ValueError as e:
        print(format_error(str(e)))

    input("\nPress Enter to continue...")


if __name__ == "__main__":
    main()
