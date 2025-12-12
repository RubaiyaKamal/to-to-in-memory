"use client";

import { useState } from "react";
import type { Task } from "@/types/task";

interface TaskItemProps {
    task: Task;
    onToggleComplete: (taskId: number) => Promise<void>;
    onDelete: (taskId: number) => Promise<void>;
    onUpdate?: (taskId: number, data: { title?: string; description?: string; priority?: string; due_date?: string; category?: string }) => Promise<void>;
}

export function TaskItem({ task, onToggleComplete, onDelete, onUpdate }: TaskItemProps) {
    const [isDeleting, setIsDeleting] = useState(false);
    const [isToggling, setIsToggling] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [editTitle, setEditTitle] = useState(task.title);
    const [editDescription, setEditDescription] = useState(task.description || "");
    const [editPriority, setEditPriority] = useState(task.priority || "");
    const [editDueDate, setEditDueDate] = useState(task.due_date ? task.due_date.split('T')[0] : "");
    const [editCategory, setEditCategory] = useState(task.category || "");
    const [showConfetti, setShowConfetti] = useState(false);

    const handleToggle = async () => {
        setIsToggling(true);
        try {
            await onToggleComplete(task.id);
            if (!task.completed) {
                setShowConfetti(true);
                setTimeout(() => setShowConfetti(false), 1000);
            }
        } finally {
            setIsToggling(false);
        }
    };

    const handleDelete = async () => {
        if (!confirm("Are you sure you want to delete this task?")) return;

        setIsDeleting(true);
        try {
            await onDelete(task.id);
        } catch {
            setIsDeleting(false);
        }
    };

    const handleSaveEdit = async () => {
        if (onUpdate && editTitle.trim()) {
            try {
                await onUpdate(task.id, {
                    title: editTitle.trim(),
                    description: editDescription.trim() || undefined,
                    priority: editPriority || undefined,
                    due_date: editDueDate || undefined,
                    category: editCategory.trim() || undefined,
                });
                setIsEditing(false);
            } catch (err) {
                alert("Failed to update task");
            }
        }
    };

    const handleCancelEdit = () => {
        setEditTitle(task.title);
        setEditDescription(task.description || "");
        setEditPriority(task.priority || "");
        setEditDueDate(task.due_date ? task.due_date.split('T')[0] : "");
        setEditCategory(task.category || "");
        setIsEditing(false);
    };

    // Helper functions
    const getPriorityColor = (priority: string | null) => {
        if (!priority) return "";
        switch (priority.toLowerCase()) {
            case "high":
                return "bg-red-100 text-red-700 border-red-200";
            case "medium":
                return "bg-amber-100 text-amber-700 border-amber-200";
            case "low":
                return "bg-green-100 text-green-700 border-green-200";
            default:
                return "bg-gray-100 text-gray-700 border-gray-200";
        }
    };

    const isOverdue = task.due_date && new Date(task.due_date) < new Date() && !task.completed;
    const isDueSoon = task.due_date && new Date(task.due_date) <= new Date(Date.now() + 24 * 60 * 60 * 1000) && !task.completed;

    if (isEditing) {
        return (
            <div className="bg-blue-50 border-2 border-blue-300 rounded-lg p-4 shadow-md">
                <div className="space-y-3">
                    <input
                        type="text"
                        value={editTitle}
                        onChange={(e) => setEditTitle(e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="Task title"
                        maxLength={200}
                    />
                    <textarea
                        value={editDescription}
                        onChange={(e) => setEditDescription(e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="Task description (optional)"
                        rows={2}
                        maxLength={1000}
                    />
                    <div className="grid grid-cols-2 gap-3">
                        <select
                            value={editPriority}
                            onChange={(e) => setEditPriority(e.target.value)}
                            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        >
                            <option value="">No priority</option>
                            <option value="Low">Low</option>
                            <option value="Medium">Medium</option>
                            <option value="High">High</option>
                        </select>
                        <input
                            type="date"
                            value={editDueDate}
                            onChange={(e) => setEditDueDate(e.target.value)}
                            className="px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        />
                    </div>
                    <input
                        type="text"
                        value={editCategory}
                        onChange={(e) => setEditCategory(e.target.value)}
                        className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                        placeholder="Category (optional)"
                        maxLength={100}
                    />
                    <div className="flex gap-2">
                        <button onClick={handleSaveEdit} className="bg-blue-500 hover:bg-blue-600 text-white font-semibold px-4 py-2 rounded-lg transition-colors">
                            Save
                        </button>
                        <button onClick={handleCancelEdit} className="bg-gray-300 hover:bg-gray-400 text-gray-700 font-semibold px-4 py-2 rounded-lg transition-colors">
                            Cancel
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={`border rounded-lg p-4 shadow-md transition-all duration-300 hover:shadow-lg ${isDeleting ? "opacity-50" : ""} ${task.completed ? "bg-gray-50 border-gray-300" : "bg-white border-gray-200"} relative overflow-hidden`}>
            {/* Confetti Effect */}
            {showConfetti && (
                <div className="absolute inset-0 pointer-events-none">
                    {[...Array(10)].map((_, i) => (
                        <div
                            key={i}
                            className="absolute w-2 h-2 bg-teal-500 rounded-full animate-ping"
                            style={{
                                left: `${Math.random() * 100}%`,
                                top: "50%",
                                animationDelay: `${i * 0.1}s`,
                            }}
                        />
                    ))}
                </div>
            )}

            <div className="flex items-start gap-3">
                {/* Checkbox */}
                <div className="flex items-center pt-1">
                    <input
                        type="checkbox"
                        checked={task.completed}
                        onChange={handleToggle}
                        disabled={isToggling || isDeleting}
                        className="h-5 w-5 text-teal-600 rounded border-gray-300 focus:ring-2 focus:ring-teal-500 cursor-pointer"
                        title={task.completed ? "Mark as incomplete" : "Mark as complete"}
                    />
                </div>

                {/* Task Content */}
                <div className="flex-1 min-w-0">
                    <h3 className={`font-semibold text-lg ${task.completed ? "line-through text-gray-500" : "text-gray-900"}`}>
                        {task.title}
                    </h3>

                    {task.description && (
                        <p className={`text-sm mt-1 ${task.completed ? "text-gray-400" : "text-gray-600"}`}>
                            {task.description}
                        </p>
                    )}

                    {/* Badges Row */}
                    <div className="flex flex-wrap items-center gap-2 mt-3">
                        {/* Priority Badge */}
                        {task.priority && (
                            <span className={`text-xs px-2 py-1 rounded-full font-medium border ${getPriorityColor(task.priority)}`}>
                                {task.priority}
                            </span>
                        )}

                        {/* Category Badge */}
                        {task.category && (
                            <span className="text-xs px-2 py-1 rounded-full font-medium bg-purple-100 text-purple-700 border border-purple-200">
                                🏷️ {task.category}
                            </span>
                        )}

                        {/* Due Date Badge */}
                        {task.due_date && (
                            <span className={`text-xs px-2 py-1 rounded-full font-medium flex items-center gap-1 ${isOverdue ? "bg-red-100 text-red-700 border border-red-200" :
                                    isDueSoon ? "bg-orange-100 text-orange-700 border border-orange-200" :
                                        "bg-blue-100 text-blue-700 border border-blue-200"
                                }`}>
                                <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                                </svg>
                                {new Date(task.due_date).toLocaleDateString()}
                                {isOverdue && " (Overdue)"}
                                {isDueSoon && !isOverdue && " (Due Soon)"}
                            </span>
                        )}

                        {/* Completed Badge */}
                        {task.completed && (
                            <span className="text-xs bg-green-100 text-green-700 px-2 py-1 rounded-full font-medium border border-green-200">
                                ✓ Completed
                            </span>
                        )}

                        {/* Created Date */}
                        <span className="text-xs text-gray-400 flex items-center gap-1">
                            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            Created {new Date(task.created_at).toLocaleDateString()}
                        </span>
                    </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-2">
                    {onUpdate && !task.completed && (
                        <button
                            onClick={() => setIsEditing(true)}
                            disabled={isDeleting || isToggling}
                            className="bg-amber-500 hover:bg-amber-600 text-white font-semibold px-3 py-1 rounded-lg transition-colors text-sm disabled:opacity-50"
                            title="Edit task"
                        >
                            Edit
                        </button>
                    )}
                    <button
                        onClick={handleDelete}
                        disabled={isDeleting || isToggling}
                        className="bg-red-500 hover:bg-red-600 text-white font-semibold px-3 py-1 rounded-lg transition-colors text-sm disabled:opacity-50"
                        title="Delete task"
                    >
                        {isDeleting ? "..." : "Delete"}
                    </button>
                </div>
            </div>
        </div>
    );
}
