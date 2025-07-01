import React from 'react';
import { Link } from 'react-router-dom';
import { Users as UsersIcon, Smartphone, User, ChevronRight, Shield } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';

interface UserData {
    devices: {
        [deviceId: string]: string;
    };
}

export default function Users() {
    const { data, loading } = useFirebaseData();

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
                <h1 className="text-3xl font-bold text-gray-900 mb-2">Users</h1>
                <p className="text-gray-600">Manage and view user information and their registered devices</p>
            </div>

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