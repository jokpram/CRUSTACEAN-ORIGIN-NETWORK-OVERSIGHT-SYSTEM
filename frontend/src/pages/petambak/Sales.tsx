import { useState, useEffect } from 'react';
import { orderApi } from '../../api/orderApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge } from '../../components/ui';
import type { Order } from '../../types';
import { useTranslation } from 'react-i18next';
export default function PetambakSales() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { orderApi.getSellerOrders().then(r => setOrders(r.data.data || [])).catch(() => setError(t('petambak.sales.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('petambak.sales.title')}</h1>
            {!orders.length ? <EmptyState title={t('petambak.sales.empty_title')} message={t('petambak.sales.empty_desc')} /> : (
                <div className="card overflow-x-auto"><table className="w-full text-sm"><thead className="bg-gray-50 border-b"><tr>
                    <th className="text-left p-4 font-semibold">{t('petambak.sales.col_order')}</th><th className="text-left p-4 font-semibold">{t('petambak.sales.col_customer')}</th><th className="text-left p-4 font-semibold">{t('petambak.sales.col_amount')}</th><th className="text-left p-4 font-semibold">{t('petambak.sales.col_status')}</th>
                </tr></thead><tbody className="divide-y">{orders.map(o => (
                    <tr key={o.id} className="hover:bg-gray-50">
                        <td className="p-4 font-mono text-xs">{o.id.slice(0, 8)}...</td>
                        <td className="p-4">{o.user?.name || '-'}</td>
                        <td className="p-4 font-medium">Rp {o.total_amount?.toLocaleString()}</td>
                        <td className="p-4"><StatusBadge status={o.status} /></td>
                    </tr>
                ))}</tbody></table></div>
            )}
        </div>
    );
}
