import { useState, useEffect } from 'react';
import { ref, onValue, off } from 'firebase/database';
import { database } from '../config/firebase';

export interface CallData {
  [callId: string]: {
    RECEIVER?: {
      state: string;
    };
    SENDER?: {
      recipients: string[];
      'sender-uid': string;
      state: string;
    };
    'created-at': string;
  };
}

export interface LogData {
  [callId: string]: {
    RECEIVER?: {
      [logId: string]: {
        message?: string;
        source_queue?: string;
        timestamp: string;
        type: string;
        new_state?: string;
        old_state?: string;
        trigger?: string;
        error?: string;
        stacktrace?: string;
        dest_queue?: string;
      };
    };
    SENDER?: {
      [logId: string]: {
        message?: string;
        source_queue?: string;
        timestamp: string;
        type: string;
        new_state?: string;
        old_state?: string;
        trigger?: string;
        error?: string;
        stacktrace?: string;
        dest_queue?: string;
      };
    };
  };
}

export interface FirebaseData {
  calls: CallData;
  logs: {
    call: LogData;
    server?: {
      [logId: string]: {
        error: string;
        message: string;
        stacktrace: string;
        timestamp: string;
      };
    };
    push_notifications?: {
      [logId: string]: {
        error: string;
        message: string;
        stacktrace: string;
        timestamp: string;
      };
    };
  };
  users: {
    [userId: string]: {
      devices: {
        [deviceId: string]: string;
      };
    };
  };
}

export interface CombinedCallData {
  [callId: string]: {
    RECEIVER?: {
      state: string;
    };
    SENDER?: {
      recipients: string[];
      'sender-uid': string;
      state: string;
    };
    'created-at': string;
    isLogOnly: boolean;
    lastLogTimestamp?: string;
  };
}

export function useFirebaseData() {
  const [data, setData] = useState<FirebaseData | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const dataRef = ref(database, '/');

    const handleData = (snapshot: any) => {
      const val = snapshot.val() as FirebaseData;

      // Combine calls and logs data
      const combinedCalls: CombinedCallData = {};

      // Add regular calls with isLogOnly set to false
      if (val.calls) {
        Object.entries(val.calls).forEach(([callId, callData]) => {
          combinedCalls[callId] = {
            ...callData,
            isLogOnly: false
          };
        });
      }

      // Add log-only calls
      if (val.logs?.call) {
        Object.entries(val.logs.call).forEach(([callId, logData]) => {
          if (!combinedCalls[callId]) {
            // Find the most recent log timestamp
            const allLogs = [
              ...Object.values(logData.RECEIVER || {}),
              ...Object.values(logData.SENDER || {})
            ];
            const lastLog = allLogs.sort((a, b) =>
              new Date(b.timestamp).getTime() - new Date(a.timestamp).getTime()
            )[0];

            combinedCalls[callId] = {
              'created-at': lastLog.timestamp,
              isLogOnly: true,
              lastLogTimestamp: lastLog.timestamp
            };
          }
        });
      }

      setData({
        ...val,
        calls: combinedCalls
      });
      setLoading(false);
    };

    onValue(dataRef, handleData);

    return () => {
      off(dataRef, 'value', handleData);
    };
  }, []);

  return { data, loading };
}