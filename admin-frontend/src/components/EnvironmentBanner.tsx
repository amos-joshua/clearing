import React from 'react';
import { Environment, shouldShowBanner } from '../config/environment';

interface EnvironmentBannerProps {
    environment: Environment;
}

const EnvironmentBanner: React.FC<EnvironmentBannerProps> = ({ environment }) => {
    // Don't show banner for production
    if (!shouldShowBanner()) {
        return null;
    }

    const getBannerColor = (env: Environment) => {
        switch (env) {
            case 'development':
                return 'bg-red-500';
            case 'staging':
                return 'bg-green-500';
            case 'production':
                return 'bg-blue-500';
        }
    };

    const getBannerText = (env: Environment) => {
        switch (env) {
            case 'development':
                return 'DEV';
            case 'staging':
                return 'STAGING';
            case 'production':
                return 'PROD';
        }
    };

    return (
        <div className="fixed top-4 right-4 z-50 pointer-events-none">
            <div
                className={`${getBannerColor(environment)} text-white px-3 py-1 rounded-md text-xs font-bold shadow-lg`}
                style={{
                    transform: 'rotate(12deg)',
                    boxShadow: '0 2px 8px rgba(0, 0, 0, 0.3)',
                }}
            >
                {getBannerText(environment)}
            </div>
        </div>
    );
};

export default EnvironmentBanner; 