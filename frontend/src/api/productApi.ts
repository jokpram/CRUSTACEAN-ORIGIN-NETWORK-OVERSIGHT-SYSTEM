import api from './axios';
export const productApi = {
    getMarketplace: (params?: Record<string, string>) =>
        api.get('/products', { params }),
    getProduct: (id: string) => api.get(`/products/${id}`),
    getMyProducts: () => api.get('/products/my'),
    create: (data: Record<string, unknown>) => api.post('/products', data),
    update: (id: string, data: Record<string, unknown>) => api.put(`/products/${id}`, data),
    delete: (id: string) => api.delete(`/products/${id}`),
    getReviews: (id: string) => api.get(`/products/${id}/reviews`),
};
