import type { Task, TaskCreate, TaskUpdate, TaskHistory } from "@/types/task";

const API_URL = process.env.NEXT_PUBLIC_API_URL || 'https://to-to-in-memory-backend.onrender.com';
console.log('🔍 API_URL loaded:', API_URL);

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

export const api = {
    /**
     * Get all tasks for user
     */
    async getTasks(userId: string): Promise<Task[]> {
        try {
            const headers = getAuthHeaders();
            console.log('Fetching tasks from:', `${API_URL}/api/${userId}/tasks`);
            const response = await fetch(`${API_URL}/api/${userId}/tasks`, { headers });
            console.log('Response status:', response.status);
            if (!response.ok) {
                const errorText = await response.text();
                console.error('Error response:', errorText);
                throw new Error(`Failed to fetch tasks: ${response.status}`);
            }
            return response.json();
        } catch (error) {
            console.error('Fetch error:', error);
            throw error;
        }
    },

    /**
     * Create a new task
     */
    async createTask(userId: string, data: TaskCreate): Promise<Task> {
        try {
            const headers = getAuthHeaders();
            console.log('Creating task at:', `${API_URL}/api/${userId}/tasks`);
            console.log('Task data:', data);
            const response = await fetch(`${API_URL}/api/${userId}/tasks`, {
                method: "POST",
                headers,
                body: JSON.stringify(data),
            });
            console.log('Create response status:', response.status);
            if (!response.ok) {
                const errorText = await response.text();
                console.error('Error response:', errorText);
                throw new Error(`Failed to create task: ${response.status}`);
            }
            return response.json();
        } catch (error) {
            console.error('Create task error:', error);
            throw error;
        }
    },

    /**
     * Get a specific task
     */
    async getTask(userId: string, taskId: number): Promise<Task> {
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}`, { headers });
        if (!response.ok) {
            throw new Error("Failed to fetch task");
        }
        return response.json();
    },

    /**
     * Update a task
     */
    async updateTask(userId: string, taskId: number, data: TaskUpdate): Promise<Task> {
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}`, {
            method: "PUT",
            headers,
            body: JSON.stringify(data),
        });
        if (!response.ok) {
            throw new Error("Failed to update task");
        }
        return response.json();
    },

    /**
     * Delete a task
     */
    async deleteTask(userId: string, taskId: number): Promise<void> {
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}`, {
            method: "DELETE",
            headers,
        });
        if (!response.ok) {
            throw new Error("Failed to delete task");
        }
    },

    /**
     * Toggle task completion status
     */
    async toggleComplete(userId: string, taskId: number): Promise<Task> {
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks/${taskId}/complete`, {
            method: "PATCH",
            headers,
        });
        if (!response.ok) {
            throw new Error("Failed to toggle task");
        }
        return response.json();
    },

    /**
     * Get task history for user
     */
    async getHistory(userId: string): Promise<TaskHistory[]> {
        try {
            const headers = getAuthHeaders();
            console.log('Fetching history from:', `${API_URL}/api/${userId}/history`);
            const response = await fetch(`${API_URL}/api/${userId}/history`, { headers });
            console.log('History response status:', response.status);
            if (!response.ok) {
                const errorText = await response.text();
                console.error('Error response:', errorText);
                throw new Error(`Failed to fetch history: ${response.status}`);
            }
            return response.json();
        } catch (error) {
            console.error('Fetch history error:', error);
            throw error;
        }
    },
};
