export interface Task {
    id: number;
    user_id: string;
    title: string;
    description?: string;
    completed: boolean;
    created_at: string;
    updated_at: string;
}

export interface Conversation {
    id: number;
    user_id: string;
    created_at: string;
    updated_at: string;
}

export interface Message {
    id?: number;
    user_id: string;
    conversation_id: number;
    role: 'user' | 'assistant';
    content: string;
    created_at?: string;
    tool_calls?: ToolCall[];
}

export interface ChatRequest {
    message: string;
    conversation_id?: number;
}

export interface ToolCall {
    tool: string;
    input: Record<string, unknown>;
    output: Record<string, unknown>;
}

export interface ChatResponse {
    conversation_id: number;
    response: string;
    tool_calls: ToolCall[];
}

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
