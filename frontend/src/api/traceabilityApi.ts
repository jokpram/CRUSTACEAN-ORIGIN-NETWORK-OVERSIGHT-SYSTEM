import api from './axios';
export const traceabilityApi = {
    getByBatchCode: (batchCode: string) => api.get(`/traceability/${batchCode}`),
    getAllLogs: () => api.get('/admin/traceability/logs'),
    verifyChain: () => api.get('/admin/traceability/verify'),
};
export const reviewApi = {
    create: (data: { product_id: string; rating: number; comment: string }) =>
        api.post('/reviews', data),
    getByProduct: (productId: string) => api.get(`/products/${productId}/reviews`),
};
export const userApi = {
    getAll: (params?: Record<string, string>) => api.get('/admin/users', { params }),
    verify: (id: string) => api.put(`/admin/users/${id}/verify`),
    updateStatus: (id: string, data: { is_verified: boolean }) =>
        api.put(`/admin/users/${id}/status`, data),
    create: (data: Record<string, any>) => api.post('/admin/users', data),
};
export const shrimpTypeApi = {
    getAll: () => api.get('/shrimp-types'),
    create: (data: { name: string; description?: string; image?: string }) =>
        api.post('/admin/shrimp-types', data),
    update: (id: string, data: Record<string, unknown>) => api.put(`/admin/shrimp-types/${id}`, data),
    delete: (id: string) => api.delete(`/admin/shrimp-types/${id}`),
};
export const dashboardApi = {
    getAdmin: () => api.get('/admin/dashboard'),
    getPetambak: () => api.get('/dashboard/petambak'),
    getLogistik: () => api.get('/dashboard/logistik'),
    getKonsumen: () => api.get('/dashboard/konsumen'),
};
