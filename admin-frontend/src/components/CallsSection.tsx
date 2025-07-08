import { Link, useLocation } from 'react-router-dom';
import { Phone, AlertCircle } from 'lucide-react';
import { CallState, isValidCallState } from '../utils/colors';
import { useMemo } from 'react';

interface Call {
    'created-at': string;
    SENDER?: {
        state: CallState;
    };
    RECEIVER?: {
        state: CallState;
    };
    isLogOnly?: boolean;
    lastLogTimestamp?: string;
}

interface RawCall {
    'created-at': string;
    SENDER?: {
        state: string;
    };
    RECEIVER?: {
        state: string;
    };
    isLogOnly?: boolean;
    lastLogTimestamp?: string;
}

interface CallsSectionProps {
    calls: [string, RawCall][];
    getStateColorClasses: (state: CallState) => string;
}

export function CallsSection({ calls, getStateColorClasses }: CallsSectionProps) {
    const location = useLocation();

    const transformCall = (call: RawCall): Call => ({
        ...call,
        SENDER: call.SENDER ? {
            ...call.SENDER,
            state: isValidCallState(call.SENDER.state) ? call.SENDER.state as CallState : 'IDLE'
        } : undefined,
        RECEIVER: call.RECEIVER ? {
            ...call.RECEIVER,
            state: isValidCallState(call.RECEIVER.state) ? call.RECEIVER.state as CallState : 'IDLE'
        } : undefined
    });

    const formatDateHeader = (date: Date): string => {
        const today = new Date();
        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        const isToday = date.toDateString() === today.toDateString();
        const isYesterday = date.toDateString() === yesterday.toDateString();

        if (isToday) {
            return 'Today';
        } else if (isYesterday) {
            return 'Yesterday';
        } else {
            return date.toLocaleDateString('en-US', {
                weekday: 'long',
                year: 'numeric',
                month: 'long',
                day: 'numeric'
            });
        }
    };

    // Memoize the sorted and transformed calls with date grouping
    const groupedCalls = useMemo(() => {
        const sortedCalls = [...calls]
            .sort(([, a], [, b]) =>
                new Date(b['created-at']).getTime() - new Date(a['created-at']).getTime()
            )
            .map(([callId, rawCall]) => ({
                callId,
                call: transformCall(rawCall)
            }));

        // Group calls by date
        const groups: { dateHeader: string; calls: typeof sortedCalls }[] = [];
        let currentDate = '';
        let currentGroup: typeof sortedCalls = [];

        sortedCalls.forEach(({ callId, call }) => {
            const callDate = new Date(call['created-at']);
            const dateHeader = formatDateHeader(callDate);

            if (dateHeader !== currentDate) {
                if (currentGroup.length > 0) {
                    groups.push({ dateHeader: currentDate, calls: currentGroup });
                }
                currentDate = dateHeader;
                currentGroup = [{ callId, call }];
            } else {
                currentGroup.push({ callId, call });
            }
        });

        // Add the last group
        if (currentGroup.length > 0) {
            groups.push({ dateHeader: currentDate, calls: currentGroup });
        }

        return groups;
    }, [calls]);

    return (
        <div className="px-4">
            <div className="flex items-center space-x-2 px-4 py-2 text-gray-400 text-sm font-medium">
                <Phone className="w-4 h-4" />
                <span>Calls</span>
            </div>
            <div className="space-y-1 max-h-96 overflow-y-auto">
                {groupedCalls.map(({ dateHeader, calls: groupCalls }) => (
                    <div key={dateHeader}>
                        <div className="sticky top-0 z-10 bg-gray-900 px-4 py-2 text-xs font-semibold text-gray-500 uppercase tracking-wider border-b border-gray-800">
                            {dateHeader}
                        </div>
                        {groupCalls.map(({ callId, call }) => (
                            <Link
                                key={callId}
                                to={`/call/${callId}`}
                                className={`block px-4 py-3 rounded-lg transition-colors ${location.pathname === `/call/${callId}`
                                    ? 'bg-blue-600 text-white'
                                    : call.isLogOnly
                                        ? 'text-gray-400 hover:bg-gray-800 border border-dashed border-gray-700'
                                        : 'text-gray-300 hover:bg-gray-800'
                                    }`}
                            >
                                <div className="text-sm">
                                    <div className="flex items-center justify-between">
                                        <p className="font-mono text-xs text-gray-400 truncate">
                                            {callId.slice(0, 8)}...
                                        </p>
                                        {call.isLogOnly && (
                                            <AlertCircle className="w-4 h-4 text-yellow-500" aria-label="Log-only call" />
                                        )}
                                    </div>
                                    <p className="text-xs text-gray-500 mt-1">
                                        {new Date(call['created-at']).toLocaleTimeString()}
                                    </p>
                                    {call.isLogOnly ? (
                                        <p className="text-xs text-yellow-500 mt-1">
                                            Logs only
                                        </p>
                                    ) : (
                                        <div className="flex space-x-2 mt-1">
                                            {call.SENDER && (
                                                <span className={`text-xs px-2 py-1 rounded ${getStateColorClasses(call.SENDER.state)}`}>
                                                    OUT: {call.SENDER.state}
                                                </span>
                                            )}
                                            {call.RECEIVER && (
                                                <span className={`text-xs px-2 py-1 rounded ${getStateColorClasses(call.RECEIVER.state)}`}>
                                                    IN: {call.RECEIVER.state}
                                                </span>
                                            )}
                                        </div>
                                    )}
                                </div>
                            </Link>
                        ))}
                    </div>
                ))}
            </div>
        </div>
    );
} 