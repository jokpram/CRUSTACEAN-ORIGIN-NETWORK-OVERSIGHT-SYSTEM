import { useState, useEffect } from 'react';
import { dashboardApi } from '../../api/traceabilityApi';
import { LoadingSpinner, ErrorState, StatCard } from '../../components/ui';
import { FiTruck, FiCheckCircle, FiClock, FiPackage } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
export default function LogistikDashboard() {
    const [data, setData] = useState<Record<string, unknown> | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { dashboardApi.getLogistik().then(r => setData(r.data.data)).catch(() => setError(t('logistik.dashboard.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    const statuses = (data?.shipment_status || {}) as Record<string, number>;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('logistik.dashboard.title')}</h1>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
                <StatCard title={t('logistik.dashboard.total_shipments')} value={(data?.total_shipments as number) || 0} icon={<FiTruck className="w-5 h-5" />} color="primary" />
                <StatCard title={t('logistik.dashboard.pending')} value={statuses.pending || 0} icon={<FiClock className="w-5 h-5" />} color="orange" />
                <StatCard title={t('logistik.dashboard.in_transit')} value={statuses.transit || 0} icon={<FiPackage className="w-5 h-5" />} color="ocean" />
                <StatCard title={t('logistik.dashboard.delivered')} value={statuses.delivered || 0} icon={<FiCheckCircle className="w-5 h-5" />} color="accent" />
            </div>
        </div>
    );
}
