import React from 'react';
import { useQuery } from '@tanstack/react-query';
import { Server, Database, Wifi } from 'lucide-react';
import { BACKEND_URL } from '../config/firebase';
import { fetchWithAuth } from '../utils/api';

function errorToString(error: unknown): string {
  if (error instanceof Error) return error.message;
  if (typeof error === 'string') return error;
  try {
    return JSON.stringify(error);
  } catch {
    return 'Unknown error';
  }
}

async function fetchInfo() {
  return fetchWithAuth('/info');
}

export default function Settings() {
  const { data, isLoading, error } = useQuery({
    queryKey: ['info'],
    queryFn: fetchInfo,
    refetchInterval: 30000, // Refetch every 30 seconds
  });

  return (
    <div className="p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-2">Settings</h1>
        <p className="text-gray-600">System configuration and backend information</p>
      </div>

      {/* Backend Info */}
      <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6 mb-8">
        <div className="flex items-center space-x-3 mb-6">
          <div className="w-12 h-12 bg-blue-100 rounded-lg flex items-center justify-center">
            <Server className="w-6 h-6 text-blue-600" />
          </div>
          <div>
            <h2 className="text-xl font-semibold text-gray-900">Backend Information</h2>
            <p className="text-sm text-gray-600">System status and configuration</p>
          </div>
        </div>

        {isLoading && (
          <div className="animate-pulse">
            <div className="space-y-4">
              {[...Array(4)].map((_, i) => (
                <div key={i} className="flex justify-between items-center">
                  <div className="h-4 bg-gray-200 rounded w-1/3"></div>
                  <div className="h-4 bg-gray-200 rounded w-1/4"></div>
                </div>
              ))}
            </div>
          </div>
        )}

        {error && (
          <div className="bg-red-50 border border-red-200 rounded-lg p-4">
            <div className="flex items-center space-x-2">
              <div className="w-5 h-5 bg-red-500 rounded-full flex-shrink-0"></div>
              <div>
                <p className="text-red-800 font-medium">Connection Error</p>
                <p className="text-red-700 text-sm">
                  {`Failed to connect to backend: ${errorToString(error)}`}
                </p>
              </div>
            </div>
          </div>
        )}

        {data && (
          <div className="space-y-4">
            {Object.entries(data).map(([key, value]) => (
              <div key={key} className="flex justify-between items-center py-3 border-b border-gray-100 last:border-b-0">
                <span className="text-gray-700 font-medium capitalize">
                  {key.replace(/[_-]/g, ' ')}
                </span>
                <span className="text-gray-900 font-mono text-sm bg-gray-100 px-2 py-1 rounded">
                  {typeof value === 'object' ? JSON.stringify(value) : String(value)}
                </span>
              </div>
            ))}
          </div>
        )}
      </div>

      {/* Configuration */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-orange-100 rounded-lg flex items-center justify-center">
              <Database className="w-5 h-5 text-orange-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900">Firebase Configuration</h3>
          </div>
          <div className="space-y-3">
            <div>
              <p className="text-sm text-gray-600">Project ID</p>
              <p className="text-sm font-mono bg-gray-100 px-2 py-1 rounded">
                {import.meta.env.VITE_FIREBASE_PROJECT_ID || 'Not configured'}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Database URL</p>
              <p className="text-sm font-mono bg-gray-100 px-2 py-1 rounded truncate">
                {import.meta.env.VITE_FIREBASE_DATABASE_URL || 'Not configured'}
              </p>
            </div>
          </div>
        </div>

        <div className="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
          <div className="flex items-center space-x-3 mb-4">
            <div className="w-10 h-10 bg-green-100 rounded-lg flex items-center justify-center">
              <Wifi className="w-5 h-5 text-green-600" />
            </div>
            <h3 className="text-lg font-semibold text-gray-900">Backend Configuration</h3>
          </div>
          <div className="space-y-3">
            <div>
              <p className="text-sm text-gray-600">Backend URL</p>
              <p className="text-sm font-mono bg-gray-100 px-2 py-1 rounded">
                {BACKEND_URL}
              </p>
            </div>
            <div>
              <p className="text-sm text-gray-600">Status</p>
              <div className="flex items-center space-x-2">
                <div className={`w-3 h-3 rounded-full ${error ? 'bg-red-500' : 'bg-green-500'}`}></div>
                <span className="text-sm">{error ? 'Disconnected' : 'Connected'}</span>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}