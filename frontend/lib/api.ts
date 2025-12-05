import type { Task, TaskCreate, TaskUpdate } from "@/types/task";

const API_URL = process.env.NEXT_PUBLIC_API_URL;

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
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks`, { headers });
        if (!response.ok) {
            throw new Error("Failed to fetch tasks");
        }
        return response.json();
    },

    /**
     * Create a new task
     */
    async createTask(userId: string, data: TaskCreate): Promise<Task> {
        const headers = getAuthHeaders();
        const response = await fetch(`${API_URL}/api/${userId}/tasks`, {
            method: "POST",
            headers,
            body: JSON.stringify(data),
        });
        if (!response.ok) {
            throw new Error("Failed to create task");
        }
        return response.json();
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
};
