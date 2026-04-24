import { create } from 'zustand';
import type { User } from '../types';
interface AuthState {
    user: User | null;
    token: string | null;
    isAuthenticated: boolean;
    setAuth: (user: User, token: string) => void;
    logout: () => void;
    updateUser: (user: Partial<User>) => void;
}
export const useAuthStore = create<AuthState>((set) => ({
    user: JSON.parse(localStorage.getItem('cronos_user') || 'null'),
    token: localStorage.getItem('cronos_token'),
    isAuthenticated: !!localStorage.getItem('cronos_token'),
    setAuth: (user, token) => {
        localStorage.setItem('cronos_token', token);
        localStorage.setItem('cronos_user', JSON.stringify(user));
        set({ user, token, isAuthenticated: true });
    },
    logout: () => {
        localStorage.removeItem('cronos_token');
        localStorage.removeItem('cronos_user');
        set({ user: null, token: null, isAuthenticated: false });
    },
    updateUser: (updatedFields) => {
        set((state) => {
            const newUser = state.user ? { ...state.user, ...updatedFields } : null;
            if (newUser) localStorage.setItem('cronos_user', JSON.stringify(newUser));
            return { user: newUser };
        });
    },
}));
