import React from 'react';
import { X } from 'lucide-react';

interface ErrorLog {
  timestamp: string;
  message?: string;
  error?: string;
  stacktrace?: string;
}

interface ErrorDetailsPopupProps {
  log: ErrorLog;
  type: 'SENDER' | 'RECEIVER';
  onClose: () => void;
}

export function ErrorDetailsPopup({ log, type, onClose }: ErrorDetailsPopupProps) {
  return (
    <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
      <div className="bg-white rounded-xl shadow-lg max-w-3xl w-full mx-4 max-h-[80vh] flex flex-col">
        <div className="p-6 border-b border-gray-200 flex justify-between items-center">
          <h3 className="text-lg font-semibold text-gray-900">
            Error Details - {type === 'SENDER' ? 'Outgoing' : 'Incoming'} Call
          </h3>
          <button
            onClick={onClose}
            className="text-gray-400 hover:text-gray-500"
          >
            <X className="w-5 h-5" />
          </button>
        </div>
        <div className="p-6 overflow-y-auto">
          <div className="space-y-4">
            <div>
              <p className="text-sm font-medium text-gray-500">Timestamp</p>
              <p className="text-gray-900">{new Date(log.timestamp).toLocaleString()}</p>
            </div>
            {log.message && (
              <div>
                <p className="text-sm font-medium text-gray-500">Message</p>
                <p className="text-gray-900">{log.message}</p>
              </div>
            )}
            <div>
              <p className="text-sm font-medium text-gray-500">Error</p>
              <p className="text-red-700">{log.error || 'Unknown error'}</p>
            </div>
            {log.stacktrace && (
              <div>
                <p className="text-sm font-medium text-gray-500">Stack Trace</p>
                <pre className="mt-2 p-4 bg-gray-50 rounded-lg overflow-x-auto text-sm text-red-700">
                  {log.stacktrace}
                </pre>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
} 