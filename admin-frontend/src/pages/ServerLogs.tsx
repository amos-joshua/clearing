import React from 'react';
import LogsDisplay from '../components/LogsDisplay';

export default function ServerLogs() {
    return (
        <LogsDisplay
            title="Server Logs"
            description="System error logs and exceptions"
            logPath="server"
        />
    );
} 