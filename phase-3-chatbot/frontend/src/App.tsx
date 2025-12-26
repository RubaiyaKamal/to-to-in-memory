import { useState } from 'react';
import Chat from './components/Chat';
import History from './components/History';

function App() {
    const [currentView, setCurrentView] = useState<'chat' | 'history'>('chat');

    return (
        <div className="min-h-screen bg-gray-100">
            {/* Navigation */}
            <div className="bg-gradient-to-r from-teal-600 to-teal-800 text-white shadow-lg">
                <div className="container mx-auto px-4 py-4">
                    <div className="flex justify-between items-center">
                        <h1 className="text-2xl font-bold">Todo Chatbot</h1>
                        <nav className="flex gap-2">
                            <button
                                onClick={() => setCurrentView('chat')}
                                className={`px-4 py-2 rounded-lg transition ${
                                    currentView === 'chat'
                                        ? 'bg-white text-teal-700 font-semibold'
                                        : 'bg-teal-700 hover:bg-teal-600'
                                }`}
                            >
                                Chat
                            </button>
                            <button
                                onClick={() => setCurrentView('history')}
                                className={`px-4 py-2 rounded-lg transition ${
                                    currentView === 'history'
                                        ? 'bg-white text-teal-700 font-semibold'
                                        : 'bg-teal-700 hover:bg-teal-600'
                                }`}
                            >
                                History
                            </button>
                        </nav>
                    </div>
                </div>
            </div>

            {/* Content */}
            {currentView === 'chat' ? <Chat /> : <History />}
        </div>
    );
}

export default App;
