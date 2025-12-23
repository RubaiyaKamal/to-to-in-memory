"""Chatbot communication endpoints."""

from fastapi import APIRouter, Depends, HTTPException
from sqlmodel import Session

from auth import verify_jwt
from db import get_session
from models import ChatRequest, ChatResponse
from agent import process_chat

router = APIRouter(tags=["chat"])

@router.post("/{user_id}/chat", response_model=ChatResponse)
async def chat_endpoint(
    user_id: str,
    request: ChatRequest,
    authenticated_user_id: str = Depends(verify_jwt),
):
    """
    Chat endpoint for interaction with Task Buddy AI.
    """
    # Verify user_id matches authenticated user
    if user_id != authenticated_user_id:
        raise HTTPException(status_code=403, detail="Forbidden")

    try:
        response = await process_chat(user_id, request)
        return response
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
