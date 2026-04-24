import { useState, useEffect } from 'react';
import { harvestApi } from '../../api/farmApi';
import { LoadingSpinner, EmptyState, ErrorState } from '../../components/ui';
import type { Harvest } from '../../types';
import { useTranslation } from 'react-i18next';
export default function PetambakHarvests() {
    const [harvests, setHarvests] = useState<Harvest[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { harvestApi.getMyHarvests().then(r => setHarvests(r.data.data || [])).catch(() => setError(t('petambak.harvests.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('petambak.harvests.title')}</h1>
            {!harvests.length ? <EmptyState title={t('petambak.harvests.empty_title')} /> : (
                <div className="space-y-4">{harvests.map(h => (
                    <div key={h.id} className="card p-5">
                        <div className="flex justify-between"><span className="font-semibold">{h.total_weight} kg</span><span className="badge-info">{h.quality_grade}</span></div>
                        <p className="text-sm text-gray-500 mt-1">{t('petambak.harvests.size')} {h.shrimp_size} • {t('petambak.harvests.date')} {new Date(h.harvest_date).toLocaleDateString()}</p>
                    </div>
                ))}</div>
            )}
        </div>
    );
}
