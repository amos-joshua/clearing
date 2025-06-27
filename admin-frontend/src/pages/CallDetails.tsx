import React, { useState } from 'react';
import { useParams } from 'react-router-dom';
import { Phone } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';
import { CallLogsSection } from '../components/CallLogsSection';
import { LogEntryData } from '../components/CallLogsSection';
import { Call } from '../types/call';
import { CallInformation } from '../components/CallInformation';
import { StateComparison } from '../components/StateComparison';

export default function CallDetails() {
  const { callId } = useParams<{ callId: string }>();
  const { data, loading } = useFirebaseData();
  const [selectedError, setSelectedError] = useState<{ log: LogEntryData; type: 'SENDER' | 'RECEIVER' } | null>(null);

  const handleErrorSelect = (log: LogEntryData, type: 'SENDER' | 'RECEIVER') => {
    setSelectedError({ log, type });
  };

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
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

  if (!callId || !data?.calls?.[callId]) {
    return (
      <div className="p-8">
        <div className="text-center">
          <Phone className="w-16 h-16 text-gray-400 mx-auto mb-4" />
          <h1 className="text-2xl font-bold text-gray-900 mb-2">Call Not Found</h1>
          <p className="text-gray-600">The requested call could not be found.</p>
        </div>
      </div>
    );
  }

  const call = data.calls[callId] as Call;
  const logs = data?.logs?.call?.[callId];

  const getLogEntries = (type: 'SENDER' | 'RECEIVER'): LogEntryData[] => {
    if (!logs?.[type]) return [];
    return Object.entries(logs[type])
      .sort(([, a], [, b]) => new Date(a.timestamp).getTime() - new Date(b.timestamp).getTime())
      .map(([logId, log]) => ({ 
        ...log, 
        id: logId,
        error: log.error
      }));
  };

  const senderLogs = getLogEntries('SENDER');
  const receiverLogs = getLogEntries('RECEIVER');

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Call Details</h1>
        <p className="text-gray-600 font-mono">{callId}</p>
      </div>

      <CallInformation call={call} />
      <StateComparison call={call} />

      {/* Logs Section */}
      <CallLogsSection
        senderLogs={senderLogs}
        receiverLogs={receiverLogs}
        onErrorSelect={handleErrorSelect}
        selectedError={selectedError}
        onErrorClose={() => setSelectedError(null)}
        createdAt={call['created-at']}
      />
    </div>
  );
}