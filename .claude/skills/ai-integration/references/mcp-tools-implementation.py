"""
MCP Tools Implementation Reference
Complete implementation of all 5 MCP tools for Todo application

File location: backend/app/mcp/tools.py
"""

from mcp.server import MCPServer
from pydantic import BaseModel, Field
from typing import Optional, List, Literal
from sqlmodel import Session, select
from datetime import datetime

from app.models import Task, User
from app.database import get_session

mcp_server = MCPServer("todo-mcp-server")

# ============================================================================
# TOOL 1: Add Task
# ============================================================================
class AddTaskParams(BaseModel):
    user_id: str = Field(description="User ID from JWT")
    title: str = Field(
        description="Task title (required, 1-200 characters)",
        min_length=1,
        max_length=200
    )
    description: Optional[str] = Field(
        default=None,
        description="Optional task description (max 1000 characters)",
        max_length=1000
    )

@mcp_server.tool(
    name="add_task",
    description="Create a new task in the user's todo list. Use this when the user wants to add, create, or remember something.",
    parameters=AddTaskParams
)
async def add_task(params: AddTaskParams) -> dict:
    """
    Add a new task to the database.

    Examples:
    - "Add task: Buy groceries"
    - "Remind me to call mom"
    - "I need to finish the report"
    """
    try:
        with next(get_session()) as session:
            task = Task(
                user_id=params.user_id,
                title=params.title.strip(),
                description=params.description.strip() if params.description else None,
                completed=False
            )
            session.add(task)
            session.commit()
            session.refresh(task)

            return {
                "status": "success",
                "task_id": task.id,
                "title": task.title,
                "message": f"✓ Created task: {task.title}"
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to create task: {str(e)}"
        }

# ============================================================================
# TOOL 2: List Tasks
# ============================================================================
class ListTasksParams(BaseModel):
    user_id: str = Field(description="User ID from JWT")
    status: Optional[Literal["all", "pending", "completed"]] = Field(
        default="all",
        description="Filter by status: 'all' (default), 'pending', or 'completed'"
    )
    limit: Optional[int] = Field(
        default=None,
        description="Maximum number of tasks to return"
    )

@mcp_server.tool(
    name="list_tasks",
    description="Retrieve and display the user's tasks. Can filter by status (pending/completed) and limit results. Use this when the user asks to see, show, or list their tasks.",
    parameters=ListTasksParams
)
async def list_tasks(params: ListTasksParams) -> dict:
    """
    List tasks from database.

    Examples:
    - "Show me my tasks"
    - "What do I need to do?"
    - "List my completed tasks"
    """
    try:
        with next(get_session()) as session:
            # Build query
            statement = select(Task).where(Task.user_id == params.user_id)

            if params.status == "pending":
                statement = statement.where(Task.completed == False)
            elif params.status == "completed":
                statement = statement.where(Task.completed == True)

            if params.limit:
                statement = statement.limit(params.limit)

            statement = statement.order_by(Task.created_at.desc())

            # Execute
            tasks = session.exec(statement).all()

            # Format for display
            task_list = []
            for task in tasks:
                task_list.append({
                    "id": task.id,
                    "title": task.title,
                    "description": task.description,
                    "completed": task.completed,
                    "icon": "✓" if task.completed else "☐",
                    "created": task.created_at.strftime("%Y-%m-%d")
                })

            # Summary
            total = len(task_list)
            completed = sum(1 for t in task_list if t["completed"])
            pending = total - completed

            return {
                "status": "success",
                "tasks": task_list,
                "summary": {
                    "total": total,
                    "completed": completed,
                    "pending": pending
                },
                "message": f"Found {total} tasks ({completed} completed, {pending} pending)"
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to list tasks: {str(e)}"
        }

# ============================================================================
# TOOL 3: Complete Task
# ============================================================================
class CompleteTaskParams(BaseModel):
    user_id: str = Field(description="User ID from JWT")
    task_id: int = Field(description="ID of the task to mark as complete")

@mcp_server.tool(
    name="complete_task",
    description="Mark a task as completed or toggle its completion status. Use this when the user says they finished, completed, or did something.",
    parameters=CompleteTaskParams
)
async def complete_task(params: CompleteTaskParams) -> dict:
    """
    Toggle task completion in database.

    Examples:
    - "I finished task 5"
    - "Mark the groceries task as done"
    - "Complete the first task"
    """
    try:
        with next(get_session()) as session:
            task = session.get(Task, params.task_id)

            if not task:
                return {
                    "status": "error",
                    "message": f"Task #{params.task_id} not found"
                }

            if task.user_id != params.user_id:
                return {
                    "status": "error",
                    "message": "You don't have permission to modify this task"
                }

            # Toggle
            task.completed = not task.completed
            task.updated_at = datetime.utcnow()

            session.add(task)
            session.commit()
            session.refresh(task)

            icon = "✓" if task.completed else "☐"
            status_word = "completed" if task.completed else "pending"

            return {
                "status": "success",
                "task_id": task.id,
                "title": task.title,
                "completed": task.completed,
                "message": f"{icon} Marked '{task.title}' as {status_word}"
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to update task: {str(e)}"
        }

# ============================================================================
# TOOL 4: Update Task
# ============================================================================
class UpdateTaskParams(BaseModel):
    user_id: str = Field(description="User ID from JWT")
    task_id: int = Field(description="ID of the task to update")
    title: Optional[str] = Field(
        default=None,
        description="New title for the task"
    )
    description: Optional[str] = Field(
        default=None,
        description="New description for the task"
    )

@mcp_server.tool(
    name="update_task",
    description="Update a task's title or description. Use this when the user wants to change, edit, or modify a task.",
    parameters=UpdateTaskParams
)
async def update_task(params: UpdateTaskParams) -> dict:
    """
    Update task details in database.

    Examples:
    - "Change task 3 to 'Buy milk'"
    - "Update the description of my grocery task"
    """
    try:
        with next(get_session()) as session:
            task = session.get(Task, params.task_id)

            if not task:
                return {
                    "status": "error",
                    "message": f"Task #{params.task_id} not found"
                }

            if task.user_id != params.user_id:
                return {
                    "status": "error",
                    "message": "You don't have permission to modify this task"
                }

            # Update fields
            if params.title is not None:
                task.title = params.title.strip()
            if params.description is not None:
                task.description = params.description.strip() if params.description else None

            task.updated_at = datetime.utcnow()

            session.add(task)
            session.commit()
            session.refresh(task)

            return {
                "status": "success",
                "task_id": task.id,
                "title": task.title,
                "description": task.description,
                "message": f"✓ Updated task: {task.title}"
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to update task: {str(e)}"
        }

# ============================================================================
# TOOL 5: Delete Task
# ============================================================================
class DeleteTaskParams(BaseModel):
    user_id: str = Field(description="User ID from JWT")
    task_id: int = Field(description="ID of the task to delete")

@mcp_server.tool(
    name="delete_task",
    description="Permanently delete a task from the list. Use this when the user wants to remove or delete a task.",
    parameters=DeleteTaskParams
)
async def delete_task(params: DeleteTaskParams) -> dict:
    """
    Delete task from database.

    Examples:
    - "Delete task 5"
    - "Remove the grocery task"
    """
    try:
        with next(get_session()) as session:
            task = session.get(Task, params.task_id)

            if not task:
                return {
                    "status": "error",
                    "message": f"Task #{params.task_id} not found"
                }

            if task.user_id != params.user_id:
                return {
                    "status": "error",
                    "message": "You don't have permission to delete this task"
                }

            title = task.title
            session.delete(task)
            session.commit()

            return {
                "status": "success",
                "message": f"✗ Deleted task: {title}"
            }
    except Exception as e:
        return {
            "status": "error",
            "message": f"Failed to delete task: {str(e)}"
        }
