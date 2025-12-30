from fastmcp import FastMCP
from sqlmodel import Session, select
from typing import Optional, List
from database import engine, create_db_and_tables
from models import Task, TaskHistory

# Initialize MCP Server
mcp = FastMCP("Todo Agent")

def log_task_history(
    session: Session,
    task_id: int,
    user_id: str,
    action: str,
    field_name: Optional[str] = None,
    old_value: Optional[str] = None,
    new_value: Optional[str] = None,
) -> None:
    """Log task change to history."""
    history_entry = TaskHistory(
        task_id=task_id,
        user_id=user_id,
        action=action,
        field_name=field_name,
        old_value=old_value,
        new_value=new_value,
    )
    session.add(history_entry)
    session.commit()

@mcp.tool()
def add_task(user_id: str, title: str, description: Optional[str] = None, priority: Optional[str] = "medium", due_date: Optional[str] = None, category: Optional[str] = "general") -> dict:
    """Create a new task. Priority can be 'low', 'medium', 'high'."""
    with Session(engine) as session:
        task = Task(user_id=user_id, title=title, description=description, priority=priority, due_date=due_date, category=category)
        session.add(task)
        session.commit()
        session.refresh(task)

        # Log creation to history
        log_task_history(
            session=session,
            task_id=task.id,
            user_id=user_id,
            action="created",
            new_value=task.title,
        )

        return {"task_id": task.id, "status": "created", "title": task.title, "priority": task.priority, "due_date": task.due_date, "category": task.category}

@mcp.tool()
def list_tasks(user_id: str, status: Optional[str] = "all") -> List[dict]:
    """Retrieve tasks from the list. Status can be 'all', 'pending', or 'completed'."""
    with Session(engine) as session:
        statement = select(Task).where(Task.user_id == user_id)
        if status == "pending":
            statement = statement.where(Task.completed == False)
        elif status == "completed":
            statement = statement.where(Task.completed == True)

        results = session.exec(statement).all()
        return [task.model_dump() for task in results]

@mcp.tool()
def complete_task(user_id: str, task_id: int) -> dict:
    """Mark a task as complete"""
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            return {"error": "Task not found"}

        old_completed = task.completed
        task.completed = True
        session.add(task)
        session.commit()
        session.refresh(task)

        # Log completion status change
        log_task_history(
            session=session,
            task_id=task_id,
            user_id=user_id,
            action="completed",
            field_name="completed",
            old_value=str(old_completed),
            new_value=str(task.completed),
        )

        return {"task_id": task.id, "status": "completed", "title": task.title}

@mcp.tool()
def delete_task(user_id: str, task_id: int) -> dict:
    """Remove a task from the list"""
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            return {"error": "Task not found"}

        # Log deletion before deleting
        log_task_history(
            session=session,
            task_id=task_id,
            user_id=user_id,
            action="deleted",
            old_value=task.title,
        )

        session.delete(task)
        session.commit()
        return {"task_id": task_id, "status": "deleted", "title": task.title}

@mcp.tool()
def clear_tasks(user_id: str) -> dict:
    """Delete ALL tasks for the user. Use with caution."""
    with Session(engine) as session:
        statement = select(Task).where(Task.user_id == user_id)
        results = session.exec(statement).all()
        for task in results:
            session.delete(task)
        session.commit()
        return {"status": "all_cleared", "count": len(results)}

@mcp.tool()
def update_task(user_id: str, task_id: int, title: Optional[str] = None, description: Optional[str] = None, priority: Optional[str] = None, due_date: Optional[str] = None, category: Optional[str] = None) -> dict:
    """Modify task details"""
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            return {"error": "Task not found"}

        # Log each field change
        if title and title != task.title:
            log_task_history(session, task_id, user_id, "updated", "title", task.title, title)
            task.title = title
        if description and description != task.description:
            log_task_history(session, task_id, user_id, "updated", "description", task.description, description)
            task.description = description
        if priority and priority != task.priority:
            log_task_history(session, task_id, user_id, "updated", "priority", task.priority, priority)
            task.priority = priority
        if due_date and due_date != task.due_date:
            log_task_history(session, task_id, user_id, "updated", "due_date", task.due_date, due_date)
            task.due_date = due_date
        if category and category != task.category:
            log_task_history(session, task_id, user_id, "updated", "category", task.category, category)
            task.category = category

        session.add(task)
        session.commit()
        session.refresh(task)
        return {"task_id": task.id, "status": "updated", "title": task.title}

@mcp.tool()
def get_task_history(user_id: str) -> List[dict]:
    """Get task history audit log for the user"""
    with Session(engine) as session:
        statement = select(TaskHistory).where(TaskHistory.user_id == user_id).order_by(TaskHistory.changed_at.desc())
        results = session.exec(statement).all()
        return [history.model_dump() for history in results]

if __name__ == "__main__":
    # Ensure tables exist
    create_db_and_tables()
    mcp.run()
