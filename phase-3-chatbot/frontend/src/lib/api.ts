export interface ChatRequest {
    message: string;
    conversation_id?: number;
    language?: string;
}

export interface ChatResponse {
    conversation_id: number;
    response: string;
    tool_calls?: any[];
}

const API_BASE_URL = 'http://127.0.0.1:8001';

export const sendChatMessage = async (userId: string, request: ChatRequest): Promise<ChatResponse> => {
    const response = await fetch(`${API_BASE_URL}/api/${userId}/chat`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
        },
        body: JSON.stringify(request),
    });

    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ detail: response.statusText }));
        throw new Error(errorData.detail || 'Failed to send message');
    }

    return response.json();
};

export const checkHealth = async (): Promise<boolean> => {
    try {
        const response = await fetch(`${API_BASE_URL}/api/health`);
        return response.ok;
    } catch {
        return false;
    }
};

export interface TaskHistory {
    id: number;
    task_id: number;
    user_id: string;
    action: string;
    field_name: string | null;
    old_value: string | null;
    new_value: string | null;
    changed_at: string;
}

export const getTaskHistory = async (userId: string): Promise<TaskHistory[]> => {
    const response = await fetch(`${API_BASE_URL}/api/${userId}/history`);

    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ detail: response.statusText }));
        throw new Error(errorData.detail || 'Failed to fetch history');
    }

    return response.json();
};
