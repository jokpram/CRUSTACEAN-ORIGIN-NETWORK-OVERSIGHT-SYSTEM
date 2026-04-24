import api from './axios';
export const orderApi = {
    create: (data: { shipping_address: string; notes?: string; items: { product_id: string; quantity: number }[] }) =>
        api.post('/orders', data),
    getMyOrders: (params?: Record<string, string>) => api.get('/orders', { params }),
    getAllOrders: (params?: Record<string, string>) => api.get('/admin/orders', { params }),
    getOrder: (id: string) => api.get(`/orders/${id}`),
    cancel: (id: string) => api.put(`/orders/${id}/cancel`),
    getSellerOrders: () => api.get('/sales'),
};
