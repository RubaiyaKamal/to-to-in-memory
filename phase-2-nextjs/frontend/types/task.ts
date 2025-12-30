export interface Task {
    id: number;
    user_id: string;
    title: string;
    description: string | null;
    completed: boolean;
    priority: string | null;
    due_date: string | null;
    category: string | null;
    created_at: string;
    updated_at: string;
}

export interface TaskCreate {
    title: string;
    description?: string;
    priority?: string;
    due_date?: string;
    category?: string;
}

export interface TaskUpdate {
    title?: string;
    description?: string;
    priority?: string;
    due_date?: string;
    category?: string;
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
