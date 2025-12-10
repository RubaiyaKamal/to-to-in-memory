import React, { useState } from 'react';
import { Plus, Calendar, Flag, Tag } from 'lucide-react';

interface AddTaskFormProps {
    onSubmit: (taskDetails: string) => void;
    onCancel: () => void;
}

export default function AddTaskForm({ onSubmit, onCancel }: AddTaskFormProps) {
    const [title, setTitle] = useState('');
    const [description, setDescription] = useState('');

    const [showPriority, setShowPriority] = useState(false);
    const [priority, setPriority] = useState('Medium');

    const [showDueDate, setShowDueDate] = useState(false);
    const [dueDate, setDueDate] = useState('');

    const [showCategory, setShowCategory] = useState(false);
    const [category, setCategory] = useState('work');

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        if (!title.trim()) return;

        // Construct the natural language command that the agent will process
        let command = `Add task "${title}"`;
        if (description) command += ` description "${description}"`;
        if (showPriority) command += ` priority ${priority}`;
        if (showDueDate && dueDate) command += ` due ${dueDate}`;
        if (showCategory) command += ` category @${category}`;

        onSubmit(command);
    };

    return (
        <div className="bg-white border border-gray-200 rounded-xl shadow-sm p-4 mt-2 w-full max-w-md animate-slideIn">
            <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2 text-[#0D9488]">
                    <Plus className="w-5 h-5" />
                    <span className="font-semibold text-sm">Add New Task</span>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="space-y-3">
                {/* Title */}
                <div>
                    <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        placeholder="Task Title"
                        className="w-full text-base font-medium px-3 py-2 border-b-2 border-gray-100 focus:border-[#0D9488] outline-none bg-transparent transition-colors placeholder-gray-400"
                        autoFocus
                    />
                </div>

                {/* Description */}
                <div>
                    <input
                        type="text"
                        value={description}
                        onChange={(e) => setDescription(e.target.value)}
                        placeholder="Description (optional)"
                        className="w-full text-sm px-3 py-1.5 border-b border-gray-100 focus:border-[#0D9488]/50 outline-none bg-transparent transition-colors placeholder-gray-400"
                    />
                </div>

                {/* Toggles */}
                <div className="flex flex-col gap-2 pt-2">
                    {/* Priority Toggle */}
                    <div className="flex items-center gap-2">
                        <label className="flex items-center gap-2 text-xs font-medium text-gray-600 cursor-pointer select-none">
                            <input
                                type="checkbox"
                                checked={showPriority}
                                onChange={(e) => setShowPriority(e.target.checked)}
                                className="w-4 h-4 rounded text-[#0D9488] focus:ring-[#0D9488] border-gray-300"
                            />
                            <div className="flex items-center gap-1">
                                <Flag className="w-3.5 h-3.5" />
                                Add Priority
                            </div>
                        </label>
                        {showPriority && (
                            <select
                                value={priority}
                                onChange={(e) => setPriority(e.target.value)}
                                className="text-xs border border-gray-200 rounded-md px-2 py-1 outline-none focus:border-[#0D9488] bg-white text-gray-700"
                            >
                                <option value="High">High</option>
                                <option value="Medium">Medium</option>
                                <option value="Low">Low</option>
                            </select>
                        )}
                    </div>

                    {/* Due Date Toggle */}
                    <div className="flex items-center gap-2">
                        <label className="flex items-center gap-2 text-xs font-medium text-gray-600 cursor-pointer select-none">
                            <input
                                type="checkbox"
                                checked={showDueDate}
                                onChange={(e) => setShowDueDate(e.target.checked)}
                                className="w-4 h-4 rounded text-[#0D9488] focus:ring-[#0D9488] border-gray-300"
                            />
                            <div className="flex items-center gap-1">
                                <Calendar className="w-3.5 h-3.5" />
                                Add Due Date
                            </div>
                        </label>
                        {showDueDate && (
                            <input
                                type="date"
                                value={dueDate}
                                onChange={(e) => setDueDate(e.target.value)}
                                className="text-xs border border-gray-200 rounded-md px-2 py-1 outline-none focus:border-[#0D9488] bg-white text-gray-700 font-sans"
                            />
                        )}
                    </div>

                    {/* Category Toggle */}
                    <div className="flex items-center gap-2">
                        <label className="flex items-center gap-2 text-xs font-medium text-gray-600 cursor-pointer select-none">
                            <input
                                type="checkbox"
                                checked={showCategory}
                                onChange={(e) => setShowCategory(e.target.checked)}
                                className="w-4 h-4 rounded text-[#0D9488] focus:ring-[#0D9488] border-gray-300"
                            />
                            <div className="flex items-center gap-1">
                                <Tag className="w-3.5 h-3.5" />
                                Add Category
                            </div>
                        </label>
                        {showCategory && (
                            <input
                                type="text"
                                value={category}
                                onChange={(e) => setCategory(e.target.value)}
                                placeholder="e.g. work"
                                className="text-xs border border-gray-200 rounded-md px-2 py-1 outline-none focus:border-[#0D9488] bg-white text-gray-700 w-24"
                            />
                        )}
                    </div>
                </div>

                {/* Action Buttons */}
                <div className="flex gap-2 pt-3 mt-1 border-t border-gray-50">
                    <button
                        type="submit"
                        disabled={!title.trim()}
                        className="flex-1 bg-[#0D9488] text-white py-2 rounded-lg text-sm font-semibold hover:bg-[#0F766E] transition-colors disabled:opacity-50 disabled:cursor-not-allowed flex items-center justify-center gap-2"
                    >
                        Create Task
                    </button>
                    <button
                        type="button"
                        onClick={onCancel}
                        className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors"
                    >
                        Cancel
                    </button>
                </div>
            </form>
        </div>
    );
}
