import React, { useState, useEffect, useRef } from 'react';
import { Send, Bot, Plus, List, Edit, Trash, CheckCircle, Home, RefreshCcw } from 'lucide-react';
import AddTaskForm from './AddTaskForm';
import { sendChatMessage } from '../lib/api';
import { Message } from '../types';

const INITIAL_MESSAGE: Message = {
    user_id: 'default-user',
    conversation_id: 0,
    role: 'assistant',
    content: 'Hello! I’m your smart Todo AI. Add tasks, set reminders, and stay organized—how can I help?'
};

const QuickActions = ({ onAction }: { onAction: (prompt: string) => void }) => {
    const actions = [
        { icon: Plus, label: 'Add Task', prompt: 'Add a new task', color: 'text-[#0D9488] border-[#0D9488]' },
        { icon: List, label: 'View Tasks', prompt: 'Show all my tasks', color: 'text-blue-600 border-blue-600' },
        { icon: Edit, label: 'Update Task', prompt: 'I need to update a task', color: 'text-orange-500 border-orange-500' },
        { icon: Trash, label: 'Delete Task', prompt: 'I want to delete a task', color: 'text-red-500 border-red-500' },
        { icon: CheckCircle, label: 'Mark Complete', prompt: 'Mark a task as complete', color: 'text-green-600 border-green-600' }
    ];

    return (
        <div className="grid grid-cols-2 md:grid-cols-6 gap-3 p-4 animate-slideIn">
            {actions.map((action, idx) => (
                <button
                    key={idx}
                    onClick={() => onAction(action.prompt)}
                    className={`btn-action group ${action.color} hover:bg-gray-50 flex flex-col items-center justify-center gap-2 p-3 border-2 rounded-xl shadow-sm transition-all duration-200 md:col-span-2 ${idx === 3 ? 'md:col-start-2' : ''}`}
                >
                    <action.icon className={`w-6 h-6 ${action.color}`} />
                    <span className="text-xs font-semibold text-gray-700 group-hover:text-gray-900">{action.label}</span>
                </button>
            ))}
        </div>
    );
};

export default function Chat() {
    const [messages, setMessages] = useState<Message[]>([INITIAL_MESSAGE]);
    const [input, setInput] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [conversationId, setConversationId] = useState<number | undefined>();
    const messagesEndRef = useRef<HTMLDivElement>(null);

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    useEffect(() => {
        scrollToBottom();
    }, [messages, isLoading]);

    const handleSendMessage = async (text: string) => {
        if (!text.trim() || isLoading) return;

        // CRITICAL FIX: Intercept "Main menu" to reset the chat to the initial state
        if (['main menu', 'home', 'back to main menu'].includes(text.toLowerCase())) {
            handleReset();
            return;
        }

        const userMessage: Message = {
            user_id: 'default-user',
            conversation_id: conversationId || 0,
            role: 'user',
            content: text.trim()
        };

        setMessages(prev => [...prev, userMessage]);
        setInput('');
        setIsLoading(true);

        try {
            const response = await sendChatMessage('default-user', {
                message: userMessage.content,
                conversation_id: conversationId
            });

            if (response.conversation_id) {
                setConversationId(response.conversation_id);
            }

            const botMessage: Message = {
                user_id: 'default-user',
                conversation_id: response.conversation_id,
                role: 'assistant',
                content: response.response,
                tool_calls: response.tool_calls // Store tool calls if present
            };

            setMessages(prev => [...prev, botMessage]);
        } catch (error) {
            console.error('Failed to send message:', error);
            const errorMessage: Message = {
                user_id: 'default-user',
                conversation_id: conversationId || 0,
                role: 'assistant',
                content: error instanceof Error ? `Error: ${error.message}` : 'Sorry, I encountered an error. Please try again.'
            };
            setMessages(prev => [...prev, errorMessage]);
        } finally {
            setIsLoading(false);
        }
    };
    const handleReset = () => {
        setMessages([INITIAL_MESSAGE]);
        setConversationId(undefined);
    };

    const handleMainMenu = () => {
        handleSendMessage('Main menu');
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        handleSendMessage(input);
    };

    // Helper to parse suggestion chips from assistant response
    const parseSuggestedActions = (text: string) => {
        const lines = text.split('\n');
        const actions: { label: string, command: string }[] = [];

        // Regex to match "1️⃣ Add new task" or similar patterns
        // Matches: 1. Emoji/Number 2. Space 3. Text
        const regex = /^(?:[1-9]️⃣|➕|📝|✅|❓|✏️|🗑️|🏠)\s+(.+)$/;

        lines.forEach(line => {
            const match = line.trim().match(regex);
            if (match) {
                actions.push({
                    label: line.trim(),
                    command: match[1].trim() // The text part is the command
                });
            } else if (line.trim().startsWith('[') && line.includes(']')) {
                // Match "[➕ Add another]" format
                const bracketMatch = line.trim().match(/^\[(➕|📝|🏠)\s+(.+)\]$/);
                if (bracketMatch) {
                    actions.push({
                        label: line.trim().replace(/^\[|\]$/g, ''), // Remove brackets
                        command: bracketMatch[2].trim()
                    });
                }
            }
        });
        return actions;
    };

    return (
        <div className="flex flex-col h-screen bg-[#F0FDF4] font-sans text-gray-800">
            {/* Header */}
            <div className="bg-gradient-to-r from-[#0D9488] to-[#0F766E] p-4 shadow-lg flex items-center justify-between z-10">
                <div className="flex items-center gap-3">
                    <div className="bg-white/10 p-2 rounded-xl backdrop-blur-sm border border-white/20">
                        <Bot className="w-8 h-8 text-white" />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-white tracking-tight">Task Buddy</h1>
                        <p className="text-teal-100 text-xs font-medium opacity-90">Your Personal Task Helper</p>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    <button
                        onClick={handleMainMenu}
                        className="p-2 text-white/80 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-sm font-medium"
                        title="Main Menu"
                    >
                        <Home className="w-5 h-5" />
                        <span className="hidden md:inline">Menu</span>
                    </button>
                    <button
                        onClick={handleReset}
                        className="p-2 text-white/80 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-sm font-medium"
                        title="Reset Chat"
                    >
                        <RefreshCcw className="w-5 h-5" />
                        <span className="hidden md:inline">Reset</span>
                    </button>
                    <div className="flex items-center gap-2 bg-white/10 px-3 py-1.5 rounded-full border border-white/10">
                        <div className="w-2 h-2 rounded-full bg-green-400 animate-pulse-ring"></div>
                        <span className="text-teal-50 text-xs font-semibold tracking-wide">Online</span>
                    </div>
                </div>
            </div>

            {/* Messages Area */}
            <div className="flex-1 overflow-y-auto p-4 space-y-6 bg-gray-50/50 scroll-smooth">
                {messages.map((msg, idx) => (
                    <div className={`flex w-full ${msg.role === 'user' ? 'justify-end' : 'justify-start'} task-enter`} style={{ animationDelay: `${idx * 0.05}s` }}>
                        <div className={`flex max-w-[85%] ${msg.role === 'user' ? 'flex-row-reverse' : 'flex-row'} gap-3 items-end`}>
                            {msg.role !== 'user' && (
                                <div className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 shadow-sm bg-[#0D9488]">
                                    <Bot className="w-5 h-5 text-white" />
                                </div>
                            )}

                            <div className={`flex flex-col gap-1 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
                                <div
                                    className={`p-4 rounded-2xl shadow-sm leading-relaxed ${msg.role === 'user'
                                        ? 'bg-gradient-to-br from-[#0F766E] to-[#0D9488] text-white rounded-tr-none'
                                        : 'bg-white border border-gray-100 text-[#0F172A] rounded-tl-none'
                                        }`}
                                >
                                    <div className="whitespace-pre-wrap font-sans text-[0.95rem]">
                                        {msg.content.replace('<<SHOW_ADD_TASK_FORM>>', '').trim()}
                                    </div>

                                    {msg.content.includes('<<SHOW_ADD_TASK_FORM>>') && (
                                        <AddTaskForm
                                            onSubmit={(details) => handleSendMessage(details)}
                                            onCancel={() => handleSendMessage('Cancel')}
                                        />
                                    )}
                                </div>
                                {msg.role === 'assistant' && parseSuggestedActions(msg.content).length > 0 && !msg.content.includes('<<SHOW_ADD_TASK_FORM>>') && (
                                    <div className="flex flex-wrap gap-2 mt-2">
                                        {parseSuggestedActions(msg.content).map((action, i) => (
                                            <button
                                                key={i}
                                                onClick={() => handleSendMessage(action.command)}
                                                className="bg-white border border-[#0D9488] text-[#0D9488] hover:bg-teal-50 px-3 py-1.5 rounded-full text-xs font-medium shadow-sm transition-colors"
                                            >
                                                {action.label}
                                            </button>
                                        ))}
                                    </div>
                                )}
                                <div className={`text-[10px] px-1 font-medium ${msg.role === 'user' ? 'text-gray-400' : 'text-gray-400'
                                    }`}>
                                    {new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                                </div>
                            </div>
                        </div>
                    </div>
                ))}

                {/* Loading Indicator */}
                {isLoading && (
                    <div className="flex justify-start w-full task-enter">
                        <div className="flex max-w-[80%] flex-row gap-3 items-end">
                            <div className="w-8 h-8 rounded-full bg-[#0D9488] flex items-center justify-center flex-shrink-0 shadow-sm">
                                <Bot className="w-5 h-5 text-white" />
                            </div>
                            <div className="bg-white border border-gray-100 text-gray-700 rounded-2xl rounded-tl-none shadow-sm p-4 flex gap-1">
                                <div className="w-2 h-2 bg-[#0D9488] rounded-full typing-dot"></div>
                                <div className="w-2 h-2 bg-[#0D9488] rounded-full typing-dot"></div>
                                <div className="w-2 h-2 bg-[#0D9488] rounded-full typing-dot"></div>
                            </div>
                        </div>
                    </div>
                )}

                {/* Empty State / Quick Actions */}
                {messages.length === 1 && !isLoading && (
                    <div className="mt-8">
                        <p className="text-center text-gray-500 mb-4 text-sm font-medium">✨ Quick Actions</p>
                        <QuickActions onAction={handleSendMessage} />
                    </div>
                )}

                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <div className="p-4 bg-white border-t border-gray-100 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.02)]">
                <form onSubmit={handleSubmit} className="flex gap-3 items-center">
                    <input
                        type="text"
                        value={input}
                        onChange={(e) => setInput(e.target.value)}
                        placeholder="Type your message..."
                        className="input-field shadow-inner"
                        disabled={isLoading}
                    />
                    <button
                        type="submit"
                        disabled={!input.trim() || isLoading}
                        className="btn-primary p-3.5 rounded-xl disabled:opacity-50 transition-transform active:scale-95"
                    >
                        <Send className="w-5 h-5" />
                    </button>
                </form>
            </div>
        </div>
    );
}
