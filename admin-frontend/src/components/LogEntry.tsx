import React from 'react';

interface LogEntryProps {
  log: {
    id: string;
    type: string;
    timestamp: string;
    message?: string;
    trigger?: string;
    old_state?: string;
    new_state?: string;
    dest_queue?: string;
    source_queue?: string;
    error?: string;
    stacktrace?: string;
  };
  onErrorSelect: (log: LogEntryProps['log'], type: 'SENDER' | 'RECEIVER') => void;
  type: 'SENDER' | 'RECEIVER';
  createdAt: string;
}

const getLogTypeColor = (type: string) => {
  switch (type) {
    case 'INCOMING_EVENT': return 'bg-blue-100 text-blue-800';
    case 'OUTGOING_EVENT': return 'bg-green-100 text-green-800';
    case 'STATE-CHANGE': return 'bg-yellow-100 text-yellow-800';
    case 'ERROR': return 'bg-red-100 text-red-800';
    default: return 'bg-gray-100 text-gray-800';
  }
};

const formatRelativeTime = (timestamp: string, createdAt: string): string => {
  const logTime = new Date(timestamp).getTime();
  const startTime = new Date(createdAt).getTime();
  const diffSeconds = (logTime - startTime) / 1000;

  if (diffSeconds < 60) {
    // NOTE: the very first event occurs slightly before the call is created,
    // so return 0 if the diff is negative
    if (diffSeconds < 0) {
      return '0s';
    }
    return `${diffSeconds.toFixed(2)}s`;
  }

  const minutes = Math.floor(diffSeconds / 60);
  const seconds = (diffSeconds % 60).toFixed(2);
  return `${minutes}m ${seconds}s`;
};

export function LogEntry({ log, onErrorSelect, type, createdAt }: LogEntryProps) {
  return (
    <div className="border border-gray-200 rounded-lg p-4 shadow-sm bg-white">
      <div className="flex items-center justify-between mb-2">
        <span className={`px-2 py-1 rounded text-xs font-medium ${getLogTypeColor(log.type)}`}>
          {log.type}
        </span>
        <span className="text-xs text-gray-500">
          {formatRelativeTime(log.timestamp, createdAt)}
        </span>
      </div>
      
      {log.message && (
        <p className="text-sm text-gray-700 mb-1">
          <strong>Message:</strong> {log.message}
        </p>
      )}

      {log.source_queue && (
        <p className="text-sm text-gray-700 mb-1">
          <strong>Source Queue:</strong> {log.source_queue}
        </p>
      )}

      {log.dest_queue && (
        <p className="text-sm text-gray-700 mb-1">
          <strong>Destination Queue:</strong> {log.dest_queue}
        </p>
      )}

      {log.type === 'STATE-CHANGE' && (
        <div className="text-sm text-gray-700">
          <p><strong>Trigger:</strong> {log.trigger}</p>
          <p><strong>State:</strong> {log.old_state} → {log.new_state}</p>
        </div>
      )}
      
      {log.error && (
        <div className="text-sm text-red-700">
          <div className="flex justify-between items-start">
            <p><strong>Error:</strong> {log.error}</p>
            <button
              onClick={() => onErrorSelect(log, type)}
              className="ml-2 px-2 py-1 text-xs bg-gray-100 hover:bg-gray-200 rounded text-gray-700"
            >
              Details
            </button>
          </div>
          {log.stacktrace && (
            <pre className="text-xs bg-red-50 p-2 rounded mt-2 overflow-x-auto">
              {log.stacktrace.slice(0, 200)}...
            </pre>
          )}
        </div>
      )}
    </div>
  );
} 