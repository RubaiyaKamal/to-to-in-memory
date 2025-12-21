import os
from pathlib import Path
from dotenv import load_dotenv

# Robustly load .env from the same directory as this file
env_path = Path(__file__).parent / '.env'
load_dotenv(dotenv_path=env_path)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session

from .database import create_db_and_tables, engine
from .models import ChatRequest, ChatResponse, Task
from .agent import process_chat
from typing import List
from sqlmodel import select

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173", "http://localhost:5174"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
def on_startup():
    create_db_and_tables()

@app.get("/api/health")
def health_check():
    return {"status": "ok"}

@app.post("/api/{user_id}/chat", response_model=ChatResponse)
async def chat_endpoint(user_id: str, request: ChatRequest):
    try:
        response = await process_chat(user_id, request)
        return response
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/{user_id}/tasks", response_model=List[Task])
def get_tasks(user_id: str):
    with Session(engine) as session:
        statement = select(Task).where(Task.user_id == user_id)
        results = session.exec(statement).all()
        return results

@app.post("/api/{user_id}/tasks", response_model=Task)
def create_task(user_id: str, task: Task):
    # Ensure task.user_id matches path param
    task.id = None
    task.user_id = user_id
    with Session(engine) as session:
        session.add(task)
        session.commit()
        session.refresh(task)
        return task

@app.get("/api/{user_id}/tasks/{task_id}", response_model=Task)
def get_task(user_id: str, task_id: int):
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            raise HTTPException(status_code=404, detail="Task not found")
        return task

@app.put("/api/{user_id}/tasks/{task_id}", response_model=Task)
def update_task(user_id: str, task_id: int, task_update: Task):
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            raise HTTPException(status_code=404, detail="Task not found")

        # Update fields
        task.title = task_update.title
        task.description = task_update.description
        task.priority = task_update.priority
        task.due_date = task_update.due_date
        task.category = task_update.category
        task.completed = task_update.completed

        session.add(task)
        session.commit()
        session.refresh(task)
        return task

@app.delete("/api/{user_id}/tasks/{task_id}")
def delete_task(user_id: str, task_id: int):
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
             raise HTTPException(status_code=404, detail="Task not found")

        session.delete(task)
        session.commit()
        return {"status": "deleted"}

@app.patch("/api/{user_id}/tasks/{task_id}/complete", response_model=Task)
def toggle_complete(user_id: str, task_id: int):
    with Session(engine) as session:
        task = session.get(Task, task_id)
        if not task or task.user_id != user_id:
            raise HTTPException(status_code=404, detail="Task not found")

        task.completed = not task.completed
        session.add(task)
        session.commit()
        session.refresh(task)
        return task

