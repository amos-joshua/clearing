import { initializeApp } from 'firebase/app';
import { connectAuthEmulator, getAuth, GoogleAuthProvider } from 'firebase/auth';
import { connectDatabaseEmulator, getDatabase } from 'firebase/database';
import { getEnvironment, isDevelopment, isProduction } from './environment';

// Configure these values in your environment or config
const firebaseConfig = {
  apiKey: import.meta.env.VITE_FIREBASE_API_KEY || "your-api-key",
  authDomain: import.meta.env.VITE_FIREBASE_AUTH_DOMAIN || "your-project-id.firebaseapp.com",
  databaseURL: import.meta.env.VITE_FIREBASE_DATABASE_URL || "https://your-project-id-default-rtdb.firebaseio.com/",
  projectId: import.meta.env.VITE_FIREBASE_PROJECT_ID || "your-project-id",
  storageBucket: import.meta.env.VITE_FIREBASE_STORAGE_BUCKET || "your-project-id.appspot.com",
  messagingSenderId: import.meta.env.VITE_FIREBASE_MESSAGING_SENDER_ID || "123456789",
  appId: import.meta.env.VITE_FIREBASE_APP_ID || "1:123456789:web:abcdef123456"
};

// Log Firebase configuration in dev and staging (but not production)
if (!isProduction()) {
  console.log('Firebase Configuration:');
  console.log('Environment:', getEnvironment());
  console.log('Project ID:', firebaseConfig.projectId);
  console.log('Auth Domain:', firebaseConfig.authDomain);
  console.log('Database URL:', firebaseConfig.databaseURL);
  console.log('Storage Bucket:', firebaseConfig.storageBucket);
  console.log('Messaging Sender ID:', firebaseConfig.messagingSenderId);
  console.log('App ID:', firebaseConfig.appId);
  console.log('API Key:', firebaseConfig.apiKey ? `${firebaseConfig.apiKey.substring(0, 10)}...` : 'Not set');
  console.log('Backend URL:', import.meta.env.VITE_BACKEND_URL || 'http://localhost:8000');
  console.log('---');
}


const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
if (isDevelopment()) {
  const emulatorUrl = import.meta.env.VITE_FIREBASE_AUTH_EMULATOR_URL || 'http://localhost:9099';
  console.log('🔧 Connecting to Firebase Auth Emulator:', emulatorUrl);
  connectAuthEmulator(auth, emulatorUrl, { disableWarnings: false });
}

export { auth };
//export const auth = getAuth(app);
export const database = getDatabase(app, firebaseConfig.databaseURL);
if (isDevelopment()) {
  // Parse host and port from databaseURL
  const url = new URL(firebaseConfig.databaseURL);
  const host = url.hostname;
  const port = parseInt(url.port) || 9000; // Default to 9000 if no port specified
  console.log('🔧 Connecting to Firebase Database Emulator:', `${host}, ${port}`);
  connectDatabaseEmulator(database, host, port);
}
export const googleProvider = new GoogleAuthProvider();

export const BACKEND_URL = import.meta.env.VITE_BACKEND_URL || "http://localhost:8000";