"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { isAuthenticated, getUser } from "@/lib/auth";
import { api } from "@/lib/api";
import { TaskForm } from "@/components/TaskForm";
import { TaskList } from "@/components/TaskList";
import type { Task, TaskCreate } from "@/types/task";

export default function TasksPage() {
    const router = useRouter();
    const [tasks, setTasks] = useState<Task[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (!isAuthenticated()) {
            router.push("/signin");
            return;
        }
        loadTasks();
    }, [router]);

    const loadTasks = async () => {
        try {
            const user = getUser();
            if (!user) return;

            const data = await api.getTasks(user.id);
            setTasks(data);
            setError(null); // Clear any previous errors on success
        } catch (err) {
            setError("Failed to load tasks");
        } finally {
            setIsLoading(false);
        }
    };

    const handleCreateTask = async (data: TaskCreate) => {
        const user = getUser();
        if (!user) return;

        const newTask = await api.createTask(user.id, data);
        setTasks([newTask, ...tasks]);
    };

    const handleToggleComplete = async (taskId: number) => {
        const user = getUser();
        if (!user) return;

        const updatedTask = await api.toggleComplete(user.id, taskId);
        setTasks(tasks.map((t) => (t.id === taskId ? updatedTask : t)));
    };

    const handleDelete = async (taskId: number) => {
        const user = getUser();
        if (!user) return;

        await api.deleteTask(user.id, taskId);
        setTasks(tasks.filter((t) => t.id !== taskId));
    };

    const handleUpdate = async (taskId: number, data: { title?: string; description?: string }) => {
        const user = getUser();
        if (!user) return;

        const updatedTask = await api.updateTask(user.id, taskId, data);
        setTasks(tasks.map((t) => (t.id === taskId ? updatedTask : t)));
    };

    if (!isAuthenticated()) {
        return null;
    }

    return (
        <div className="max-w-4xl mx-auto">
            <div className="mb-8">
                <h1 className="text-4xl font-bold mb-2 bg-gradient-to-r from-[#134E4A] to-[#0D9488] bg-clip-text text-transparent">
                    My Tasks
                </h1>
                <p className="text-gray-600">Organize your day, achieve your goals</p>
            </div>

            <div className="mb-8 bg-white p-6 rounded-lg shadow-md border border-gray-100">
                <h2 className="text-xl font-semibold mb-4 text-[#0F172A] flex items-center gap-2">
                    <svg className="w-6 h-6 text-[#0D9488]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                    Create New Task
                </h2>
                <TaskForm onSubmit={handleCreateTask} />
            </div>

            <div>
                <h2 className="text-xl font-semibold mb-4 text-[#0F172A]">
                    All Tasks ({tasks.length})
                </h2>

                {error && (
                    <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
                        {error}
                    </div>
                )}

                {isLoading ? (
                    <div className="text-center py-12 bg-white rounded-lg shadow-md">
                        <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-[#0D9488] mx-auto"></div>
                        <p className="mt-4 text-gray-600">Loading tasks...</p>
                    </div>
                ) : (
                    <TaskList
                        tasks={tasks}
                        onToggleComplete={handleToggleComplete}
                        onDelete={handleDelete}
                        onUpdate={handleUpdate}
                    />
                )}
            </div>
        </div>
    );
}
