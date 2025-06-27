import React from 'react';

// Import the version from package.json
// Note: Vite automatically handles this import
import packageJson from '../../package.json';

export default function VersionDisplay() {
    return (
        <div className="fixed bottom-4 right-4 z-50">
            <div className="bg-gray-800 bg-opacity-75 text-gray-300 text-xs px-2 py-1 rounded-md font-mono">
                v{packageJson.version}
            </div>
        </div>
    );
} 