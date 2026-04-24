import { useState, useEffect } from 'react';
import { dashboardApi } from '../../api/traceabilityApi';
import { LoadingSpinner, ErrorState, StatCard, StatusBadge } from '../../components/ui';
import { FiShoppingBag, FiFileText } from 'react-icons/fi';
import type { Order } from '../../types';
import { Link } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
export default function KonsumenDashboard() {
    const [data, setData] = useState<Record<string, unknown> | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { dashboardApi.getKonsumen().then(r => setData(r.data.data)).catch(() => setError(t('konsumen.dashboard.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    const recentOrders = (data?.recent_orders || []) as Order[];
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('konsumen.dashboard.title')}</h1>
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mb-8">
                <StatCard title={t('konsumen.dashboard.total_orders')} value={(data?.total_orders as number) || 0} icon={<FiShoppingBag className="w-5 h-5" />} color="primary" />
                <StatCard title={t('konsumen.dashboard.recent_orders')} value={recentOrders.length} icon={<FiFileText className="w-5 h-5" />} color="accent" />
            </div>
            <div className="card p-6">
                <div className="flex justify-between items-center mb-4">
                    <h2 className="font-semibold text-lg">{t('konsumen.dashboard.recent_orders')}</h2>
                    <Link to="/konsumen/orders" className="text-primary-600 text-sm hover:underline">{t('konsumen.dashboard.view_all')}</Link>
                </div>
                {recentOrders.length === 0 ? <p className="text-gray-500 text-sm">{t('konsumen.dashboard.no_orders_yet')}<Link to="/marketplace" className="text-primary-600 hover:underline">{t('konsumen.dashboard.visit_marketplace')}</Link>{t('konsumen.dashboard.exclamation')}</p> : (
                    <div className="space-y-3">{recentOrders.map(o => (
                        <div key={o.id} className="flex items-center justify-between py-2 border-b last:border-0">
                            <div><p className="font-mono text-xs">{o.id?.slice(0, 8)}...</p><p className="text-sm text-gray-500">Rp {o.total_amount?.toLocaleString()}</p></div>
                            <StatusBadge status={o.status} />
                        </div>
                    ))}</div>
                )}
            </div>
        </div>
    );
}
