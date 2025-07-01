import React from 'react';
import { Link, useParams } from 'react-router-dom';
import { ArrowLeft, User, Smartphone, Shield } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';

export default function UserDetail() {
    const { userId } = useParams<{ userId: string }>();
    const { data, loading } = useFirebaseData();

    if (loading) {
        return (
            <div className="p-8">
                <div className="animate-pulse">
                    <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
                    <div className="space-y-4">
                        {[...Array(3)].map((_, i) => (
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

    if (!userId || !data?.users?.[userId]) {
        return (
            <div className="p-8">
                <div className="text-center">
                    <User className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                    <h2 className="text-xl font-semibold text-gray-900 mb-2">User Not Found</h2>
                    <p className="text-gray-500 mb-6">The user you're looking for doesn't exist.</p>
                    <Link
                        to="/users"
                        className="inline-flex items-center space-x-2 px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors"
                    >
                        <ArrowLeft className="w-4 h-4" />
                        <span>Back to Users</span>
                    </Link>
                </div>
            </div>
        );
    }

    const userData = data.users[userId];
    const devices = userData.devices || {};
    const userPermissions = data?.user_permissions || {};
    const isAdmin = userPermissions[userId]?.admin || false;

    return (
        <div className="p-8">
            {/* Header */}
            <div className="mb-8">
                <Link
                    to="/users"
                    className="inline-flex items-center space-x-2 text-gray-600 hover:text-gray-900 mb-4 transition-colors"
                >
                    <ArrowLeft className="w-4 h-4" />
                    <span>Back to Users</span>
                </Link>

                <div className="flex items-center justify-between">
                    <div>
                        <h1 className="text-3xl font-bold text-gray-900 mb-2">User Details</h1>
                        <p className="text-gray-600">Manage user information and devices</p>
                    </div>
                </div>
            </div>

            {/* User Information */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-8">
                <div className="flex items-center space-x-4 mb-6">
                    <div className="w-16 h-16 bg-blue-100 rounded-full flex items-center justify-center">
                        <User className="w-8 h-8 text-blue-600" />
                    </div>
                    <div className="flex-1">
                        <div className="flex items-center space-x-3">
                            <h2 className="text-2xl font-semibold text-gray-900">{userId}</h2>
                            {isAdmin && (
                                <div className="flex items-center space-x-1 px-3 py-1 bg-orange-100 text-orange-800 rounded-full">
                                    <Shield className="w-4 h-4" />
                                    <span className="text-sm font-medium">Admin</span>
                                </div>
                            )}
                        </div>
                        <p className="text-gray-500">User ID</p>
                    </div>
                </div>

                <div>
                    <h3 className="text-lg font-medium text-gray-900 mb-4">User Statistics</h3>
                    <div className="space-y-3">
                        <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                            <span className="text-gray-600">Total Devices</span>
                            <span className="font-semibold text-gray-900">{Object.keys(devices).length}</span>
                        </div>
                        <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                            <span className="text-gray-600">Account Status</span>
                            <span className="px-2 py-1 bg-green-100 text-green-800 text-sm rounded-full">
                                Active
                            </span>
                        </div>
                        <div className="flex justify-between items-center p-3 bg-gray-50 rounded-lg">
                            <span className="text-gray-600">Admin Access</span>
                            <span className={`px-2 py-1 text-sm rounded-full ${isAdmin
                                ? 'bg-orange-100 text-orange-800'
                                : 'bg-gray-100 text-gray-600'
                                }`}>
                                {isAdmin ? 'Yes' : 'No'}
                            </span>
                        </div>
                    </div>
                </div>
            </div>

            {/* Devices Section */}
            <div className="bg-white rounded-xl shadow-sm border border-gray-100">
                <div className="p-6 border-b border-gray-100">
                    <div className="flex items-center justify-between">
                        <div className="flex items-center space-x-3">
                            <Smartphone className="w-6 h-6 text-gray-600" />
                            <h2 className="text-xl font-semibold text-gray-900">Registered Devices</h2>
                        </div>
                        <span className="px-3 py-1 bg-blue-100 text-blue-800 text-sm rounded-full">
                            {Object.keys(devices).length} devices
                        </span>
                    </div>
                </div>

                {Object.keys(devices).length === 0 ? (
                    <div className="p-8 text-center">
                        <Smartphone className="w-12 h-12 text-gray-400 mx-auto mb-4" />
                        <p className="text-gray-500">No devices registered for this user</p>
                    </div>
                ) : (
                    <div className="divide-y divide-gray-100">
                        {Object.entries(devices).map(([deviceId, deviceName]) => (
                            <div key={deviceId} className="p-6">
                                <div className="flex items-center justify-between">
                                    <div className="flex items-center space-x-4">
                                        <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
                                            <Smartphone className="w-6 h-6 text-green-600" />
                                        </div>
                                        <div>
                                            <h3 className="text-lg font-medium text-gray-900">{deviceName}</h3>
                                            <p className="text-sm text-gray-500 font-mono">{deviceId}</p>
                                        </div>
                                    </div>
                                    <div className="flex items-center">
                                        <span className="px-3 py-1 bg-green-100 text-green-800 text-sm rounded-full">
                                            Active
                                        </span>
                                    </div>
                                </div>
                            </div>
                        ))}
                    </div>
                )}
            </div>
        </div>
    );
} 