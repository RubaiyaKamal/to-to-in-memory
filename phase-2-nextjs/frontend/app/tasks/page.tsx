"use client";

import { useState, useEffect } from "react";
import { useRouter } from "next/navigation";
import { isAuthenticated, getUser } from "@/lib/auth";
import { api } from "@/lib/api";
import { TaskForm } from "@/components/TaskForm";
import { TaskList } from "@/components/TaskList";
import { ActionButton } from "@/components/ActionButton";
import type { Task, TaskCreate } from "@/types/task";

type ActionView = "add" | "view" | "update" | "toggle" | "delete" | null;

export default function TasksPage() {
    const router = useRouter();
    const [tasks, setTasks] = useState<Task[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [activeView, setActiveView] = useState<ActionView>(null);

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
            setError(null);
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
        setActiveView("view");
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

    const handleUpdate = async (taskId: number, data: { title?: string; description?: string; priority?: string; due_date?: string; category?: string }) => {
        const user = getUser();
        if (!user) return;

        const updatedTask = await api.updateTask(user.id, taskId, data);
        setTasks(tasks.map((t) => (t.id === taskId ? updatedTask : t)));
    };

    if (!isAuthenticated()) {
        return null;
    }

    const completedCount = tasks.filter(t => t.completed).length;
    const pendingCount = tasks.length - completedCount;
    const overdueCount = tasks.filter(t => t.due_date && new Date(t.due_date) < new Date() && !t.completed).length;

    return (
        <div className="max-w-7xl mx-auto">
            {/* Header */}
            <div className="mb-8">
                <h1 className="text-4xl font-bold mb-2 bg-gradient-to-r from-[#134E4A] to-[#0D9488] bg-clip-text text-transparent">
                    My Tasks
                </h1>
                <p className="text-gray-600">Organize your day, achieve your goals</p>
            </div>

            {/* Action Buttons Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-4 mb-8">
                <ActionButton
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                        </svg>
                    }
                    title="Add Task"
                    description="Create new task"
                    count={tasks.length}
                    color="teal"
                    onClick={() => setActiveView(activeView === "add" ? null : "add")}
                    isActive={activeView === "add"}
                />

                <ActionButton
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                        </svg>
                    }
                    title="View Tasks"
                    description="See all tasks"
                    count={tasks.length}
                    color="blue"
                    onClick={() => setActiveView(activeView === "view" ? null : "view")}
                    isActive={activeView === "view"}
                />

                <ActionButton
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                        </svg>
                    }
                    title="Update Task"
                    description="Edit existing tasks"
                    count={tasks.length}
                    color="amber"
                    onClick={() => setActiveView(activeView === "update" ? null : "update")}
                    isActive={activeView === "update"}
                />

                <ActionButton
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                        </svg>
                    }
                    title="Complete/Pending"
                    description={`${completedCount} done, ${pendingCount} pending`}
                    count={overdueCount > 0 ? overdueCount : undefined}
                    color="green"
                    onClick={() => setActiveView(activeView === "toggle" ? null : "toggle")}
                    isActive={activeView === "toggle"}
                />

                <ActionButton
                    icon={
                        <svg className="w-6 h-6" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                        </svg>
                    }
                    title="Delete Task"
                    description="Remove tasks"
                    color="red"
                    onClick={() => setActiveView(activeView === "delete" ? null : "delete")}
                    isActive={activeView === "delete"}
                />
            </div>

            {/* Dynamic Content Area */}
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
                <>
                    {activeView === "add" && (
                        <div className="bg-white p-6 rounded-lg shadow-md border border-gray-100 mb-8">
                            <h2 className="text-xl font-semibold mb-4 text-[#0F172A] flex items-center gap-2">
                                <svg className="w-6 h-6 text-[#0D9488]" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                                </svg>
                                Create New Task
                            </h2>
                            <TaskForm onSubmit={handleCreateTask} />
                        </div>
                    )}

                    {activeView === "view" && (
                        <div>
                            <h2 className="text-xl font-semibold mb-4 text-[#0F172A]">
                                All Tasks ({tasks.length})
                            </h2>
                            <TaskList
                                tasks={tasks}
                                onToggleComplete={handleToggleComplete}
                                onDelete={handleDelete}
                                onUpdate={handleUpdate}
                            />
                        </div>
                    )}

                    {activeView === "update" && (
                        <div>
                            <h2 className="text-xl font-semibold mb-4 text-[#0F172A]">
                                Update Tasks
                            </h2>
                            <TaskList
                                tasks={tasks}
                                onToggleComplete={handleToggleComplete}
                                onDelete={handleDelete}
                                onUpdate={handleUpdate}
                            />
                        </div>
                    )}

                    {activeView === "toggle" && (
                        <div>
                            <h2 className="text-xl font-semibold mb-4 text-[#0F172A]">
                                Toggle Completion Status
                            </h2>
                            <TaskList
                                tasks={tasks}
                                onToggleComplete={handleToggleComplete}
                                onDelete={handleDelete}
                                onUpdate={handleUpdate}
                            />
                        </div>
                    )}

                    {activeView === "delete" && (
                        <div>
                            <h2 className="text-xl font-semibold mb-4 text-[#0F172A] flex items-center gap-2">
                                <svg className="w-6 h-6 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z" />
                                </svg>
                                Delete Tasks (Click delete button on tasks)
                            </h2>
                            <TaskList
                                tasks={tasks}
                                onToggleComplete={handleToggleComplete}
                                onDelete={handleDelete}
                                onUpdate={handleUpdate}
                            />
                        </div>
                    )}

                    {!activeView && tasks.length > 0 && (
                        <div className="text-center py-16 bg-gradient-to-br from-teal-50 to-blue-50 rounded-lg">
                            <svg className="w-24 h-24 mx-auto text-teal-500 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M13 10V3L4 14h7v7l9-11h-7z" />
                            </svg>
                            <h3 className="text-2xl font-bold text-gray-700 mb-2">Select an Action</h3>
                            <p className="text-gray-600">Choose one of the action buttons above to get started</p>
                        </div>
                    )}

                    {!activeView && tasks.length === 0 && (
                        <div className="text-center py-16 bg-white rounded-lg shadow-md">
                            <svg className="w-24 h-24 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                            </svg>
                            <h3 className="text-xl font-semibold text-gray-700 mb-2">No tasks yet!</h3>
                            <p className="text-gray-500 mb-4">Click "Add Task" button above to create your first task</p>
                        </div>
                    )}
                </>
            )}
        </div>
    );
}
