"""Task CRUD endpoints."""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from backend.auth import verify_jwt
from backend.db import get_session
from backend.models import Task, TaskCreate, TaskResponse, TaskUpdate, User, TaskHistory, TaskHistoryResponse

router = APIRouter(tags=["tasks"])


def ensure_user_exists(user_id: str, session: Session) -> None:
    """
    Ensure user exists in database. Create if doesn't exist.
    This is for testing with mock auth - remove in production.
    """
    user = session.get(User, user_id)
    if not user:
        # Create mock user
        user = User(
            id=user_id,
            email=f"{user_id}@example.com",
            password_hash="mock-hash"
        )
        session.add(user)
        session.commit()


def log_task_history(
    session: Session,
    task_id: int,
    user_id: str,
    action: str,
    field_name: str | None = None,
    old_value: str | None = None,
    new_value: str | None = None,
) -> None:
    """
    Log task change to history.

    Args:
        session: Database session
        task_id: ID of the task that changed
        user_id: ID of the user who made the change
        action: Type of action (created, updated, deleted, completed, uncompleted)
        field_name: Name of the field that changed (for updates)
        old_value: Previous value (for updates)
        new_value: New value (for updates/creates)
    """
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


@router.get("/{user_id}/tasks", response_model=list[TaskResponse])
def get_tasks(
    user_id: str,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> list[Task]:
    """
    Get all tasks for authenticated user.

    Args:
        user_id: User ID from path
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        list[Task]: List of user's tasks

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
    """
    # Verify user_id matches authenticated user
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Query tasks for user
    statement = select(Task).where(Task.user_id == user_id).order_by(Task.created_at.desc())
    tasks = session.exec(statement).all()
    return list(tasks)


@router.post("/{user_id}/tasks", response_model=TaskResponse, status_code=201)
def create_task(
    user_id: str,
    task_data: TaskCreate,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> Task:
    """
    Create a new task for authenticated user.

    Args:
        user_id: User ID from path
        task_data: Task creation data
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        Task: Created task

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Ensure user exists (for mock auth testing)
    ensure_user_exists(user_id, session)

    # Create task
    task = Task(user_id=user_id, **task_data.model_dump())
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

    return task


@router.get("/{user_id}/tasks/{task_id}", response_model=TaskResponse)
def get_task(
    user_id: str,
    task_id: int,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> Task:
    """
    Get a specific task.

    Args:
        user_id: User ID from path
        task_id: Task ID
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        Task: Task details

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
        HTTPException: 404 if task not found or doesn't belong to user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Get task
    task = session.get(Task, task_id)
    if not task or task.user_id != user_id:
        raise HTTPException(status_code=404, detail="Task not found")

    return task


@router.put("/{user_id}/tasks/{task_id}", response_model=TaskResponse)
def update_task(
    user_id: str,
    task_id: int,
    task_data: TaskUpdate,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> Task:
    """
    Update a task.

    Args:
        user_id: User ID from path
        task_id: Task ID
        task_data: Task update data
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        Task: Updated task

    Raises:
        HTTPException: 400 if no fields to update
        HTTPException: 403 if user_id doesn't match authenticated user
        HTTPException: 404 if task not found or doesn't belong to user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Get task
    task = session.get(Task, task_id)
    if not task or task.user_id != user_id:
        raise HTTPException(status_code=404, detail="Task not found")

    # Update fields
    update_data = task_data.model_dump(exclude_unset=True)
    if not update_data:
        raise HTTPException(status_code=400, detail="No fields to update")

    # Log each field change
    for field, value in update_data.items():
        old_value = getattr(task, field)
        log_task_history(
            session=session,
            task_id=task_id,
            user_id=user_id,
            action="updated",
            field_name=field,
            old_value=str(old_value) if old_value is not None else None,
            new_value=str(value) if value is not None else None,
        )
        setattr(task, field, value)

    task.updated_at = datetime.utcnow()
    session.add(task)
    session.commit()
    session.refresh(task)
    return task


@router.delete("/{user_id}/tasks/{task_id}", status_code=204)
def delete_task(
    user_id: str,
    task_id: int,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> None:
    """
    Delete a task.

    Args:
        user_id: User ID from path
        task_id: Task ID
        session: Database session
        authenticated_user_id: User ID from JWT token

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
        HTTPException: 404 if task not found or doesn't belong to user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Get task
    task = session.get(Task, task_id)
    if not task or task.user_id != user_id:
        raise HTTPException(status_code=404, detail="Task not found")

    # Log deletion before deleting
    log_task_history(
        session=session,
        task_id=task_id,
        user_id=user_id,
        action="deleted",
        old_value=task.title,
    )

    # Delete task
    session.delete(task)
    session.commit()


@router.patch("/{user_id}/tasks/{task_id}/complete", response_model=TaskResponse)
def toggle_task_complete(
    user_id: str,
    task_id: int,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> Task:
    """
    Toggle task completion status.

    Args:
        user_id: User ID from path
        task_id: Task ID
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        Task: Updated task

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
        HTTPException: 404 if task not found or doesn't belong to user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Get task
    task = session.get(Task, task_id)
    if not task or task.user_id != user_id:
        raise HTTPException(status_code=404, detail="Task not found")

    # Toggle completion
    old_completed = task.completed
    task.completed = not task.completed
    task.updated_at = datetime.utcnow()

    # Log completion status change
    log_task_history(
        session=session,
        task_id=task_id,
        user_id=user_id,
        action="completed" if task.completed else "uncompleted",
        field_name="completed",
        old_value=str(old_completed),
        new_value=str(task.completed),
    )

    session.add(task)
    session.commit()
    session.refresh(task)
    return task


@router.get("/{user_id}/history", response_model=list[TaskHistoryResponse])
def get_task_history(
    user_id: str,
    session: Session = Depends(get_session),
    authenticated_user_id: str = Depends(verify_jwt),
) -> list[TaskHistory]:
    """
    Get task history for authenticated user.

    Args:
        user_id: User ID from path
        session: Database session
        authenticated_user_id: User ID from JWT token

    Returns:
        list[TaskHistory]: List of task history entries

    Raises:
        HTTPException: 403 if user_id doesn't match authenticated user
    """
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    # Query history for user, ordered by most recent first
    statement = (
        select(TaskHistory)
        .where(TaskHistory.user_id == user_id)
        .order_by(TaskHistory.changed_at.desc())
    )
    history = session.exec(statement).all()
    return list(history)
