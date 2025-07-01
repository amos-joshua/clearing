import React, { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { Users as UsersIcon, Smartphone, User, ChevronRight, Shield, Search, X } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';
import { fetchWithAuth } from '../utils/api';

interface UserData {
    devices: {
        [deviceId: string]: string;
    };
}

export default function Users() {
    const { data, loading } = useFirebaseData();
    const navigate = useNavigate();
    const [isEmailModalOpen, setIsEmailModalOpen] = useState(false);
    const [emailInput, setEmailInput] = useState('');
    const [isSearching, setIsSearching] = useState(false);
    const [searchError, setSearchError] = useState('');

    const handleEmailSearch = async () => {
        if (!emailInput.trim()) {
            setSearchError('Please enter an email address');
            return;
        }

        setIsSearching(true);
        setSearchError('');

        try {
            const userInfo = await fetchWithAuth(`/user/info?email=${encodeURIComponent(emailInput.trim())}`);

            if (userInfo && userInfo.uid) {
                // Navigate to the user detail page
                navigate(`/users/${userInfo.uid}`);
                setIsEmailModalOpen(false);
                setEmailInput('');
            } else {
                setSearchError('User found but no UID available');
            }
        } catch (error) {
            if (error instanceof Error) {
                if (error.message.includes('404')) {
                    setSearchError('No user found with this email address');
                } else if (error.message.includes('400')) {
                    setSearchError('Invalid email format');
                } else {
                    setSearchError('Failed to search for user. Please try again.');
                }
            } else {
                setSearchError('An unexpected error occurred');
            }
        } finally {
            setIsSearching(false);
        }
    };

    const handleModalClose = () => {
        setIsEmailModalOpen(false);
        setEmailInput('');
        setSearchError('');
    };

    if (loading) {
        return (
            <div className="p-8">
                <div className="animate-pulse">
                    <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
                    <div className="space-y-4">
                        {[...Array(5)].map((_, i) => (
                            <div key={i} className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                                <div className="h-4 bg-gray-200 rounded w-1/3 mb-4"></div>
                                <div className="h-3 bg-gray-200 rounded w-1/2"></div>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        );
    }

    const users = data?.users ? Object.entries(data.users) : [];
    const userPermissions = data?.user_permissions || {};

    return (
        <div className="p-8">
            <div className="mb-8">
                <div className="flex items-center justify-between mb-2">
                    <h1 className="text-3xl font-bold text-gray-900">Users</h1>
                    <button
                        onClick={() => setIsEmailModalOpen(true)}
                        className="inline-flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                        <Search className="w-4 h-4" />
                        <span>Find by Email</span>
                    </button>
                </div>
                <p className="text-gray-600">Manage and view user information and their registered devices</p>
            </div>

            {/* Email Search Modal */}
            {isEmailModalOpen && (
                <div className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50">
                    <div className="bg-white rounded-xl shadow-lg max-w-md w-full mx-4">
                        <div className="flex items-center justify-between p-6 border-b border-gray-100">
                            <h2 className="text-xl font-semibold text-gray-900">Find User by Email</h2>
                            <button
                                onClick={handleModalClose}
                                className="text-gray-400 hover:text-gray-600 transition-colors"
                            >
                                <X className="w-5 h-5" />
                            </button>
                        </div>

                        <div className="p-6">
                            <div className="mb-4">
                                <label htmlFor="email-input" className="block text-sm font-medium text-gray-700 mb-2">
                                    Email Address
                                </label>
                                <input
                                    id="email-input"
                                    type="email"
                                    value={emailInput}
                                    onChange={(e) => setEmailInput(e.target.value)}
                                    onKeyPress={(e) => e.key === 'Enter' && handleEmailSearch()}
                                    placeholder="Enter email address..."
                                    className="w-full px-3 py-2 border border-gray-300 rounded-lg focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
                                    disabled={isSearching}
                                />
                            </div>

                            {searchError && (
                                <div className="mb-4 p-3 bg-red-50 border border-red-200 rounded-lg">
                                    <p className="text-sm text-red-600">{searchError}</p>
                                </div>
                            )}

                            <div className="flex space-x-3">
                                <button
                                    onClick={handleEmailSearch}
                                    disabled={isSearching}
                                    className="flex-1 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                                >
                                    {isSearching ? 'Searching...' : 'Search'}
                                </button>
                                <button
                                    onClick={handleModalClose}
                                    disabled={isSearching}
                                    className="px-4 py-2 bg-gray-200 text-gray-700 rounded-lg hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                                >
                                    Cancel
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
            )}

            {/* Stats */}
            <div className="grid grid-cols-1 md:grid-cols-4 gap-6 mb-8">
                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
                            <UsersIcon className="w-6 h-6 text-blue-600" />
                        </div>
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900">{users.length}</h3>
                    <p className="text-sm text-gray-600">Total Users</p>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                            <Smartphone className="w-6 h-6 text-green-600" />
                        </div>
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900">
                        {users.reduce((total, [, userData]) =>
                            total + Object.keys(userData.devices || {}).length, 0
                        )}
                    </h3>
                    <p className="text-sm text-gray-600">Total Devices</p>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
                            <User className="w-6 h-6 text-purple-600" />
                        </div>
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900">
                        {users.filter(([, userData]) =>
                            Object.keys(userData.devices || {}).length > 0
                        ).length}
                    </h3>
                    <p className="text-sm text-gray-600">Users with Devices</p>
                </div>

                <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
                    <div className="flex items-center justify-between mb-4">
                        <div className="w-12 h-12 bg-orange-100 rounded-lg flex items-center justify-center">
                            <Shield className="w-6 h-6 text-orange-600" />
                        </div>
                    </div>
                    <h3 className="text-2xl font-bold text-gray-900">
                        {Object.values(userPermissions).filter(permission => permission.admin).length}
                    </h3>
                    <p className="text-sm text-gray-600">Admin Users</p>
                </div>
            </div>

            {/* Users List */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100">
                <div className="p-6 border-b border-gray-100">
                    <h2 className="text-xl font-semibold text-gray-900">User Directory</h2>
                </div>

                {users.length === 0 ? (
                    <div className="p-8 text-center">
                        <UsersIcon className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                        <p className="text-gray-500">No users found</p>
                    </div>
                ) : (
                    <div className="divide-y divide-gray-100">
                        {users.map(([userId, userData]) => (
                            <Link
                                key={userId}
                                to={`/users/${userId}`}
                                className="block p-6 hover:bg-gray-50 transition-colors"
                            >
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center space-x-4">
                                        <div className="w-12 h-12 bg-blue-100 rounded-full flex items-center justify-center">
                                            <User className="w-6 h-6 text-blue-600" />
                                        </div>
                                        <div>
                                            <h3 className="text-lg font-medium text-gray-900">{userId}</h3>
                                            <div className="flex items-center space-x-4 text-sm text-gray-500">
                                                <span>User ID</span>
                                                <div className="flex items-center space-x-1">
                                                    <Smartphone className="w-4 h-4" />
                                                    <span>{Object.keys(userData.devices || {}).length} devices</span>
                                                </div>
                                                {userPermissions[userId]?.admin && (
                                                    <div className="flex items-center space-x-1">
                                                        <Shield className="w-4 h-4" />
                                                        <span className="text-orange-600 font-medium">Admin</span>
                                                    </div>
                                                )}
                                            </div>
                                        </div>
                                    </div>
                                    <ChevronRight className="w-5 h-5 text-gray-400" />
                                </div>
                            </Link>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
} 