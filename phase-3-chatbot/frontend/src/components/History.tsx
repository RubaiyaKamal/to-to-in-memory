import { useEffect, useState } from 'react';
import { getTaskHistory, TaskHistory } from '../lib/api';

const History = () => {
    const [history, setHistory] = useState<TaskHistory[]>([]);
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [filter, setFilter] = useState<string>('all');
    const userId = 'test-user';

    useEffect(() => {
        loadHistory();
    }, []);

    const loadHistory = async () => {
        try {
            const data = await getTaskHistory(userId);
            setHistory(data);
            setError(null);
        } catch (err) {
            setError('Failed to load history');
            console.error(err);
        } finally {
            setIsLoading(false);
        }
    };

    const getActionIcon = (action: string) => {
        switch (action) {
            case 'created':
                return (
                    <svg className="w-5 h-5 text-green-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                    </svg>
                );
            case 'updated':
                return (
                    <svg className="w-5 h-5 text-amber-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                    </svg>
                );
            case 'deleted':
                return (
                    <svg className="w-5 h-5 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                    </svg>
                );
            case 'completed':
                return (
                    <svg className="w-5 h-5 text-teal-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                );
            case 'uncompleted':
                return (
                    <svg className="w-5 h-5 text-gray-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 14l2-2m0 0l2-2m-2 2l-2-2m2 2l2 2m7-2a9 9 0 11-18 0 9 9 0 0118 0z" />
                    </svg>
                );
            default:
                return null;
        }
    };

    const getActionColor = (action: string) => {
        switch (action) {
            case 'created':
                return 'bg-green-50 border-green-200';
            case 'updated':
                return 'bg-amber-50 border-amber-200';
            case 'deleted':
                return 'bg-red-50 border-red-200';
            case 'completed':
                return 'bg-teal-50 border-teal-200';
            case 'uncompleted':
                return 'bg-gray-50 border-gray-200';
            default:
                return 'bg-gray-50 border-gray-200';
        }
    };

    const formatDate = (dateString: string) => {
        const date = new Date(dateString);
        return new Intl.DateTimeFormat('en-US', {
            month: 'short',
            day: 'numeric',
            year: 'numeric',
            hour: '2-digit',
            minute: '2-digit',
        }).format(date);
    };

    const filteredHistory = filter === 'all'
        ? history
        : history.filter(h => h.action === filter);

    return (
        <div className="max-w-4xl mx-auto p-6">
            {/* Header */}
            <div className="mb-8">
                <h1 className="text-4xl font-bold mb-2 bg-gradient-to-r from-teal-600 to-teal-800 bg-clip-text text-transparent">
                    Task History
                </h1>
                <p className="text-gray-600">Complete audit log of all task changes</p>
            </div>

            {/* Filter Buttons */}
            <div className="flex flex-wrap gap-2 mb-6">
                <button
                    onClick={() => setFilter('all')}
                    className={`px-4 py-2 rounded-lg transition ${
                        filter === 'all'
                            ? 'bg-teal-600 text-white'
                            : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                >
                    All ({history.length})
                </button>
                <button
                    onClick={() => setFilter('created')}
                    className={`px-4 py-2 rounded-lg transition ${
                        filter === 'created'
                            ? 'bg-green-500 text-white'
                            : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                >
                    Created ({history.filter(h => h.action === 'created').length})
                </button>
                <button
                    onClick={() => setFilter('updated')}
                    className={`px-4 py-2 rounded-lg transition ${
                        filter === 'updated'
                            ? 'bg-amber-500 text-white'
                            : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                >
                    Updated ({history.filter(h => h.action === 'updated').length})
                </button>
                <button
                    onClick={() => setFilter('completed')}
                    className={`px-4 py-2 rounded-lg transition ${
                        filter === 'completed'
                            ? 'bg-teal-500 text-white'
                            : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                >
                    Completed ({history.filter(h => h.action === 'completed').length})
                </button>
                <button
                    onClick={() => setFilter('deleted')}
                    className={`px-4 py-2 rounded-lg transition ${
                        filter === 'deleted'
                            ? 'bg-red-500 text-white'
                            : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                >
                    Deleted ({history.filter(h => h.action === 'deleted').length})
                </button>
            </div>

            {/* Error Message */}
            {error && (
                <div className="bg-red-50 border border-red-200 text-red-700 px-4 py-3 rounded-lg mb-4">
                    {error}
                </div>
            )}

            {/* Loading State */}
            {isLoading ? (
                <div className="text-center py-12 bg-white rounded-lg shadow-md">
                    <div className="animate-spin rounded-full h-12 w-12 border-b-2 border-teal-600 mx-auto"></div>
                    <p className="mt-4 text-gray-600">Loading history...</p>
                </div>
            ) : (
                <>
                    {/* History List */}
                    {filteredHistory.length > 0 ? (
                        <div className="space-y-3">
                            {filteredHistory.map((entry) => (
                                <div
                                    key={entry.id}
                                    className={`p-4 rounded-lg border ${getActionColor(entry.action)} transition hover:shadow-md`}
                                >
                                    <div className="flex items-start gap-3">
                                        <div className="flex-shrink-0 mt-1">
                                            {getActionIcon(entry.action)}
                                        </div>
                                        <div className="flex-1 min-w-0">
                                            <div className="flex items-center justify-between mb-1">
                                                <span className="font-semibold text-gray-900 capitalize">
                                                    {entry.action}
                                                </span>
                                                <span className="text-sm text-gray-500">
                                                    {formatDate(entry.changed_at)}
                                                </span>
                                            </div>
                                            {entry.field_name && (
                                                <div className="text-sm text-gray-600 mb-1">
                                                    <span className="font-medium">Field:</span> {entry.field_name}
                                                </div>
                                            )}
                                            {entry.old_value && (
                                                <div className="text-sm text-gray-600">
                                                    <span className="font-medium">From:</span> {entry.old_value}
                                                </div>
                                            )}
                                            {entry.new_value && (
                                                <div className="text-sm text-gray-700 font-medium">
                                                    <span className="font-medium">To:</span> {entry.new_value}
                                                </div>
                                            )}
                                            <div className="text-xs text-gray-500 mt-2">
                                                Task ID: #{entry.task_id}
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            ))}
                        </div>
                    ) : (
                        <div className="text-center py-16 bg-white rounded-lg shadow-md">
                            <svg className="w-24 h-24 mx-auto text-gray-300 mb-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5} d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z" />
                            </svg>
                            <h3 className="text-xl font-semibold text-gray-700 mb-2">No history yet!</h3>
                            <p className="text-gray-500">Task changes will appear here</p>
                        </div>
                    )}
                </>
            )}
        </div>
    );
};

export default History;
