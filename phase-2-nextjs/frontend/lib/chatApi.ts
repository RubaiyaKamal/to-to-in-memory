// API client for phase-2 nextjs backend (including chatbot logic)

const API_URL = (process.env.NEXT_PUBLIC_API_URL || "http://localhost:8000").replace(/\/$/, "");

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

/**
 * Get JWT token from localStorage
 */
function getToken(): string | null {
    if (typeof window === "undefined") return null;
    return localStorage.getItem("auth_token");
}

/**
 * Get authorization headers with JWT token
 */
function getAuthHeaders(): HeadersInit {
    const token = getToken();
    if (!token) {
        throw new Error("Not authenticated");
    }
    return {
        "Authorization": `Bearer ${token}`,
        "Content-Type": "application/json",
    };
}

export async function sendChatMessage(
    userId: string,
    message: string,
    conversationId?: number,
    language: string = "en"
): Promise<ChatResponse> {
    const headers = getAuthHeaders();
    const response = await fetch(`${API_URL}/api/${userId}/chat`, {
        method: "POST",
        headers,
        body: JSON.stringify({
            message,
            conversation_id: conversationId,
            language,
        }),
    });

    if (!response.ok) {
        const errorText = await response.text();
        throw new Error(`Chat API error: ${response.status} ${errorText}`);
    }

    return response.json();
}
