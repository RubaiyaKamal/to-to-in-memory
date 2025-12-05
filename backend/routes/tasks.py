"""Task CRUD endpoints."""

from datetime import datetime

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session, select

from auth import verify_jwt
from db import get_session
from models import Task, TaskCreate, TaskResponse, TaskUpdate, User

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

    for field, value in update_data.items():
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
    task.completed = not task.completed
    task.updated_at = datetime.utcnow()
    session.add(task)
    session.commit()
    session.refresh(task)
    return task
