import api from './axios';
export const paymentApi = {
    createPayment: (orderId: string) => api.post('/payments/create', { order_id: orderId }),
    getPayment: (orderId: string) => api.get(`/payments/${orderId}`),
};
export const shipmentApi = {
    create: (data: Record<string, unknown>) => api.post('/admin/shipments', data),
    getMyShipments: () => api.get('/shipments'),
    getAllShipments: () => api.get('/admin/shipments'),
    updateStatus: (id: string, data: { status: string; location?: string; notes?: string }) =>
        api.put(`/shipments/${id}/status`, data),
    getLogs: (id: string) => api.get(`/shipments/${id}/logs`),
};
export const withdrawalApi = {
    create: (data: { amount: number; bank_name: string; account_number: string; account_name: string }) =>
        api.post('/withdrawals', data),
    getMyWithdrawals: () => api.get('/withdrawals'),
    getAllWithdrawals: () => api.get('/admin/withdrawals'),
    update: (id: string, data: { status: string; notes?: string }) =>
        api.put(`/admin/withdrawals/${id}`, data),
};
