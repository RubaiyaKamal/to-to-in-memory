"""Demo script to showcase all todo application features in a single session."""

from todo.models.task import Task, TaskStatus
from todo.services.todo_service import TodoService
from todo.storage.repository import InMemoryTaskRepository
from todo.cli.formatter import format_task, format_task_list, format_success


def main() -> None:
    """Demonstrate all todo application features."""
    print("=" * 60)
    print("TODO APPLICATION DEMO - All Features")
    print("=" * 60)
    print()

    # Initialize service
    repository = InMemoryTaskRepository()
    service = TodoService(repository)

    # Feature 1: Add tasks
    print("📝 FEATURE 1: Adding Tasks")
    print("-" * 60)
    task1 = service.add_task("Buy groceries", "Milk, eggs, bread, and cheese")
    print(format_success(f"Task added with ID: {task1.id}"))
    print(format_task(task1))
    print()

    task2 = service.add_task("Finish project report", "Complete the Q4 analysis")
    print(format_success(f"Task added with ID: {task2.id}"))
    print(format_task(task2))
    print()

    task3 = service.add_task("Call dentist")
    print(format_success(f"Task added with ID: {task3.id}"))
    print(format_task(task3))
    print()

    # Feature 2: List all tasks
    print("\n📋 FEATURE 2: Listing All Tasks")
    print("-" * 60)
    tasks = service.list_tasks()
    print(format_task_list(tasks))
    print()

    # Feature 3: View specific task
    print(f"\n🔍 FEATURE 3: Viewing Specific Task (ID: {task1.id[:8]}...)")
    print("-" * 60)
    task = service.get_task(task1.id)
    print(format_task(task))
    print()

    # Feature 4: Update task
    print(f"\n✏️  FEATURE 4: Updating Task (ID: {task2.id[:8]}...)")
    print("-" * 60)
    updated_task = service.update_task(
        task2.id,
        title="Complete Q4 Project Report",
        description="Finish analysis and create presentation slides"
    )
    print(format_success("Task updated"))
    print(format_task(updated_task))
    print()

    # Feature 5: Mark task as complete
    print(f"\n✅ FEATURE 5: Marking Task as Complete (ID: {task1.id[:8]}...)")
    print("-" * 60)
    completed_task = service.mark_complete(task1.id)
    print(format_success("Task marked as complete"))
    print(format_task(completed_task))
    print()

    # Show updated list
    print("\n📋 Updated Task List (After Completion)")
    print("-" * 60)
    tasks = service.list_tasks()
    print(format_task_list(tasks))
    print()

    # Mark task as incomplete
    print(f"\n🔄 BONUS: Marking Task as Incomplete (ID: {task1.id[:8]}...)")
    print("-" * 60)
    incomplete_task = service.mark_incomplete(task1.id)
    print(format_success("Task marked as incomplete"))
    print(format_task(incomplete_task))
    print()

    # Feature 6: Delete task
    print(f"\n🗑️  FEATURE 6: Deleting Task (ID: {task3.id[:8]}...)")
    print("-" * 60)
    service.delete_task(task3.id)
    print(format_success(f"Task {task3.id} deleted"))
    print()

    # Final list
    print("\n📋 Final Task List (After Deletion)")
    print("-" * 60)
    tasks = service.list_tasks()
    print(format_task_list(tasks))
    print()

    print("=" * 60)
    print("✨ DEMO COMPLETE - All 5 Core Features Demonstrated!")
    print("=" * 60)
    print("\nFeatures demonstrated:")
    print("  ✓ Add tasks with title and description")
    print("  ✓ List all tasks with status")
    print("  ✓ View specific task details")
    print("  ✓ Update task title and description")
    print("  ✓ Mark tasks as complete/incomplete")
    print("  ✓ Delete tasks by ID")
    print()


if __name__ == "__main__":
    main()
