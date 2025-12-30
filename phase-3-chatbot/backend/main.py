import os
from pathlib import Path
from dotenv import load_dotenv

# Robustly load .env from the same directory as this file
env_path = Path(__file__).parent / '.env'
load_dotenv(dotenv_path=env_path)

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlmodel import Session, select

from database import create_db_and_tables, engine
from models import ChatRequest, ChatResponse, TaskHistory
from agent import process_chat

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://localhost:5173", "http://localhost:5174", "http://localhost:30080", "http://127.0.0.1:30080"],
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

@app.get("/api/{user_id}/history")
def get_history(user_id: str):
    """Get task history for user."""
    with Session(engine) as session:
        statement = select(TaskHistory).where(TaskHistory.user_id == user_id).order_by(TaskHistory.changed_at.desc())
        results = session.exec(statement).all()
        return [history.model_dump() for history in results]
