"use client";

import type { Task } from "@/types/task";
import { TaskItem } from "./TaskItem";

interface TaskListProps {
    tasks: Task[];
    onToggleComplete: (taskId: number) => Promise<void>;
    onDelete: (taskId: number) => Promise<void>;
    onUpdate?: (taskId: number, data: { title?: string; description?: string }) => Promise<void>;
}

export function TaskList({ tasks, onToggleComplete, onDelete, onUpdate }: TaskListProps) {
    if (tasks.length === 0) {
        return (
            <div className="text-center py-16 bg-white rounded-lg shadow-md">
                <div className="mb-4">
                    <svg className="w-24 h-24 mx-auto text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M9 5H7a2 2 0 00-2 2v12a2 2 0 002 2h10a2 2 0 002-2V7a2 2 0 00-2-2h-2M9 5a2 2 0 002 2h2a2 2 0 002-2M9 5a2 2 0 012-2h2a2 2 0 012 2" />
                    </svg>
                </div>
                <h3 className="text-xl font-semibold text-gray-700 mb-2">No tasks yet!</h3>
                <p className="text-gray-500">Create your first task to get started on your journey to productivity.</p>
            </div>
        );
    }

    const completedCount = tasks.filter(t => t.completed).length;
    const totalCount = tasks.length;
    const progressPercentage = (completedCount / totalCount) * 100;

    return (
        <div className="space-y-4">
            {/* Progress Bar */}
            <div className="bg-white p-4 rounded-lg shadow-md">
                <div className="flex justify-between items-center mb-2">
                    <span className="text-sm font-medium text-gray-700">Progress</span>
                    <span className="text-sm text-gray-600">{completedCount} of {totalCount} completed</span>
                </div>
                <div className="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                    <div
                        className="bg-gradient-to-r from-[#0D9488] to-[#06B6D4] h-3 rounded-full transition-all duration-500 ease-out"
                        style={{ width: `${progressPercentage}%` }}
                    />
                </div>
            </div>

            {/* Task List */}
            <div className="space-y-3">
                {tasks.map((task) => (
                    <TaskItem
                        key={task.id}
                        task={task}
                        onToggleComplete={onToggleComplete}
                        onDelete={onDelete}
                        onUpdate={onUpdate}
                    />
                ))}
            </div>
        </div>
    );
}
