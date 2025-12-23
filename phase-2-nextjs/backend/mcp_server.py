from mcp.server.fastmcp import FastMCP
from sqlmodel import Session, select
from typing import Optional, List
from db import engine, init_db
from models import Task

# Initialize MCP Server
mcp = FastMCP("Todo Agent")

@mcp.tool()
def add_task(user_id: str, title: str, description: Optional[str] = None, priority: Optional[str] = "medium", due_date: Optional[str] = None, category: Optional[str] = "general") -> dict:
    """Create a new task. Priority can be 'low', 'medium', 'high'."""
    with Session(engine) as session:
        # In Phase 2, due_date might need parsing if it's a string, or it's already a datetime in model
        # The model says Optional[datetime]
        from datetime import datetime
        dt_due_date = None
        if due_date:
            try:
                dt_due_date = datetime.fromisoformat(due_date.replace("Z", "+00:00"))
            except:
                dt_due_date = None

        task = Task(user_id=user_id, title=title, description=description, priority=priority, due_date=dt_due_date, category=category)
        session.add(task)
        session.commit()
        session.refresh(task)
        return {"task_id": task.id, "status": "created", "title": task.title, "priority": task.priority, "due_date": str(task.due_date) if task.due_date else None, "category": task.category}

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
        # Convert to dict and handle datetime
        tasks = []
        for t in results:
            d = t.model_dump()
            d['due_date'] = str(t.due_date) if t.due_date else None
            d['created_at'] = str(t.created_at)
            d['updated_at'] = str(t.updated_at)
            tasks.append(d)
        return tasks

@mcp.tool()
def complete_task(user_id: str, task_id: int) -> dict:
    """Mark a task as complete"""
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            return {"error": "Task not found"}

        task.completed = True
        session.add(task)
        session.commit()
        session.refresh(task)
        return {"task_id": task.id, "status": "completed", "title": task.title}

@mcp.tool()
def delete_task(user_id: str, task_id: int) -> dict:
    """Remove a task from the list"""
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            return {"error": "Task not found"}

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

        if title:
            task.title = title
        if description:
            task.description = description
        if priority:
            task.priority = priority
        if due_date:
            from datetime import datetime
            try:
                task.due_date = datetime.fromisoformat(due_date.replace("Z", "+00:00"))
            except:
                pass
        if category:
            task.category = category

        session.add(task)
        session.commit()
        session.refresh(task)
        return {"task_id": task.id, "status": "updated", "title": task.title}

if __name__ == "__main__":
    # Ensure tables exist
    init_db()
    mcp.run()
