import { Link, useLocation } from 'react-router-dom';
import { Home, Settings, LogOut, User, AlertCircle } from 'lucide-react';
import { useAuth } from '../hooks/useAuth';
import { useFirebaseData } from '../hooks/useFirebaseData';
import { useViewedLogs } from '../hooks/useViewedLogs';
import { getStateColorClasses } from '../utils/colors';
import { CallsSection } from './CallsSection';

export default function Sidebar() {
  const location = useLocation();
  const { user, logout } = useAuth();
  const { data } = useFirebaseData();
  const { hasNewLogs, markAllAsViewed } = useViewedLogs();

  const isActive = (path: string) => location.pathname === path;

  const calls = data?.calls ? Object.entries(data.calls).sort(
    ([, a], [, b]) => new Date(b['created-at']).getTime() - new Date(a['created-at']).getTime()
  ) : [];

  const handleServerLogsClick = () => {
    markAllAsViewed();
  };

  return (
    <div className="w-80 bg-gray-900 text-white flex flex-col">
      {/* Header */}
      <div className="p-6 border-b border-gray-700">
        <div className="flex items-center space-x-3">
          <div className="w-10 h-10 bg-blue-600 rounded-full flex items-center justify-center">
            <User className="w-6 h-6" />
          </div>
          <div>
            <p className="font-semibold">{user?.displayName}</p>
            <p className="text-sm text-gray-400">{user?.email}</p>
          </div>
        </div>
      </div>

      {/* Navigation */}
      <nav className="flex-1 overflow-y-auto">
        <div className="p-4 space-y-2">
          <Link
            to="/dashboard"
            className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive('/dashboard')
              ? 'bg-blue-600 text-white'
              : 'text-gray-300 hover:bg-gray-800'
              }`}
          >
            <Home className="w-5 h-5" />
            <span>Dashboard</span>
          </Link>

          <Link
            to="/settings"
            className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive('/settings')
              ? 'bg-blue-600 text-white'
              : 'text-gray-300 hover:bg-gray-800'
              }`}
          >
            <Settings className="w-5 h-5" />
            <span>Settings</span>
          </Link>
        </div>

        {/* Calls Section */}
        <CallsSection calls={calls} getStateColorClasses={getStateColorClasses} />
      </nav>

      {/* Footer */}
      <div className="p-4 border-t border-gray-700 space-y-2">
        <Link
          to="/push-notification-logs"
          onClick={() => markAllAsViewed('push_notifications')}
          className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive('/push-notification-logs')
            ? 'bg-blue-600 text-white'
            : 'text-gray-300 hover:bg-gray-800'
            }`}
        >
          <AlertCircle className="w-5 h-5" />
          <span>Push Notification Logs</span>
          {hasNewLogs('push_notifications') && (
            <span className="ml-auto bg-red-500 text-white text-xs px-2 py-1 rounded-full">
              New
            </span>
          )}
        </Link>

        <Link
          to="/server-logs"
          onClick={() => markAllAsViewed('server')}
          className={`flex items-center space-x-3 px-4 py-3 rounded-lg transition-colors ${isActive('/server-logs')
            ? 'bg-blue-600 text-white'
            : 'text-gray-300 hover:bg-gray-800'
            }`}
        >
          <AlertCircle className="w-5 h-5" />
          <span>Server Logs</span>
          {hasNewLogs('server') && (
            <span className="ml-auto bg-red-500 text-white text-xs px-2 py-1 rounded-full">
              New
            </span>
          )}
        </Link>

        <button
          onClick={logout}
          className="flex items-center space-x-3 px-4 py-3 rounded-lg text-gray-300 hover:bg-gray-800 w-full transition-colors"
        >
          <LogOut className="w-5 h-5" />
          <span>Logout</span>
        </button>
      </div>
    </div>
  );
}