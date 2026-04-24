import api from './axios';
export const farmApi = {
    create: (data: { name: string; location?: string; area?: number; description?: string }) =>
        api.post('/farms', data),
    getMyFarms: () => api.get('/farms'),
    getFarm: (id: string) => api.get(`/farms/${id}`),
    update: (id: string, data: Record<string, unknown>) => api.put(`/farms/${id}`, data),
    delete: (id: string) => api.delete(`/farms/${id}`),
    createPond: (farmId: string, data: { name: string; area?: number; depth?: number; status?: string }) =>
        api.post(`/farms/${farmId}/ponds`, data),
    getPonds: (farmId: string) => api.get(`/farms/${farmId}/ponds`),
    updatePond: (pondId: string, data: Record<string, unknown>) => api.put(`/ponds/${pondId}`, data),
    deletePond: (pondId: string) => api.delete(`/ponds/${pondId}`),
};
export const cultivationApi = {
    create: (data: Record<string, unknown>) => api.post('/cultivations', data),
    getMyCycles: () => api.get('/cultivations'),
    getCycle: (id: string) => api.get(`/cultivations/${id}`),
    update: (id: string, data: Record<string, unknown>) => api.put(`/cultivations/${id}`, data),
    addFeedLog: (cycleId: string, data: Record<string, unknown>) =>
        api.post(`/cultivations/${cycleId}/feed-logs`, data),
    getFeedLogs: (cycleId: string) => api.get(`/cultivations/${cycleId}/feed-logs`),
    addWaterQuality: (cycleId: string, data: Record<string, unknown>) =>
        api.post(`/cultivations/${cycleId}/water-quality`, data),
    getWaterQuality: (cycleId: string) => api.get(`/cultivations/${cycleId}/water-quality`),
};
export const harvestApi = {
    create: (data: Record<string, unknown>) => api.post('/harvests', data),
    getMyHarvests: () => api.get('/harvests'),
};
export const batchApi = {
    create: (data: { harvest_id: string; quantity: number }) => api.post('/batches', data),
    getMyBatches: () => api.get('/batches'),
    getByCode: (code: string) => api.get(`/batches/${code}`),
};
