import React, { useEffect } from 'react';
import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import Login from './pages/Login';
import Dashboard from './pages/Dashboard';
import Users from './pages/Users';
import UserDetail from './pages/UserDetail';
import Settings from './pages/Settings';
import CallDetails from './pages/CallDetails';
import ServerLogs from './pages/ServerLogs';
import PushNotificationLogs from './pages/PushNotificationLogs';
import Layout from './components/Layout';
import ProtectedRoute from './components/ProtectedRoute';
import EnvironmentBanner from './components/EnvironmentBanner';
import VersionDisplay from './components/VersionDisplay';
import { getEnvironment } from './config/environment';

const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      staleTime: 5 * 60 * 1000, // 5 minutes
      refetchOnWindowFocus: false,
    },
  },
});

function App() {
  const environment = getEnvironment();

  useEffect(() => {
    const getEnvironmentDisplay = (env: string): string => {
      switch (env) {
        case 'development':
          return 'DEV';
        case 'staging':
          return 'STAGING';
        case 'production':
          return 'PROD';
        default:
          return 'DEV';
      }
    };

    const envDisplay = getEnvironmentDisplay(environment);
    document.title = `Clearing - ${envDisplay}`;
  }, [environment]);

  return (
    <QueryClientProvider client={queryClient}>
      <Router>
        <EnvironmentBanner environment={environment} />
        <Routes>
          <Route path="/login" element={<Login />} />
          <Route
            path="/*"
            element={
              <ProtectedRoute>
                <Layout />
              </ProtectedRoute>
            }
          >
            <Route index element={<Navigate to="/dashboard" replace />} />
            <Route path="dashboard" element={<Dashboard />} />
            <Route path="users" element={<Users />} />
            <Route path="users/:userId" element={<UserDetail />} />
            <Route path="settings" element={<Settings />} />
            <Route path="call/:callId" element={<CallDetails />} />
            <Route path="server-logs" element={<ServerLogs />} />
            <Route path="push-notification-logs" element={<PushNotificationLogs />} />
          </Route>
        </Routes>
        <VersionDisplay />
      </Router>
    </QueryClientProvider>
  );
}

export default App;