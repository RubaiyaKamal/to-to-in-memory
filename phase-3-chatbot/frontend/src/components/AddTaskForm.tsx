import React, { useState } from 'react';
import { Plus, Calendar, Flag, Tag } from 'lucide-react';
import { Language } from '../lib/translations';

interface AddTaskFormProps {
    onSubmit: (taskDetails: string) => void;
    onCancel: () => void;
    t: any;
    language: Language;
}

export default function AddTaskForm({ onSubmit, onCancel, t, language }: AddTaskFormProps) {
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
        // We use English keywords in the command so the backend (which expects English args for tools mostly) understands it,
        // OR we trust the backend agent to parse Urdu if we send Urdu.
        // However, the tool call `add_task` expects specific args.
        // The safest bet is to construct the command in a way the agent understands.
        // If the agent is in Urdu mode, it *should* understand "priority High" etc. even if mixed.
        // But to be safe, let's keep the internal command structure simple or English-like if hidden options.
        // ACTUALLY, the user creates the "command" hiddenly here.
        // Let's stick to the existing command construction for now as the Agent understands "Add task..."
        // If we change this to Urdu, we need to ensure Agent understands "کام شامل کریں ... ترجیح ..."
        // Given `agent.py` prompts, I should stick to the existing format or verify.
        // The PROMPT says: "If user says 'Buy milk high priority', add it..."
        // The form constructs strictly formatted text. Let's start by KEEPING the command construction in English for reliability,
        // since the user doesn't see this command string directly (it's sent to backend).
        // Wait, `onSubmit` calls `handleSendMessage` which shows the message to the user?
        // In `Chat.tsx`: `handleSendMessage` adds `userMessage` to UI.
        // So the user WILL see "Add task 'Title' description '...'".
        // This effectively breaks the illusion of Urdu if the user sees English text they didn't type.

        // FIX: We should probably construct the message in the User's language OR just send the JSON payload if possible.
        // But `handleSendMessage` takes text.
        // Let's format the command based on language so it looks natural in chat.

        let command = ``;
        if (language === 'ur') {
            command = `نیا کام "${title}"`;
            if (description) command += ` تفصیل "${description}"`;
            if (showPriority) command += ` ترجیح ${priority === 'High' ? 'زیادہ' : priority === 'Medium' ? 'درمیانی' : 'کم'}`;
            if (showDueDate && dueDate) command += ` آخری تاریخ ${dueDate}`;
            if (showCategory) command += ` زمرہ @${category}`;
        } else {
            command = `Add task "${title}"`;
            if (description) command += ` description "${description}"`;
            if (showPriority) command += ` priority ${priority}`;
            if (showDueDate && dueDate) command += ` due ${dueDate}`;
            if (showCategory) command += ` category @${category}`;
        }

        onSubmit(command);
    };

    return (
        <div className={`bg-white border border-gray-200 rounded-xl shadow-sm p-4 mt-2 w-full max-w-md animate-slideIn ${language === 'ur' ? 'rtl' : 'ltr'}`}>
            <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-2 text-[#0D9488]">
                    <Plus className="w-5 h-5" />
                    <span className="font-semibold text-sm">{t.addNewTask}</span>
                </div>
            </div>

            <form onSubmit={handleSubmit} className="space-y-3">
                {/* Title */}
                <div>
                    <input
                        type="text"
                        value={title}
                        onChange={(e) => setTitle(e.target.value)}
                        placeholder={t.taskTitle}
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
                        placeholder={t.descriptionOptional}
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
                                {t.addPriority}
                            </div>
                        </label>
                        {showPriority && (
                            <select
                                value={priority}
                                onChange={(e) => setPriority(e.target.value)}
                                className="text-xs border border-gray-200 rounded-md px-2 py-1 outline-none focus:border-[#0D9488] bg-white text-gray-700"
                            >
                                <option value="High">{t.high}</option>
                                <option value="Medium">{t.medium}</option>
                                <option value="Low">{t.low}</option>
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
                                {t.addDueDate}
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
                                {t.addCategory}
                            </div>
                        </label>
                        {showCategory && (
                            <input
                                type="text"
                                value={category}
                                onChange={(e) => setCategory(e.target.value)}
                                placeholder={t.egWork}
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
                        {t.createTask}
                    </button>
                    <button
                        type="button"
                        onClick={onCancel}
                        className="px-4 py-2 bg-gray-100 text-gray-600 rounded-lg text-sm font-medium hover:bg-gray-200 transition-colors"
                    >
                        {t.cancel}
                    </button>
                </div>
            </form>
        </div>
    );
}
