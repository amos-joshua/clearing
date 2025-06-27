import React from 'react';
import LogsDisplay from '../components/LogsDisplay';

export default function PushNotificationLogs() {
    return (
        <LogsDisplay
            title="Push Notification Logs"
            description="Push notification error logs and exceptions"
            logPath="push_notifications"
        />
    );
} 