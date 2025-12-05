"use client";

import { useState } from "react";
import type { TaskCreate } from "@/types/task";

interface TaskFormProps {
    onSubmit: (data: TaskCreate) => Promise<void>;
}

export function TaskForm({ onSubmit }: TaskFormProps) {
    const [title, setTitle] = useState("");
    const [description, setDescription] = useState("");
    const [isSubmitting, setIsSubmitting] = useState(false);
    const [error, setError] = useState<string | null>(null);
    const [isExpanded, setIsExpanded] = useState(false);

    const titleLength = title.length;
    const descLength = description.length;
    const titleColor = titleLength > 180 ? "text-red-500" : titleLength > 150 ? "text-yellow-500" : "text-gray-500";
    const descColor = descLength > 900 ? "text-red-500" : descLength > 800 ? "text-yellow-500" : "text-gray-500";

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!title.trim()) {
            setError("Title is required");
            return;
        }

        if (title.length > 200) {
            setError("Title must be 200 characters or less");
            return;
        }

        setIsSubmitting(true);
        setError(null);

        try {
            await onSubmit({
                title: title.trim(),
                description: description.trim() || undefined,
            });
            // Clear form on success
            setTitle("");
            setDescription("");
            setIsExpanded(false);
        } catch (err) {
            setError(err instanceof Error ? err.message : "Failed to create task");
        } finally {
            setIsSubmitting(false);
        }
    };

    if (!isExpanded) {
        return (
            <button
                onClick={() => setIsExpanded(true)}
                className="w-full btn-primary flex items-center justify-center gap-2 py-3"
            >
                <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                New Task
            </button>
        );
    }

    return (
        <form onSubmit={handleSubmit} className="space-y-4 task-enter">
            {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg">
                    {error}
                </div>
            )}

            <div>
                <label htmlFor="title" className="block text-sm font-medium text-gray-700 mb-1">
                    Title <span className="text-[#E11D48]">*</span>
                </label>
                <div className="relative">
                    <div className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-400">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z" />
                        </svg>
                    </div>
                    <input
                        type="text"
                        id="title"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        className="input-field pl-10"
                        placeholder="Enter task title"
                        disabled={isSubmitting}
                        maxLength={200}
                    />
                </div>
                <p className={`text-xs mt-1 ${titleColor} transition-colors duration-200`}>{titleLength}/200</p>
            </div>

            <div>
                <label htmlFor="description" className="block text-sm font-medium text-gray-700 mb-1">
                    Description (optional)
                </label>
                <div className="relative">
                    <div className="absolute left-3 top-3 text-gray-400">
                        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z" />
                        </svg>
                    </div>
                    <textarea
                        id="description"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        className="input-field pl-10"
                        placeholder="Enter task description"
                        rows={3}
                        disabled={isSubmitting}
                        maxLength={1000}
                    />
                </div>
                <p className={`text-xs mt-1 ${descColor} transition-colors duration-200`}>{descLength}/1000</p>
            </div>

            <div className="flex gap-2">
                <button type="submit" className="btn-primary flex-1" disabled={isSubmitting}>
                    {isSubmitting ? "Creating..." : "Create Task"}
                </button>
                <button
                    type="button"
                    onClick={() => {
                        setTitle("");
                        setDescription("");
                        setIsExpanded(false);
                    }}
                    className="btn-secondary px-6"
                    disabled={isSubmitting}
                >
                    Cancel
                </button>
            </div>
        </form>
    );
}
