"use client";

import { useState, useEffect, useRef } from "react";
import { Bot, X, Send, Globe, RotateCcw } from "lucide-react";
import { sendChatMessage } from "@/lib/chatApi";
import { getUser } from "@/lib/auth";

interface TaskFormData {
    title: string;
    description: string;
    priority: string;
    due_date: string;
    category: string;
}

export function FloatingChatbot() {
    const [isOpen, setIsOpen] = useState(false);
    const [messages, setMessages] = useState<{ text: string; isUser: boolean }[]>([]);
    const [inputMessage, setInputMessage] = useState("");
    const [isLoading, setIsLoading] = useState(false);
    const [conversationId, setConversationId] = useState<number | undefined>();
    const [language, setLanguage] = useState<"en" | "ur">("en");
    const [showTaskForm, setShowTaskForm] = useState(false);
    const [taskFormData, setTaskFormData] = useState<TaskFormData>({
        title: "",
        description: "",
        priority: "",
        due_date: "",
        category: ""
    });
    const messagesEndRef = useRef<HTMLDivElement>(null);

    const getWelcomeMessage = () => {
        return language === "en"
            ? "👋 **Welcome to Task Assistant!**\n\nI can help you manage your tasks. What would you like to do?\n\n• Add a new task\n• View my tasks\n• Complete a task\n• Update a task\n• Delete a task\n• Ask about my schedule\n\nJust type what you need or click a suggestion!"
            : "👋 **ٹاسک اسسٹنٹ میں خوش آمدید!**\n\nمیں آپ کے کاموں کو منظم کرنے میں مدد کر سکتا ہوں۔ آپ کیا کرنا چاہیں گے؟\n\n• کام شامل کریں\n• کام دیکھیں\n• کام مکمل کریں\n• کام اپ ڈیٹ کریں\n• کام حذف کریں\n• میرے شیڈول کے بارے میں پوچھیں\n\nبس لکھیں کہ آپ کو کیا چاہیے!";
    };

    // Initialize with welcome message
    useEffect(() => {
        if (messages.length === 0) {
            setMessages([{ text: getWelcomeMessage(), isUser: false }]);
        }
    }, [language]);

    // Auto-scroll to bottom
    useEffect(() => {
        messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
    }, [messages, showTaskForm]);

    const handleSendMessage = async () => {
        if (!inputMessage.trim() || isLoading) return;

        const userMessage = inputMessage;

        // Check if user wants main menu
        const mainMenuKeywords = language === "en"
            ? ["main menu", "back to main menu", "menu", "start", "home"]
            : ["مین مینو", "مینو", "واپس"];

        const isMainMenuRequest = mainMenuKeywords.some(keyword =>
            userMessage.toLowerCase().includes(keyword)
        );

        if (isMainMenuRequest) {
            setInputMessage("");
            handleBackToMenu();
            return;
        }

        // Check if user wants to add a task
        const addTaskKeywords = language === "en"
            ? ["add task", "new task", "create task"]
            : ["کام شامل", "نیا کام"];

        const isAddTaskRequest = addTaskKeywords.some(keyword =>
            userMessage.toLowerCase().includes(keyword)
        );

        if (isAddTaskRequest) {
            setMessages([...messages, { text: userMessage, isUser: true }]);
            setInputMessage("");
            setShowTaskForm(true);
            return;
        }

        // Add user message immediately
        const newMessages = [...messages, { text: userMessage, isUser: true }];
        setMessages(newMessages);
        setInputMessage("");
        setIsLoading(true);

        try {
            // Get user ID from auth
            const user = getUser();
            const userId = user?.id || "guest";

            // Call phase-3 chatbot API
            const response = await sendChatMessage(userId, userMessage, conversationId, language);

            // Update conversation ID
            if (!conversationId) {
                setConversationId(response.conversation_id);
            }

            // Clean up response - remove special markers
            let cleanedResponse = response.response
                .replace(/<<SHOW_ADD_TASK_FORM>>/g, "")
                .replace(/<<[^>]+>>/g, "")
                .trim();

            // Add bot response
            setMessages([...newMessages, { text: cleanedResponse, isUser: false }]);
        } catch (error) {
            console.error("Chat error:", error);
            setMessages([
                ...newMessages,
                { text: "Sorry, I encountered an error. Please try again or check if the backend is running.", isUser: false }
            ]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleTaskFormSubmit = async (e: React.FormEvent) => {
        e.preventDefault();

        if (!taskFormData.title.trim()) {
            alert(language === "en" ? "Please enter a task title" : "براہ کرم کام کا عنوان درج کریں");
            return;
        }

        setIsLoading(true);
        setShowTaskForm(false);

        try {
            const user = getUser();
            const userId = user?.id || "guest";

            // Create task message for AI
            const taskMessage = `Add task: ${taskFormData.title}${taskFormData.description ? `, description: ${taskFormData.description}` : ""
                }${taskFormData.priority ? `, priority: ${taskFormData.priority}` : ""
                }${taskFormData.due_date ? `, due date: ${taskFormData.due_date}` : ""
                }${taskFormData.category ? `, category: ${taskFormData.category}` : ""
                }`;

            // Add user message
            const newMessages = [...messages, { text: `Creating task: ${taskFormData.title}`, isUser: true }];
            setMessages(newMessages);

            // Call AI to create task
            const response = await sendChatMessage(userId, taskMessage, conversationId, language);

            if (!conversationId) {
                setConversationId(response.conversation_id);
            }

            let cleanedResponse = response.response
                .replace(/<<SHOW_ADD_TASK_FORM>>/g, "")
                .replace(/<<[^>]+>>/g, "")
                .trim();

            setMessages([...newMessages, { text: cleanedResponse, isUser: false }]);

            // Reset form
            setTaskFormData({
                title: "",
                description: "",
                priority: "",
                due_date: "",
                category: ""
            });
        } catch (error) {
            console.error("Task creation error:", error);
            setMessages([
                ...messages,
                { text: "Failed to create task. Please try again.", isUser: false }
            ]);
        } finally {
            setIsLoading(false);
        }
    };

    const handleKeyPress = (e: React.KeyboardEvent) => {
        if (e.key === "Enter" && !e.shiftKey) {
            e.preventDefault();
            handleSendMessage();
        }
    };

    const toggleLanguage = () => {
        const newLang = language === "en" ? "ur" : "en";
        setLanguage(newLang);
        setMessages([{ text: getWelcomeMessage(), isUser: false }]);
        setConversationId(undefined);
        setShowTaskForm(false);
    };

    const handleBackToMenu = () => {
        setMessages([{ text: getWelcomeMessage(), isUser: false }]);
        setShowTaskForm(false);
        setInputMessage("");
    };

    const handleReset = () => {
        setMessages([{ text: getWelcomeMessage(), isUser: false }]);
        setConversationId(undefined);
        setShowTaskForm(false);
        setInputMessage("");
        setTaskFormData({
            title: "",
            description: "",
            priority: "",
            due_date: "",
            category: ""
        });
    };

    const handleQuickAction = (action: string) => {
        if (action.toLowerCase().includes("add") || action.includes("شامل")) {
            setShowTaskForm(true);
            setMessages([...messages, { text: action, isUser: true }]);
        } else {
            setInputMessage(action);
        }
    };

    const handleMessageClick = (text: string) => {
        // Check if clicking on main menu link
        if (text.includes("Back to Main Menu") || text.includes("مین مینو پر واپس جائیں")) {
            handleBackToMenu();
        }
    };

    return (
        <>
            {/* Floating Button */}
            <button
                onClick={() => setIsOpen(!isOpen)}
                className="fixed bottom-5 right-5 w-[60px] h-[60px] rounded-full bg-gradient-to-br from-teal-500 to-teal-700 text-white shadow-lg hover:shadow-2xl transition-all duration-300 hover:scale-110 z-50 flex items-center justify-center"
                aria-label="Toggle chatbot"
            >
                {isOpen ? (
                    <X className="w-6 h-6" />
                ) : (
                    <Bot className="w-7 h-7" />
                )}
            </button>

            {/* Chat Window */}
            {isOpen && (
                <div className="fixed bottom-24 right-5 w-[400px] h-[600px] bg-white rounded-2xl shadow-2xl z-50 flex flex-col overflow-hidden border border-gray-200">
                    {/* Header */}
                    <div className="bg-gradient-to-r from-teal-500 to-teal-700 text-white p-4 flex items-center justify-between">
                        <div className="flex items-center gap-3">
                            <div className="w-10 h-10 bg-white/20 rounded-full flex items-center justify-center">
                                <Bot className="w-6 h-6" />
                            </div>
                            <div>
                                <h3 className="font-semibold">Task Assistant</h3>
                                <p className="text-xs text-white/80">AI Powered</p>
                            </div>
                        </div>
                        <div className="flex items-center gap-2">
                            <button
                                onClick={handleReset}
                                className="hover:bg-white/20 rounded-full p-1 transition-colors"
                                title="Reset conversation"
                            >
                                <RotateCcw className="w-5 h-5" />
                            </button>
                            <button
                                onClick={toggleLanguage}
                                className="hover:bg-white/20 rounded-full p-1 transition-colors"
                                title={`Switch to ${language === "en" ? "Urdu" : "English"}`}
                            >
                                <Globe className="w-5 h-5" />
                            </button>
                            <button
                                onClick={() => setIsOpen(false)}
                                className="hover:bg-white/20 rounded-full p-1 transition-colors"
                            >
                                <X className="w-5 h-5" />
                            </button>
                        </div>
                    </div>

                    {/* Language Indicator */}
                    <div className="bg-teal-50 px-4 py-2 text-xs text-teal-700 border-b border-teal-100">
                        Language: {language === "en" ? "English" : "اردو (Urdu)"}
                    </div>

                    {/* Messages */}
                    <div className="flex-1 overflow-y-auto p-4 space-y-3 bg-gray-50">
                        {messages.map((message, index) => (
                            <div
                                key={index}
                                className={`flex ${message.isUser ? "justify-end" : "justify-start"}`}
                            >
                                <div
                                    onClick={() => !message.isUser && handleMessageClick(message.text)}
                                    className={`max-w-[85%] rounded-2xl px-4 py-2 ${message.isUser
                                        ? "bg-gradient-to-r from-teal-500 to-teal-700 text-white"
                                        : "bg-white text-gray-800 border border-gray-200 shadow-sm cursor-pointer hover:shadow-md transition-shadow"
                                        }`}
                                >
                                    <p className="text-sm whitespace-pre-line leading-relaxed" dir={language === "ur" ? "rtl" : "ltr"}>{message.text}</p>
                                </div>
                            </div>
                        ))}

                        {/* Task Form */}
                        {showTaskForm && (
                            <div className="bg-white border-2 border-teal-500 rounded-xl p-4 shadow-lg">
                                <h4 className="font-semibold text-teal-700 mb-3 flex items-center gap-2">
                                    ➕ {language === "en" ? "Create New Task" : "نیا کام بنائیں"}
                                </h4>
                                <form onSubmit={handleTaskFormSubmit} className="space-y-3">
                                    {/* Title */}
                                    <div>
                                        <label className="block text-xs font-medium text-gray-700 mb-1">
                                            {language === "en" ? "Title *" : "عنوان *"}
                                        </label>
                                        <input
                                            type="text"
                                            value={taskFormData.title}
                                            onChange={(e) => setTaskFormData({ ...taskFormData, title: e.target.value })}
                                            className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent"
                                            dir={language === "ur" ? "rtl" : "ltr"}
                                            placeholder={language === "en" ? "Enter task title" : "کام کا عنوان درج کریں"}
                                            maxLength={200}
                                        />
                                    </div>

                                    {/* Description */}
                                    <div>
                                        <label className="block text-xs font-medium text-gray-700 mb-1">
                                            {language === "en" ? "Description" : "تفصیل"}
                                        </label>
                                        <textarea
                                            value={taskFormData.description}
                                            onChange={(e) => setTaskFormData({ ...taskFormData, description: e.target.value })}
                                            className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent"
                                            placeholder={language === "en" ? "Enter description (optional)" : "تفصیل درج کریں (اختیاری)"}
                                            dir={language === "ur" ? "rtl" : "ltr"}
                                            rows={2}
                                            maxLength={500}
                                        />
                                    </div>

                                    {/* Priority and Due Date */}
                                    <div className="grid grid-cols-2 gap-2">
                                        <div>
                                            <label className="block text-xs font-medium text-gray-700 mb-1">
                                                {language === "en" ? "Priority" : "ترجیح"}
                                            </label>
                                            <select
                                                value={taskFormData.priority}
                                                onChange={(e) => setTaskFormData({ ...taskFormData, priority: e.target.value })}
                                                className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent"
                                            >
                                                <option value="">{language === "en" ? "Select" : "منتخب کریں"}</option>
                                                <option value="Low">{language === "en" ? "Low" : "کم"}</option>
                                                <option value="Medium">{language === "en" ? "Medium" : "درمیانی"}</option>
                                                <option value="High">{language === "en" ? "High" : "زیادہ"}</option>
                                            </select>
                                        </div>
                                        <div>
                                            <label className="block text-xs font-medium text-gray-700 mb-1">
                                                {language === "en" ? "Due Date" : "آخری تاریخ"}
                                            </label>
                                            <input
                                                type="date"
                                                value={taskFormData.due_date}
                                                onChange={(e) => setTaskFormData({ ...taskFormData, due_date: e.target.value })}
                                                className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent"
                                            />
                                        </div>
                                    </div>

                                    {/* Category */}
                                    <div>
                                        <label className="block text-xs font-medium text-gray-700 mb-1">
                                            {language === "en" ? "Category" : "زمرہ"}
                                        </label>
                                        <input
                                            type="text"
                                            value={taskFormData.category}
                                            onChange={(e) => setTaskFormData({ ...taskFormData, category: e.target.value })}
                                            className="w-full px-3 py-2 text-sm border border-gray-300 rounded-lg focus:ring-2 focus:ring-teal-500 focus:border-transparent"
                                            placeholder={language === "en" ? "e.g., Work, Personal" : "مثلاً، کام، ذاتی"}
                                            maxLength={100}
                                        />
                                    </div>

                                    {/* Buttons */}
                                    <div className="flex gap-2 pt-2">
                                        <button
                                            type="submit"
                                            disabled={isLoading}
                                            className="flex-1 bg-gradient-to-r from-teal-500 to-teal-700 text-white py-2 rounded-lg font-medium hover:shadow-lg transition-all disabled:opacity-50 text-sm"
                                        >
                                            {isLoading ? "..." : (language === "en" ? "Create Task" : "کام بنائیں")}
                                        </button>
                                        <button
                                            type="button"
                                            onClick={() => {
                                                setShowTaskForm(false);
                                                setTaskFormData({ title: "", description: "", priority: "", due_date: "", category: "" });
                                            }}
                                            className="px-4 bg-gray-200 text-gray-700 py-2 rounded-lg font-medium hover:bg-gray-300 transition-colors text-sm"
                                        >
                                            {language === "en" ? "Cancel" : "منسوخ"}
                                        </button>
                                    </div>
                                </form>
                            </div>
                        )}

                        {isLoading && !showTaskForm && (
                            <div className="flex justify-start">
                                <div className="bg-white text-gray-800 border border-gray-200 rounded-2xl px-4 py-3 shadow-sm">
                                    <div className="flex gap-1">
                                        <div className="w-2 h-2 bg-teal-500 rounded-full animate-bounce"></div>
                                        <div className="w-2 h-2 bg-teal-500 rounded-full animate-bounce" style={{ animationDelay: "0.1s" }}></div>
                                        <div className="w-2 h-2 bg-teal-500 rounded-full animate-bounce" style={{ animationDelay: "0.2s" }}></div>
                                    </div>
                                </div>
                            </div>
                        )}
                        <div ref={messagesEndRef} />
                    </div>

                    {/* Quick Actions */}
                    {(messages.length === 1 || messages[messages.length - 1]?.text.includes("Back to Main Menu") || messages[messages.length - 1]?.text.includes("مین مینو")) && !isLoading && !showTaskForm && (
                        <div className="px-4 py-2 bg-gray-50 border-t border-gray-200">
                            <div className="flex flex-wrap gap-2">
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Add task" : "کام شامل کریں")}
                                    className="text-xs px-3 py-1.5 bg-teal-100 text-teal-700 rounded-full hover:bg-teal-200 transition-colors"
                                >
                                    {language === "en" ? "➕ Add Task" : "➕ کام شامل کریں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "View tasks" : "کام دیکھیں")}
                                    className="text-xs px-3 py-1.5 bg-blue-100 text-blue-700 rounded-full hover:bg-blue-200 transition-colors"
                                >
                                    {language === "en" ? "📋 View Tasks" : "📋 کام دیکھیں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Complete a task" : "کام مکمل کریں")}
                                    className="text-xs px-3 py-1.5 bg-green-100 text-green-700 rounded-full hover:bg-green-200 transition-colors"
                                >
                                    {language === "en" ? "✅ Complete" : "✅ مکمل کریں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Update a task" : "کام اپ ڈیٹ کریں")}
                                    className="text-xs px-3 py-1.5 bg-yellow-100 text-yellow-700 rounded-full hover:bg-yellow-200 transition-colors"
                                >
                                    {language === "en" ? "✏️ Update" : "✏️ اپ ڈیٹ"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Delete a task" : "کام حذف کریں")}
                                    className="text-xs px-3 py-1.5 bg-red-100 text-red-700 rounded-full hover:bg-red-200 transition-colors"
                                >
                                    {language === "en" ? "🗑️ Delete" : "🗑️ حذف کریں"}
                                </button>
                                <button
                                    onClick={() => handleQuickAction(language === "en" ? "Help" : "مدد")}
                                    className="text-xs px-3 py-1.5 bg-purple-100 text-purple-700 rounded-full hover:bg-purple-200 transition-colors"
                                >
                                    {language === "en" ? "❓ Help" : "❓ مدد"}
                                </button>
                            </div>
                        </div>
                    )}

                    {/* Input */}
                    {!showTaskForm && (
                        <div className="p-4 bg-white border-t border-gray-200">
                            <div className="flex gap-2">
                                <input
                                    type="text"
                                    value={inputMessage}
                                    onChange={(e) => setInputMessage(e.target.value)}
                                    onKeyPress={handleKeyPress}
                                    placeholder={language === "en" ? "Type your message..." : "اپنا پیغام لکھیں..."}
                                    dir={language === "ur" ? "rtl" : "ltr"}
                                    className="flex-1 px-4 py-2 border border-gray-300 rounded-full focus:outline-none focus:ring-2 focus:ring-teal-500 focus:border-transparent text-sm"
                                    disabled={isLoading}
                                />
                                <button
                                    onClick={handleSendMessage}
                                    disabled={!inputMessage.trim() || isLoading}
                                    className="w-10 h-10 bg-gradient-to-r from-teal-500 to-teal-700 text-white rounded-full flex items-center justify-center hover:shadow-lg transition-all disabled:opacity-50 disabled:cursor-not-allowed"
                                >
                                    <Send className="w-4 h-4" />
                                </button>
                            </div>
                        </div>
                    )}
                </div>
            )}
        </>
    );
}

