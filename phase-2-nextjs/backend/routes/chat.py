from fastapi import APIRouter, HTTPException
from backend.models import ChatRequest, ChatResponse
from backend.agent import process_chat

router = APIRouter()

@router.post("/{user_id}/chat", response_model=ChatResponse)
async def chat_endpoint(user_id: str, request: ChatRequest):
    try:
        response = await process_chat(user_id, request)
        return response
    except Exception as e:
        import traceback
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))
