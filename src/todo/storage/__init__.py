"""Storage package initialization."""

from todo.storage.repository import InMemoryTaskRepository, TaskRepository

__all__ = ["TaskRepository", "InMemoryTaskRepository"]
