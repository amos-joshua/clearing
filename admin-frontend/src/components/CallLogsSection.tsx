import React from 'react';
import { ErrorDetailsPopup } from './ErrorDetailsPopup';
import { LogEntry } from './LogEntry';

interface LogEntryData {
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
}

interface CallLogsSectionProps {
  senderLogs: LogEntryData[];
  receiverLogs: LogEntryData[];
  onErrorSelect: (log: LogEntryData, type: 'SENDER' | 'RECEIVER') => void;
  selectedError: { log: LogEntryData; type: 'SENDER' | 'RECEIVER' } | null;
  onErrorClose: () => void;
  createdAt: string;
}

export function CallLogsSection({ 
  senderLogs, 
  receiverLogs, 
  onErrorSelect,
  selectedError,
  onErrorClose,
  createdAt
}: CallLogsSectionProps) {
  // Combine and sort logs chronologically
  const allLogs = [
    ...senderLogs.map(log => ({ ...log, source: 'SENDER' as const })),
    ...receiverLogs.map(log => ({ ...log, source: 'RECEIVER' as const }))
  ].sort((a, b) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime());

  return (
    <div className="rounded-xl shadow-sm border border-gray-100 p-6">
      {/* Fixed Headers */}
      <div className="grid grid-cols-2 gap-6 mb-4">
        <h3 className="text-lg font-semibold text-gray-900">Outgoing</h3>
        <h3 className="text-lg font-semibold text-gray-900">Incoming</h3>
      </div>

      {/* Scrollable Content */}
      <div className="relative p-4" style={{ backgroundColor: '#e0e0e0' }}>
        {/* Vertical Divider */}
        <div className="absolute left-1/2 top-0 bottom-0 w-px bg-gray-200 border-l border-dashed" />

        {/* Log Entries */}
        <div className="space-y-4 max-h-[calc(100vh-400px)] overflow-y-auto">
          {allLogs.length === 0 ? (
            <p className="text-gray-500 text-center py-4">No logs available</p>
          ) : (
            allLogs.map((log) => (
              <div
                key={`${log.source}-${log.id}`}
                className={`grid grid-cols-2 gap-6 ${
                  log.source === 'SENDER' ? 'pr-6' : 'pl-6'
                }`}
              >
                {log.source === 'SENDER' ? (
                  <>
                    <LogEntry
                      log={log}
                      type="SENDER"
                      onErrorSelect={onErrorSelect}
                      createdAt={createdAt}
                    />
                    <div /> {/* Empty div for grid alignment */}
                  </>
                ) : (
                  <>
                    <div /> {/* Empty div for grid alignment */}
                    <LogEntry
                      log={log}
                      type="RECEIVER"
                      onErrorSelect={onErrorSelect}
                      createdAt={createdAt}
                    />
                  </>
                )}
              </div>
            ))
          )}
        </div>
      </div>

      {/* Error Details Popup */}
      {selectedError && (
        <ErrorDetailsPopup
          log={selectedError.log}
          type={selectedError.type}
          onClose={onErrorClose}
        />
      )}
    </div>
  );
}

export type { LogEntryData };
