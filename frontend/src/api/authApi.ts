import api from './axios';
export const authApi = {
    register: (data: { name: string; email: string; password: string; phone?: string; role: string }) =>
        api.post('/auth/register', data),
    login: (data: { email: string; password: string }) =>
        api.post('/auth/login', data),
    getProfile: () =>
        api.get('/auth/profile'),
    updateProfile: (data: { name?: string; phone?: string; address?: string; avatar?: string }) =>
        api.put('/auth/profile', data),
};
