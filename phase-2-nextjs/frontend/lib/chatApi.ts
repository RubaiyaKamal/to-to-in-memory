// API client for phase-3 chatbot backend

const CHAT_API_URL = "http://localhost:8001/api";

export interface ChatMessage {
    message: string;
    conversation_id?: number;
    language?: string;
}

export interface ChatResponse {
    conversation_id: number;
    response: string;
    tool_calls?: Array<{
        name: string;
        args: Record<string, any>;
    }>;
}

export async function sendChatMessage(
    userId: string,
    message: string,
    conversationId?: number,
    language: string = "en"
): Promise<ChatResponse> {
    const response = await fetch(`${CHAT_API_URL}/${userId}/chat`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
        },
        body: JSON.stringify({
            message,
            conversation_id: conversationId,
            language,
        }),
    });

    if (!response.ok) {
        throw new Error(`Chat API error: ${response.statusText}`);
    }

    return response.json();
}
