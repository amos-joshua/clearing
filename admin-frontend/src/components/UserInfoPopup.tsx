import React, { useState, useEffect } from 'react';
import { X, User } from 'lucide-react';
import { fetchWithAuth } from '../utils/api';

interface UserInfo {
    [key: string]: any;
}

interface UserInfoPopupProps {
    userId: string;
    isOpen: boolean;
    onClose: () => void;
}

export function UserInfoPopup({ userId, isOpen, onClose }: UserInfoPopupProps) {
    const [userInfo, setUserInfo] = useState<UserInfo | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    useEffect(() => {
        if (isOpen && userId) {
            fetchUserInfo();
        }
    }, [isOpen, userId]);

    const fetchUserInfo = async () => {
        setLoading(true);
        setError(null);
        try {
            const response = await fetchWithAuth(`/user/info?uid=${userId}`);
            setUserInfo(response);
        } catch (err) {
            setError(err instanceof Error ? err.message : 'Failed to fetch user info');
        } finally {
            setLoading(false);
        }
    };

    if (!isOpen) return null;

    return (
        <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
            <div className="bg-white rounded-xl shadow-lg max-w-2xl w-full mx-4 max-h-[80vh] flex flex-col">
                <div className="p-6 border-b border-gray-200 flex justify-between items-center">
                    <h3 className="text-lg font-semibold text-gray-900">User Information</h3>
                    <button
                        onClick={onClose}
                        className="text-gray-400 hover:text-gray-500"
                    >
                        <X className="w-5 h-5" />
                    </button>
                </div>

                <div className="p-6 overflow-y-auto">
                    {loading ? (
                        <div className="flex items-center justify-center py-8">
                            <div className="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-600"></div>
                            <span className="ml-3 text-gray-600">Loading user information...</span>
                        </div>
                    ) : error ? (
                        <div className="text-center py-8">
                            <div className="text-red-500 mb-4">
                                <X className="w-12 h-12 mx-auto mb-2" />
                                <p className="text-lg font-medium">Error</p>
                            </div>
                            <p className="text-gray-600 mb-4">{error}</p>
                            <button
                                onClick={fetchUserInfo}
                                className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                            >
                                Try Again
                            </button>
                        </div>
                    ) : userInfo ? (
                        <div className="space-y-6">
                            {/* User Header */}
                            <div className="flex items-center space-x-4 mb-6">
                                <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
                                    <User className="w-8 h-8 text-blue-600" />
                                </div>
                                <div className="flex-1">
                                    <h2 className="text-xl font-semibold text-gray-900">
                                        {userInfo.displayName || userInfo.uid || 'User Information'}
                                    </h2>
                                    {userInfo.uid && (
                                        <p className="text-gray-500 font-mono text-sm">{userInfo.uid}</p>
                                    )}
                                </div>
                            </div>

                            {/* Dynamic User Details */}
                            <div className="space-y-4">
                                {Object.entries(userInfo)
                                    .filter(([key]) => key !== 'devices') // Exclude devices since they're shown on the main page
                                    .map(([key, value]) => {
                                        // Skip rendering if value is null, undefined, or empty object
                                        if (value === null || value === undefined ||
                                            (typeof value === 'object' && Object.keys(value).length === 0)) {
                                            return null;
                                        }

                                        // Format the key for display
                                        const displayKey = key
                                            .replace(/([A-Z])/g, ' $1') // Add space before capital letters
                                            .replace(/^./, str => str.toUpperCase()) // Capitalize first letter
                                            .replace(/([A-Z])/g, ' $1') // Add space before remaining capital letters
                                            .trim();

                                        // Format the value based on its type
                                        let displayValue = value;
                                        if (typeof value === 'string') {
                                            // Try to parse as date if it looks like a date
                                            if (value.match(/^\d{4}-\d{2}-\d{2}/) || value.match(/^\d{4}-\d{2}-\d{2}T/)) {
                                                try {
                                                    displayValue = new Date(value).toLocaleString();
                                                } catch {
                                                    // If date parsing fails, use original value
                                                }
                                            }
                                        } else if (typeof value === 'boolean') {
                                            displayValue = value ? 'Yes' : 'No';
                                        } else if (typeof value === 'object') {
                                            displayValue = JSON.stringify(value, null, 2);
                                        }

                                        return (
                                            <div key={key} className="p-4 bg-gray-50 rounded-lg">
                                                <div className="flex items-start justify-between">
                                                    <div className="flex-1">
                                                        <p className="text-sm font-medium text-gray-500 mb-1">{displayKey}</p>
                                                        {typeof displayValue === 'string' && displayValue.length > 100 ? (
                                                            <pre className="text-sm text-gray-900 whitespace-pre-wrap break-words">
                                                                {displayValue}
                                                            </pre>
                                                        ) : (
                                                            <p className="text-sm text-gray-900 break-words">
                                                                {String(displayValue)}
                                                            </p>
                                                        )}
                                                    </div>
                                                </div>
                                            </div>
                                        );
                                    })}
                            </div>
                        </div>
                    ) : (
                        <div className="text-center py-8">
                            <p className="text-gray-500">No user information available</p>
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
} 