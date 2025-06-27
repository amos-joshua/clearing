import { useState, useEffect } from 'react';
import { useFirebaseData } from './useFirebaseData';

type LogType = 'server' | 'push_notifications';

export function useViewedLogs() {
    const { data } = useFirebaseData();
    const [viewedLogIds, setViewedLogIds] = useState<{ [key in LogType]?: Set<string> }>(() => {
        const saved = localStorage.getItem('viewedLogIds');
        return saved ? {
            server: new Set(JSON.parse(saved).server || []),
            push_notifications: new Set(JSON.parse(saved).push_notifications || [])
        } : { server: new Set(), push_notifications: new Set() };
    });

    // Update localStorage when viewedLogIds changes
    useEffect(() => {
        localStorage.setItem('viewedLogIds', JSON.stringify({
            server: [...(viewedLogIds.server || [])],
            push_notifications: [...(viewedLogIds.push_notifications || [])]
        }));
    }, [viewedLogIds]);

    // Get the latest log timestamp
    const latestLogTimestamp = data?.logs?.server
        ? Math.max(...Object.values(data.logs.server).map(log => new Date(log.timestamp).getTime()))
        : 0;

    // Mark all current logs as viewed
    const markAllAsViewed = (logType: LogType = 'server') => {
        if (data?.logs?.[logType]) {
            setViewedLogIds(prev => ({
                ...prev,
                [logType]: new Set(Object.keys(data.logs[logType] || {}))
            }));
        }
    };

    // Check if there are new logs
    const hasNewLogs = (logType: LogType = 'server') => {
        if (!data?.logs?.[logType]) return false;
        const viewedIds = viewedLogIds[logType] || new Set();
        return Object.keys(data.logs[logType] || {}).some(id => !viewedIds.has(id));
    };

    return {
        hasNewLogs,
        markAllAsViewed,
        latestLogTimestamp
    };
} 