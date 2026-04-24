import { useState, useEffect } from 'react';
import { dashboardApi } from '../../api/traceabilityApi';
import { LoadingSpinner, ErrorState, StatCard } from '../../components/ui';
import { FiUsers, FiShoppingBag, FiDollarSign, FiTrendingUp } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
export default function AdminDashboard() {
    const [data, setData] = useState<Record<string, unknown> | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => {
        dashboardApi.getAdmin()
            .then(res => setData(res.data.data))
            .catch(() => setError(t('admin.dashboard.err_load')))
            .finally(() => setLoading(false));
    }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    const users = (data?.users || {}) as Record<string, number>;
    const orders = (data?.orders || {}) as Record<string, number>;
    const totalRevenue = (data?.total_revenue || 0) as number;
    const totalOrders = Object.values(orders).reduce((a, b) => a + b, 0);
    const totalUsers = Object.values(users).reduce((a, b) => a + b, 0);
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('admin.dashboard.title')}</h1>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
                <StatCard title={t('admin.dashboard.total_users')} value={totalUsers} icon={<FiUsers className="w-5 h-5" />} color="primary" />
                <StatCard title={t('admin.dashboard.total_orders')} value={totalOrders} icon={<FiShoppingBag className="w-5 h-5" />} color="ocean" />
                <StatCard title={t('admin.dashboard.revenue')} value={`Rp ${totalRevenue.toLocaleString()}`} icon={<FiDollarSign className="w-5 h-5" />} color="accent" />
                <StatCard title={t('admin.dashboard.paid_orders')} value={orders.paid || 0} icon={<FiTrendingUp className="w-5 h-5" />} color="purple" />
            </div>
            <div className="grid md:grid-cols-2 gap-6">
                <div className="card p-6">
                    <h3 className="font-semibold mb-4">{t('admin.dashboard.users_by_role')}</h3>
                    <div className="space-y-3">
                        {Object.entries(users).map(([role, count]) => (
                            <div key={role} className="flex justify-between items-center">
                                <span className="text-sm text-gray-600 capitalize">{role}</span>
                                <span className="badge-info">{count}</span>
                            </div>
                        ))}
                    </div>
                </div>
                <div className="card p-6">
                    <h3 className="font-semibold mb-4">{t('admin.dashboard.orders_by_status')}</h3>
                    <div className="space-y-3">
                        {Object.entries(orders).map(([status, count]) => (
                            <div key={status} className="flex justify-between items-center">
                                <span className="text-sm text-gray-600 capitalize">{status}</span>
                                <span className="badge-gray">{count}</span>
                            </div>
                        ))}
                    </div>
                </div>
            </div>
        </div>
    );
}
