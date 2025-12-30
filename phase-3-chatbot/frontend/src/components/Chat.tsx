import React, { useState, useEffect, useRef } from 'react';
import { Send, Bot, Plus, List, Edit, Trash, CheckCircle, Home, RefreshCcw, User, ArrowRight, Languages } from 'lucide-react';
import AddTaskForm from './AddTaskForm';
import { sendChatMessage } from '../lib/api';
import { Message } from '../types';
import { translations, Language } from '../lib/translations';
import VoiceInput from './VoiceInput';




const QuickActions = ({ onAction, t, language }: { onAction: (prompt: string) => void, t: any, language: Language }) => {
    const actions = [
        { icon: Plus, label: t.addTask, prompt: t.addTaskPrompt, color: 'text-[#0D9488] border-[#0D9488]' },
        { icon: List, label: t.viewTasks, prompt: t.viewTasksPrompt, color: 'text-blue-600 border-blue-600' },
        { icon: Edit, label: t.updateTask, prompt: t.updateTaskPrompt, color: 'text-orange-500 border-orange-500' },
        { icon: Trash, label: t.deleteTask, prompt: t.deleteTaskPrompt, color: 'text-red-500 border-red-500' },
        { icon: CheckCircle, label: t.markComplete, prompt: t.markCompletePrompt, color: 'text-green-600 border-green-600' }
    ];

    return (
        <div className={`grid grid-cols-2 lg:grid-cols-5 gap-3 p-4 animate-slideIn ${language === 'ur' ? 'rtl' : 'ltr'}`}>
            {actions.map((action, idx) => (
                <button
                    key={idx}
                    onClick={() => onAction(action.prompt)}
                    className={`btn-action group ${action.color} hover:bg-gray-50 flex flex-col items-center justify-center gap-2 p-3 border-2 rounded-xl shadow-sm transition-all duration-200`}
                >
                    <action.icon className={`w-6 h-6 ${action.color}`} />
                    <span className="text-xs font-semibold text-gray-700 group-hover:text-gray-900 text-center">{action.label}</span>
                </button>
            ))}
        </div>
    );
};

export default function Chat() {
    const [userId, setUserId] = useState<string>('');
    const [isLoggedIn, setIsLoggedIn] = useState(false);
    const [loginName, setLoginName] = useState('');
    const [messages, setMessages] = useState<Message[]>([]);
    const [input, setInput] = useState('');
    const [isLoading, setIsLoading] = useState(false);
    const [conversationId, setConversationId] = useState<number | undefined>();
    const [language, setLanguage] = useState<Language>('en');

    const messagesEndRef = useRef<HTMLDivElement>(null);
    const [isEditingUser, setIsEditingUser] = useState(false);
    const [tempUserId, setTempUserId] = useState('');

    const scrollToBottom = () => {
        messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    };

    // Initialize Language
    useEffect(() => {
        const storedLang = localStorage.getItem('todo_language') as Language;
        if (storedLang && (storedLang === 'en' || storedLang === 'ur')) {
            setLanguage(storedLang);
        }
    }, []);

    const toggleLanguage = () => {
        const newLang = language === 'en' ? 'ur' : 'en';
        setLanguage(newLang);
        localStorage.setItem('todo_language', newLang);

        // Optionally update the welcome message if it's the only message and generic
        if (messages.length === 1 && messages[0].role === 'assistant') {
            const t = translations[newLang];
            const welcome = t.welcomeMessage.replace('{user}', userId);
            setMessages([{ ...messages[0], content: welcome }]);
        }
    };

    const t = translations[language];

    useEffect(() => {
        // Initialize User ID
        const storedUserId = localStorage.getItem('todo_user_id');
        if (storedUserId) {
            setUserId(storedUserId);
            setIsLoggedIn(true);
        }
    }, []);

    useEffect(() => {
        if (!userId) return;

        // Only set welcome message if empty (or reset logic handled elsewhere)
        if (messages.length === 0) {
            const initialMsg: Message = {
                user_id: userId,
                conversation_id: 0,
                role: 'assistant',
                content: t.welcomeMessage.replace('{user}', userId)
            };
            setMessages([initialMsg]);
        }
    }, [userId, language]); // Re-run when language changes effectively handled by toggle logic primarily, but this safety ensures correct logic.

    useEffect(() => {
        scrollToBottom();
    }, [messages, isLoading]);

    const handleLogin = (e: React.FormEvent) => {
        e.preventDefault();
        if (!loginName.trim()) return;

        const cleanId = loginName.trim();
        setUserId(cleanId);
        setIsLoggedIn(true);
        localStorage.setItem('todo_user_id', cleanId);

        // Set initial welcome message immediately upon login
        const initialMsg: Message = {
            user_id: cleanId,
            conversation_id: 0,
            role: 'assistant',
            content: t.welcomeMessage.replace('{user}', cleanId)
        };
        setMessages([initialMsg]);
    };

    const handleUpdateUserId = () => {
        if (tempUserId.trim()) {
            localStorage.setItem('todo_user_id', tempUserId.trim());
            setUserId(tempUserId.trim());
            setIsEditingUser(false);

            // Reset chat for new user with current language
            const initialMsg: Message = {
                user_id: tempUserId.trim(),
                conversation_id: 0,
                role: 'assistant',
                content: t.welcomeMessage.replace('{user}', tempUserId.trim())
            };
            setMessages([initialMsg]);
            setConversationId(undefined);
        }
    };

    const handleSendMessage = async (text: string) => {
        if (!text.trim() || isLoading || !userId) return;

        // Intercept "Main menu" commands in both languages
        const lowerText = text.toLowerCase();
        if (
            ['main menu', 'home', 'back to main menu'].includes(lowerText) ||
            ['مینو', 'مین مینو', 'واپس مین مینو'].includes(lowerText) ||
            text.includes('مین مینو') // broader match for Urdu
        ) {
            handleReset();
            return;
        }

        const userMessage: Message = {
            user_id: userId,
            conversation_id: conversationId || 0,
            role: 'user',
            content: text.trim()
        };

        setMessages(prev => [...prev, userMessage]);
        setInput('');
        setIsLoading(true);

        try {
            const response = await sendChatMessage(userId, {
                message: userMessage.content,
                conversation_id: conversationId,
                language: language
            });

            if (response.conversation_id) {
                setConversationId(response.conversation_id);
            }

            const botMessage: Message = {
                user_id: userId,
                conversation_id: response.conversation_id,
                role: 'assistant',
                content: response.response,
                tool_calls: response.tool_calls
            };

            setMessages(prev => [...prev, botMessage]);
        } catch (error) {
            console.error('Failed to send message:', error);
            const errorMessage: Message = {
                user_id: userId,
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
        const initialMsg: Message = {
            user_id: userId,
            conversation_id: 0,
            role: 'assistant',
            content: t.welcomeMessage.replace('{user}', userId)
        };
        setMessages([initialMsg]);
        setConversationId(undefined);
    };

    const handleMainMenu = () => {
        handleReset();
    };

    const handleSubmit = (e: React.FormEvent) => {
        e.preventDefault();
        handleSendMessage(input);
    };

    // Helper to parse suggestion chips from assistant response
    const parseSuggestedActions = (text: string) => {
        const lines = text.split('\n');
        const actions: { label: string, command: string }[] = [];

        // Regex to match "1️⃣ Add new task" or similar patterns or Urdu bullets
        // Matches: 1. Emoji/Number 2. Space 3. Text
        const regex = /^(?:[1-9]️⃣|➕|📝|✅|❓|✏️|🗑️|🏠)\s+(.+)$/;

        lines.forEach(line => {
            const match = line.trim().match(regex);
            if (match) {
                actions.push({
                    label: line.trim(),
                    command: match[1].trim()
                });
            } else if (line.trim().startsWith('[') && line.includes(']')) {
                // Match "[Bracketed Action]" format
                const bracketMatch = line.trim().match(/^\[(➕|📝|🏠)?\s*(.+)\]$/);
                if (bracketMatch) {
                    actions.push({
                        label: line.trim().replace(/^\[|\]$/g, ''),
                        command: bracketMatch[2].trim()
                    });
                }
            }
        });
        return actions;
    };

    if (!isLoggedIn) {
        return (
            <div className={`flex flex-col h-screen bg-[#F0FDF4] items-center justify-center p-4 ${language === 'ur' ? 'rtl' : 'ltr'}`} dir={language === 'ur' ? 'rtl' : 'ltr'}>
                {/* Language Toggle in Login Screen */}
                <div className="absolute top-4 right-4 group">
                    <button
                        onClick={toggleLanguage}
                        className="bg-white/50 backdrop-blur-sm p-2 rounded-lg hover:bg-white/80 transition-colors flex items-center gap-2 border border-teal-100"
                        title="Switch Language"
                    >
                        <Languages className="w-5 h-5 text-teal-700" />
                        <span className={`text-sm font-medium ${language === 'en' ? 'text-teal-900 font-bold' : 'text-teal-600'}`}>EN</span>
                        <span className="text-teal-300">|</span>
                        <span className={`text-sm font-medium ${language === 'ur' ? 'text-teal-900 font-bold' : 'text-teal-600'}`}>اردو</span>
                    </button>
                </div>

                <div className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md animate-slideIn text-center">
                    <div className="bg-[#0D9488]/10 w-16 h-16 rounded-full flex items-center justify-center mx-auto mb-6">
                        <Bot className="w-8 h-8 text-[#0D9488]" />
                    </div>
                    <h1 className="text-2xl font-bold text-gray-800 mb-2">{t.welcomeTitle}</h1>
                    <p className="text-gray-500 mb-8">{t.whatCallYou}</p>

                    <form onSubmit={handleLogin} className="space-y-4">
                        <input
                            type="text"
                            value={loginName}
                            onChange={(e) => setLoginName(e.target.value)}
                            placeholder={t.enterName}
                            className="w-full text-center text-lg px-4 py-3 border-2 border-gray-100 rounded-xl focus:border-[#0D9488] outline-none transition-colors"
                            autoFocus
                        />
                        <button
                            type="submit"
                            disabled={!loginName.trim()}
                            className="w-full bg-[#0D9488] text-white py-3.5 rounded-xl font-semibold hover:bg-[#0F766E] transition-colors disabled:opacity-50 flex items-center justify-center gap-2 group"
                        >
                            {t.startChatting}
                            <ArrowRight className={`w-5 h-5 transition-transform ${language === 'ur' ? 'group-hover:-translate-x-1 rotate-180' : 'group-hover:translate-x-1'}`} />
                        </button>
                    </form>
                </div>
            </div>
        );
    }

    return (
        <div
            className={`flex flex-col h-screen bg-[#F0FDF4] font-sans text-gray-800 ${language === 'ur' ? 'font-urdu' : ''}`}
            dir={language === 'ur' ? 'rtl' : 'ltr'}
        >
            {/* Header */}
            <div className="bg-gradient-to-r from-[#0D9488] to-[#0F766E] p-4 shadow-lg flex items-center justify-between z-10">
                <div className="flex items-center gap-3">
                    <div className="bg-white/10 p-2 rounded-xl backdrop-blur-sm border border-white/20">
                        <Bot className="w-8 h-8 text-white" />
                    </div>
                    <div>
                        <h1 className="text-xl font-bold text-white tracking-tight">{t.appName}</h1>
                        <p className="text-teal-100 text-xs font-medium opacity-90">{t.appTagline}</p>
                    </div>
                </div>
                <div className="flex items-center gap-2">
                    {/* User ID Display/Edit */}
                    <div className="relative group">
                        {isEditingUser ? (
                            <div className="flex items-center gap-1 bg-white rounded-lg p-1">
                                <input
                                    type="text"
                                    value={tempUserId}
                                    onChange={(e) => setTempUserId(e.target.value)}
                                    className="text-xs px-2 py-1 outline-none w-24 text-gray-700"
                                    placeholder="User ID"
                                    autoFocus
                                    onBlur={() => setIsEditingUser(false)}
                                    onKeyDown={(e) => e.key === 'Enter' && handleUpdateUserId()}
                                />
                                <button onClick={handleUpdateUserId} className="text-green-600 px-1"><CheckCircle className="w-4 h-4" /></button>
                            </div>
                        ) : (
                            <button
                                onClick={() => { setTempUserId(userId); setIsEditingUser(true); }}
                                className="p-2 text-white/60 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-xs font-medium"
                                title={`Current User: ${userId}`}
                            >
                                <User className="w-5 h-5" />
                                <span className="hidden md:inline max-w-[100px] truncate">{userId}</span>
                            </button>
                        )}
                    </div>

                    <div className="h-6 w-px bg-white/20 mx-1"></div>

                    {/* Language Toggle */}
                    <button
                        onClick={toggleLanguage}
                        className="p-2 text-white/80 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-xs font-medium border border-white/10"
                        title="Switch Language"
                    >
                        <span className={language === 'en' ? 'text-white font-bold' : 'text-teal-200'}>EN</span>
                        <span className="text-white/40">|</span>
                        <span className={language === 'ur' ? 'text-white font-bold' : 'text-teal-200'}>اردو</span>
                    </button>

                    <div className="h-6 w-px bg-white/20 mx-1"></div>

                    <button
                        onClick={handleMainMenu}
                        className="p-2 text-white/80 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-sm font-medium"
                        title={t.menu}
                    >
                        <Home className="w-5 h-5" />
                        <span className="hidden md:inline">{t.menu}</span>
                    </button>
                    <button
                        onClick={handleReset}
                        className="p-2 text-white/80 hover:text-white hover:bg-white/10 rounded-lg transition-colors flex items-center gap-1 text-sm font-medium"
                        title={t.reset}
                    >
                        <RefreshCcw className="w-5 h-5" />
                        <span className="hidden md:inline">{t.reset}</span>
                    </button>
                    <div className="flex items-center gap-2 bg-white/10 px-3 py-1.5 rounded-full border border-white/10">
                        <div className="w-2 h-2 rounded-full bg-green-400 animate-pulse-ring"></div>
                        <span className="text-teal-50 text-xs font-semibold tracking-wide">{t.online}</span>
                    </div>
                </div>
            </div>

            {/* Messages Area */}
            <div className="flex-1 overflow-y-auto p-4 space-y-6 bg-gray-50/50 scroll-smooth">
                {messages.map((msg, idx) => (
                    <div
                        key={idx}
                        className={`flex w-full ${msg.role === 'user' ? 'justify-end' : 'justify-start'} task-enter`}
                        style={{ animationDelay: `${idx * 0.05}s` }}
                    >
                        <div className={`flex max-w-[85%] ${msg.role === 'user' ? (language === 'ur' ? 'flex-row' : 'flex-row-reverse') : (language === 'ur' ? 'flex-row-reverse' : 'flex-row')} gap-3 items-end`}>
                            {msg.role !== 'user' && (
                                <div className="w-8 h-8 rounded-full flex items-center justify-center flex-shrink-0 shadow-sm bg-[#0D9488]">
                                    <Bot className="w-5 h-5 text-white" />
                                </div>
                            )}

                            <div className={`flex flex-col gap-1 ${msg.role === 'user' ? 'items-end' : 'items-start'}`}>
                                <div
                                    className={`p-4 rounded-2xl shadow-sm leading-relaxed text-start ${msg.role === 'user'
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
                                            onCancel={() => handleSendMessage(t.cancel)}
                                            t={t}
                                            language={language}
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
                        <div className={`flex max-w-[80%] ${language === 'ur' ? 'flex-row-reverse' : 'flex-row'} gap-3 items-end`}>
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
                        <p className="text-center text-gray-500 mb-4 text-sm font-medium">{t.quickActionsTitle}</p>
                        <QuickActions onAction={handleSendMessage} t={t} language={language} />
                    </div>
                )}

                <div ref={messagesEndRef} />
            </div>

            {/* Input Area */}
            <div className="p-4 bg-white border-t border-gray-100 shadow-[0_-4px_6px_-1px_rgba(0,0,0,0.02)]">
                <form onSubmit={handleSubmit} className="flex gap-3 items-center">
                    <div className="relative flex-1">
                        <input
                            type="text"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            placeholder={t.typeMessage}
                            className="input-field shadow-inner w-full pr-2"
                            disabled={isLoading}
                        />
                    </div>

                    <VoiceInput
                        onSpeechResult={(text) => setInput(prev => prev ? `${prev} ${text}` : text)}
                    />

                    <button
                        type="submit"
                        disabled={!input.trim() || isLoading}
                        className={`btn-primary p-3.5 rounded-xl disabled:opacity-50 transition-transform active:scale-95 ${language === 'ur' ? 'rotate-180' : ''}`}
                    >
                        <Send className="w-5 h-5" />
                    </button>
                </form>
            </div>
        </div>
    );
}
