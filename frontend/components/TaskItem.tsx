"use client";

import { useState } from "react";
import type { Task } from "@/types/task";

interface TaskItemProps {
    task: Task;
    onToggleComplete: (taskId: number) => Promise<void>;
    onDelete: (taskId: number) => Promise<void>;
    onUpdate?: (taskId: number, data: { title?: string; description?: string }) => Promise<void>;
}

export function TaskItem({ task, onToggleComplete, onDelete, onUpdate }: TaskItemProps) {
    const [isDeleting, setIsDeleting] = useState(false);
    const [isToggling, setIsToggling] = useState(false);
    const [isEditing, setIsEditing] = useState(false);
    const [editTitle, setEditTitle] = useState(task.title);
    const [editDescription, setEditDescription] = useState(task.description || "");
    const [showConfetti, setShowConfetti] = useState(false);

    const handleToggle = async () => {
        setIsToggling(true);
        try {
            await onToggleComplete(task.id);
            // Show confetti when completing a task
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
        setIsEditing(false);
    };

    if (isEditing) {
        return (
            <div className="card bg-[#E0F2FE] border-[#06B6D4]">
                <div className="space-y-3">
                    <div>
                        <input
                            type="text"
                            value={editTitle}
                            onChange={(e) => setEditTitle(e.target.value)}
                            className="input-field"
                            placeholder="Task title"
                            maxLength={200}
                        />
                    </div>
                    <div>
                        <textarea
                            value={editDescription}
                            onChange={(e) => setEditDescription(e.target.value)}
                            className="input-field"
                            placeholder="Task description (optional)"
                            rows={2}
                            maxLength={1000}
                        />
                    </div>
                    <div className="flex gap-2">
                        <button onClick={handleSaveEdit} className="btn-primary text-sm px-3 py-1">
                            Save
                        </button>
                        <button onClick={handleCancelEdit} className="btn-secondary text-sm px-3 py-1">
                            Cancel
                        </button>
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className={`card task-enter ${isDeleting ? "opacity-50" : ""} ${task.completed ? "bg-gray-50" : "bg-white"} relative overflow-hidden`}>
            {/* Confetti Effect */}
            {showConfetti && (
                <div className="absolute inset-0 pointer-events-none">
                    {[...Array(10)].map((_, i) => (
                        <div
                            key={i}
                            className="confetti absolute w-2 h-2 bg-[#0D9488] rounded-full"
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
                        className="h-5 w-5 text-[#0D9488] rounded border-gray-300 focus:ring-2 focus:ring-[#0D9488] cursor-pointer"
                        title={task.completed ? "Mark as incomplete" : "Mark as complete"}
                    />
                </div>

                {/* Task Content */}
                <div className="flex-1 min-w-0">
                    <h3 className={`font-semibold text-lg ${task.completed ? "line-through text-gray-500" : "text-[#0F172A]"}`}>
                        {task.title}
                    </h3>
                    {task.description && (
                        <p className={`text-sm mt-1 ${task.completed ? "text-gray-400" : "text-gray-600"}`}>
                            {task.description}
                        </p>
                    )}
                    <div className="flex items-center gap-4 mt-2">
                        <p className="text-xs text-gray-400 flex items-center gap-1">
                            <svg className="w-3 h-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
                            </svg>
                            {new Date(task.created_at).toLocaleDateString()}
                        </p>
                        {task.completed && (
                            <span className="text-xs bg-[#D1FAE5] text-[#065F46] px-2 py-1 rounded-full font-medium">
                                ✓ Completed
                            </span>
                        )}
                    </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-2">
                    {onUpdate && !task.completed && (
                        <button
                            onClick={() => setIsEditing(true)}
                            disabled={isDeleting || isToggling}
                            className="btn-edit text-sm px-3 py-1"
                            title="Edit task"
                        >
                            Edit
                        </button>
                    )}
                    <button
                        onClick={handleDelete}
                        disabled={isDeleting || isToggling}
                        className="btn-danger text-sm px-3 py-1"
                        title="Delete task"
                    >
                        {isDeleting ? "..." : "Delete"}
                    </button>
                </div>
            </div>
        </div>
    );
}
