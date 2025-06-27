import React, { useEffect } from 'react';
import { AlertCircle } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';
import { useViewedLogs } from '../hooks/useViewedLogs';

interface Log {
    error: string;
    message: string;
    stacktrace: string;
    timestamp: string;
}

interface LogsDisplayProps {
    title: string;
    description: string;
    logPath: 'server' | 'push_notifications';
}

export default function LogsDisplay({ title, description, logPath }: LogsDisplayProps) {
    const { data, loading } = useFirebaseData();
    const { markAllAsViewed } = useViewedLogs();
    const logs = data?.logs?.[logPath] ? Object.entries(data.logs[logPath] || {})
        .sort(([, a], [, b]) => {
            const aTime = new Date((a as Log).timestamp).getTime();
            const bTime = new Date((b as Log).timestamp).getTime();
            return bTime - aTime;
        })
        .map(([id, log]) => ({ id, ...(log as Log) })) : [];

    // Mark logs as viewed when the page is loaded
    useEffect(() => {
        markAllAsViewed(logPath);
    }, [markAllAsViewed, logPath]);

    if (loading) {
        return (
            <div className="p-8">
                <div className="animate-pulse">
                    <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
                    <div className="space-y-4">
                        {[...Array(4)].map((_, i) => (
                            <div key={i} className="bg-white p-6 rounded-xl shadow-sm">
                                <div className="h-6 bg-gray-200 rounded w-1/2 mb-4"></div>
                                <div className="space-y-2">
                                    {[...Array(3)].map((_, j) => (
                                        <div key={j} className="h-4 bg-gray-200 rounded"></div>
                                    ))}
                                </div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        );
    }

    return (
        <div className="p-8">
            <div className="mb-8">
                <h1 className="text-3xl font-bold text-gray-900 mb-2">{title}</h1>
                <p className="text-gray-600">{description}</p>
            </div>

            <div className="space-y-4 bg-white p-4 rounded-xl">
                {logs.length === 0 ? (
                    <div className="text-center py-12 bg-white rounded-xl shadow-sm">
                        <AlertCircle className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                        <h3 className="text-lg font-medium text-gray-900 mb-2">No Logs</h3>
                        <p className="text-gray-600">There are no logs to display at this time.</p>
                    </div>
                ) : (
                    logs.map((log) => (
                        <div key={log.id} className="bg-gray-300 border border-gray-400 rounded-xl shadow-sm p-6">
                            <div className="flex items-start justify-between mb-4">
                                <div>
                                    <h3 className="text-lg font-semibold text-red-600 mb-1">{log.error}</h3>
                                    <p className="text-sm text-gray-500">
                                        {new Date(log.timestamp).toLocaleString()}
                                    </p>
                                </div>
                            </div>

                            <div className="space-y-4">
                                <div>
                                    <p className="text-sm font-medium text-gray-500 mb-1">Message</p>
                                    <p className="text-gray-900">{log.message}</p>
                                </div>

                                {log.stacktrace && (
                                    <div>
                                        <p className="text-sm font-medium text-gray-500 mb-1">Stack Trace</p>
                                        <pre className="bg-gray-50 p-4 rounded-lg overflow-x-auto text-sm text-gray-900">
                                            {log.stacktrace}
                                        </pre>
                                    </div>
                                )}
                            </div>
                        </div>
                    ))
                )}
            </div>
        </div>
    );
} 