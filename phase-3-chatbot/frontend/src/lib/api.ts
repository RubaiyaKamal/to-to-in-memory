import { ChatRequest, ChatResponse } from '../types';

const API_BASE_URL = 'http://localhost:8000/api';

export const sendChatMessage = async (userId: string, request: ChatRequest): Promise<ChatResponse> => {
    const response = await fetch(`${API_BASE_URL}/${userId}/chat`, {
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
        const response = await fetch(`${API_BASE_URL}/health`);
        return response.ok;
    } catch {
        return false;
    }
};
