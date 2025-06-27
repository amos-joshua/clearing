import React from 'react';
import { Link } from 'react-router-dom';
import { Phone, Clock, Users, TrendingUp } from 'lucide-react';
import { useFirebaseData } from '../hooks/useFirebaseData';
import { formatRelativeTime, formatAbsoluteTime } from '../utils/dateUtils';

export default function Dashboard() {
  const { data, loading } = useFirebaseData();

  if (loading) {
    return (
      <div className="p-8">
        <div className="animate-pulse">
          <div className="h-8 bg-gray-200 rounded w-1/4 mb-6"></div>
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {[...Array(4)].map((_, i) => (
              <div key={i} className="bg-white p-6 rounded-xl shadow-sm">
                <div className="h-4 bg-gray-200 rounded w-3/4 mb-4"></div>
                <div className="h-8 bg-gray-200 rounded w-1/2"></div>
              </div>
            ))}
          </div>
        </div>
      </div>
    );
  }

  const calls = data?.calls ? Object.entries(data.calls) : [];
  const latestCall = calls.length > 0 ? calls.sort(
    ([, a], [, b]) => new Date(b['created-at']).getTime() - new Date(a['created-at']).getTime()
  )[0] : null;

  const stats = {
    totalCalls: calls.length,
    activeCalls: calls.filter(([, call]) => 
      (call.SENDER?.state && !['ENDED', 'FAILED'].includes(call.SENDER.state)) ||
      (call.RECEIVER?.state && !['ENDED', 'FAILED'].includes(call.RECEIVER.state))
    ).length,
    endedCalls: calls.filter(([, call]) => 
      call.SENDER?.state === 'ENDED' || call.RECEIVER?.state === 'ENDED'
    ).length,
    users: data?.users ? Object.keys(data.users).length : 0
  };

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Dashboard</h1>
        <p className="text-gray-600">Overview of call activity and system status</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
              <Phone className="w-6 h-6 text-blue-600" />
            </div>
            <TrendingUp className="w-5 h-5 text-green-500" />
          </div>
          <h3 className="text-2xl font-bold text-gray-900">{stats.totalCalls}</h3>
          <p className="text-sm text-gray-600">Total Calls</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-green-100 rounded-lg flex items-center justify-center">
              <Clock className="w-6 h-6 text-green-600" />
            </div>
          </div>
          <h3 className="text-2xl font-bold text-gray-900">{stats.activeCalls}</h3>
          <p className="text-sm text-gray-600">Active Calls</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-red-100 rounded-lg flex items-center justify-center">
              <Phone className="w-6 h-6 text-red-600" />
            </div>
          </div>
          <h3 className="text-2xl font-bold text-gray-900">{stats.endedCalls}</h3>
          <p className="text-sm text-gray-600">Ended Calls</p>
        </div>

        <div className="bg-white p-6 rounded-xl shadow-sm border border-gray-100">
          <div className="flex items-center justify-between mb-4">
            <div className="w-12 h-12 bg-purple-100 rounded-lg flex items-center justify-center">
              <Users className="w-6 h-6 text-purple-600" />
            </div>
          </div>
          <h3 className="text-2xl font-bold text-gray-900">{stats.users}</h3>
          <p className="text-sm text-gray-600">Active Users</p>
        </div>
      </div>

      {/* Latest Call */}
      {latestCall && (
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center justify-between mb-6">
            <h2 className="text-xl font-semibold text-gray-900">Latest Call</h2>
            <Link
              to={`/call/${latestCall[0]}`}
              className="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition-colors text-sm"
            >
              View Details
            </Link>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div>
              <h3 className="font-medium text-gray-900 mb-4">Call Information</h3>
              <div className="space-y-3">
                <div>
                  <p className="text-sm text-gray-600">Call ID</p>
                  <p className="font-mono text-sm bg-gray-100 px-2 py-1 rounded">
                    {latestCall[0]}
                  </p>
                </div>
                <div>
                  <p className="text-sm text-gray-600">Created</p>
                  <p 
                    className="text-sm"
                    title={formatAbsoluteTime(latestCall[1]['created-at'])}
                  >
                    {formatRelativeTime(latestCall[1]['created-at'])}
                  </p>
                </div>
                {latestCall[1].SENDER && (
                  <div>
                    <p className="text-sm text-gray-600">Sender</p>
                    <p className="text-sm font-mono">{latestCall[1].SENDER['sender-uid']}</p>
                  </div>
                )}
                {latestCall[1].SENDER?.recipients && (
                  <div>
                    <p className="text-sm text-gray-600">Recipients</p>
                    <div className="space-y-1">
                      {latestCall[1].SENDER.recipients.map((recipient, index) => (
                        <p key={index} className="text-sm font-mono">{recipient}</p>
                      ))}
                    </div>
                  </div>
                )}
              </div>
            </div>

            <div>
              <h3 className="font-medium text-gray-900 mb-4">Current Status</h3>
              <div className="space-y-3">
                {latestCall[1].SENDER && (
                  <div className="flex items-center justify-between p-3 bg-blue-50 rounded-lg">
                    <span className="text-sm font-medium">Outgoing</span>
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      latestCall[1].SENDER.state === 'ENDED' 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-green-100 text-green-800'
                    }`}>
                      {latestCall[1].SENDER.state}
                    </span>
                  </div>
                )}
                {latestCall[1].RECEIVER && (
                  <div className="flex items-center justify-between p-3 bg-orange-50 rounded-lg">
                    <span className="text-sm font-medium">Incoming</span>
                    <span className={`px-3 py-1 rounded-full text-sm font-medium ${
                      latestCall[1].RECEIVER.state === 'ENDED' 
                        ? 'bg-red-100 text-red-800' 
                        : 'bg-yellow-100 text-yellow-800'
                    }`}>
                      {latestCall[1].RECEIVER.state}
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}