import { useState, useEffect } from 'react';
import { orderApi } from '../../api/orderApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge } from '../../components/ui';
import type { Order } from '../../types';
import { useTranslation } from 'react-i18next';
export default function AdminOrders() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => {
        orderApi.getAllOrders().then(res => setOrders(res.data.data || [])).catch(() => setError(t('admin.orders.err_load'))).finally(() => setLoading(false));
    }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    if (!orders.length) return <EmptyState title={t('admin.orders.empty_title')} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('admin.orders.title')}</h1>
            <div className="card overflow-x-auto">
                <table className="w-full text-sm">
                    <thead className="bg-gray-50 border-b"><tr>
                        <th className="text-left p-4 font-semibold">{t('admin.orders.col_id')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.orders.col_customer')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.orders.col_amount')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.orders.col_status')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.orders.col_date')}</th>
                    </tr></thead>
                    <tbody className="divide-y">{orders.map(o => (
                        <tr key={o.id} className="hover:bg-gray-50">
                            <td className="p-4 font-mono text-xs">{o.id.slice(0, 8)}...</td>
                            <td className="p-4">{o.user?.name || '-'}</td>
                            <td className="p-4 font-medium">Rp {o.total_amount?.toLocaleString()}</td>
                            <td className="p-4"><StatusBadge status={o.status} /></td>
                            <td className="p-4 text-gray-500">{new Date(o.created_at).toLocaleDateString()}</td>
                        </tr>
                    ))}</tbody>
                </table>
            </div>
        </div>
    );
}
