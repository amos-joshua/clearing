import { auth } from '../config/firebase';
import { BACKEND_URL } from '../config/firebase';

export async function authenticatedFetch(endpoint: string, options: RequestInit = {}) {
    const user = auth.currentUser;
    if (!user) {
        throw new Error('User not authenticated');
    }

    const token = await user.getIdToken();
    if (!token) {
        throw new Error('Failed to get authentication token');
    }

    const response = await fetch(`${BACKEND_URL}${endpoint}`, {
        ...options,
        headers: {
            'Authorization': `Bearer ${token}`,
            'Content-Type': 'application/json',
            ...options.headers,
        },
    });

    if (!response.ok) {
        if (response.status === 401) {
            throw new Error('Authentication required');
        } else if (response.status === 403) {
            throw new Error('Insufficient permissions');
        } else {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
    }

    return response;
}

export async function fetchWithAuth(endpoint: string, options: RequestInit = {}): Promise<any> {
    const response = await authenticatedFetch(endpoint, options);
    return response;
} 