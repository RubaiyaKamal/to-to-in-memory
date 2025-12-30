"""
Stateless Chat Endpoint Implementation Reference
Complete implementation of the chat endpoint with database-backed state

File location: backend/app/routes/chat.py
"""

from fastapi import APIRouter, HTTPException, Depends
from sqlmodel import Session, select
from pydantic import BaseModel
from typing import Optional, List
from datetime import datetime

from app.models import Conversation, Message
from app.database import get_session
from app.middleware.auth import get_current_user_id
from app.agents.chat_agent import run_agent

router = APIRouter(prefix="/api/v1/chat", tags=["chat"])

class ChatRequest(BaseModel):
    conversation_id: Optional[int] = None
    message: str

class ChatResponse(BaseModel):
    conversation_id: int
    response: str

@router.post("", response_model=ChatResponse)
async def chat(
    request: ChatRequest,
    user_id: str = Depends(get_current_user_id),
    session: Session = Depends(get_session)
) -> ChatResponse:
    """
    Stateless chat endpoint.

    Flow:
    1. Get or create conversation (database)
    2. Load conversation history (database)
    3. Save user message (database)
    4. Run agent with history
    5. Save assistant response (database)
    6. Return response

    Server holds NO state - everything in database.
    """
    # Step 1: Get or create conversation
    if request.conversation_id:
        conversation = session.get(Conversation, request.conversation_id)
        if not conversation or conversation.user_id != user_id:
            raise HTTPException(status_code=404, detail="Conversation not found")
    else:
        # Create new conversation
        conversation = Conversation(user_id=user_id)
        session.add(conversation)
        session.commit()
        session.refresh(conversation)

    # Step 2: Load conversation history from database
    history_messages = session.exec(
        select(Message)
        .where(Message.conversation_id == conversation.id)
        .order_by(Message.created_at)
    ).all()

    conversation_history = [
        {"role": msg.role, "content": msg.content}
        for msg in history_messages
    ]

    # Step 3: Save user message to database
    user_msg = Message(
        conversation_id=conversation.id,
        user_id=user_id,
        role="user",
        content=request.message
    )
    session.add(user_msg)
    session.commit()

    # Step 4: Run agent with history
    assistant_response = await run_agent(
        user_id=user_id,
        user_message=request.message,
        conversation_history=conversation_history
    )

    # Step 5: Save assistant response to database
    assistant_msg = Message(
        conversation_id=conversation.id,
        user_id=user_id,
        role="assistant",
        content=assistant_response
    )
    session.add(assistant_msg)

    # Update conversation timestamp
    conversation.updated_at = datetime.utcnow()
    session.add(conversation)

    session.commit()

    # Step 6: Return response (server holds NO state)
    return ChatResponse(
        conversation_id=conversation.id,
        response=assistant_response
    )


# Additional endpoints for conversation management

@router.get("/conversations", response_model=List[dict])
async def list_conversations(
    user_id: str = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """List all conversations for the authenticated user."""
    conversations = session.exec(
        select(Conversation)
        .where(Conversation.user_id == user_id)
        .order_by(Conversation.updated_at.desc())
    ).all()

    return [
        {
            "id": conv.id,
            "created_at": conv.created_at,
            "updated_at": conv.updated_at,
            "message_count": len(conv.messages) if hasattr(conv, 'messages') else 0
        }
        for conv in conversations
    ]


@router.get("/conversations/{conversation_id}/messages", response_model=List[dict])
async def get_conversation_messages(
    conversation_id: int,
    user_id: str = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """Get all messages in a conversation."""
    conversation = session.get(Conversation, conversation_id)

    if not conversation or conversation.user_id != user_id:
        raise HTTPException(status_code=404, detail="Conversation not found")

    messages = session.exec(
        select(Message)
        .where(Message.conversation_id == conversation_id)
        .order_by(Message.created_at)
    ).all()

    return [
        {
            "id": msg.id,
            "role": msg.role,
            "content": msg.content,
            "created_at": msg.created_at
        }
        for msg in messages
    ]


@router.delete("/conversations/{conversation_id}")
async def delete_conversation(
    conversation_id: int,
    user_id: str = Depends(get_current_user_id),
    session: Session = Depends(get_session)
):
    """Delete a conversation and all its messages."""
    conversation = session.get(Conversation, conversation_id)

    if not conversation or conversation.user_id != user_id:
        raise HTTPException(status_code=404, detail="Conversation not found")

    # Delete all messages first
    messages = session.exec(
        select(Message).where(Message.conversation_id == conversation_id)
    ).all()

    for msg in messages:
        session.delete(msg)

    # Delete conversation
    session.delete(conversation)
    session.commit()

    return {"message": "Conversation deleted successfully"}
