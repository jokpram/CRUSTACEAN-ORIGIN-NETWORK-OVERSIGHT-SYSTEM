import { useState, useEffect } from 'react';
import { dashboardApi } from '../../api/traceabilityApi';
import { LoadingSpinner, ErrorState, StatCard } from '../../components/ui';
import { FiMap, FiPackage, FiDroplet, FiScissors, FiDollarSign } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
export default function PetambakDashboard() {
    const [data, setData] = useState<Record<string, unknown> | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { dashboardApi.getPetambak().then(r => setData(r.data.data)).catch(() => setError(t('petambak.dashboard.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('petambak.dashboard.title')}</h1>
            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-5 gap-6">
                <StatCard title={t('petambak.dashboard.farms')} value={(data?.total_farms as number) || 0} icon={<FiMap className="w-5 h-5" />} color="primary" />
                <StatCard title={t('petambak.dashboard.products')} value={(data?.total_products as number) || 0} icon={<FiPackage className="w-5 h-5" />} color="accent" />
                <StatCard title={t('petambak.dashboard.cultivations')} value={(data?.total_cultivations as number) || 0} icon={<FiDroplet className="w-5 h-5" />} color="ocean" />
                <StatCard title={t('petambak.dashboard.harvests')} value={(data?.total_harvests as number) || 0} icon={<FiScissors className="w-5 h-5" />} color="orange" />
                <StatCard title={t('petambak.dashboard.revenue')} value={`Rp ${((data?.total_revenue as number) || 0).toLocaleString()}`} icon={<FiDollarSign className="w-5 h-5" />} color="purple" />
            </div>
        </div>
    );
}
