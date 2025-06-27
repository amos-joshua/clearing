import { useState, useEffect } from 'react';
import { User, onAuthStateChanged, signInWithPopup, signOut, signInWithEmailAndPassword } from 'firebase/auth';
import { ref, get } from 'firebase/database';
import { auth, googleProvider, database } from '../config/firebase';

export interface AuthUser extends User {
  isAdmin?: boolean;
}

export function useAuth() {
  const [user, setUser] = useState<AuthUser | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        try {
          // Check admin permissions from Firebase Realtime Database
          const permissionsRef = ref(database, `user_permissions/${firebaseUser.uid}/admin`);
          const snapshot = await get(permissionsRef);
          const isAdmin = snapshot.exists() && snapshot.val() === true;

          const authUser: AuthUser = {
            ...firebaseUser,
            isAdmin
          };
          setUser(authUser);
        } catch (error) {
          console.error('Error checking admin permissions:', error);
          // If there's an error reading permissions, default to not admin
          const authUser: AuthUser = {
            ...firebaseUser,
            isAdmin: false
          };
          setUser(authUser);
        }
      } else {
        setUser(null);
      }
      setLoading(false);
    });

    return unsubscribe;
  }, []);

  const loginWithGoogle = async () => {
    try {
      await signInWithPopup(auth, googleProvider);
    } catch (error) {
      console.error('Google login error:', error);
      throw error;
    }
  };

  const loginWithEmail = async (email: string, password: string) => {
    try {
      await signInWithEmailAndPassword(auth, email, password);
    } catch (error) {
      console.error('Email login error:', error);
      throw error;
    }
  };

  const logout = async () => {
    try {
      await signOut(auth);
    } catch (error) {
      console.error('Logout error:', error);
    }
  };

  return { user, loading, loginWithGoogle, loginWithEmail, logout };
}