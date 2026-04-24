import { useState, useEffect } from 'react';
import { cultivationApi } from '../../api/farmApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge } from '../../components/ui';
import type { CultivationCycle } from '../../types';
import { useTranslation } from 'react-i18next';
export default function PetambakCultivation() {
    const [cycles, setCycles] = useState<CultivationCycle[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => {
        cultivationApi.getMyCycles().then(r => setCycles(r.data.data || [])).catch(() => setError(t('petambak.cultivation.err_load'))).finally(() => setLoading(false));
    }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('petambak.cultivation.title')}</h1>
            {!cycles.length ? <EmptyState title={t('petambak.cultivation.empty_title')} message={t('petambak.cultivation.empty_desc')} /> : (
                <div className="space-y-4">{cycles.map(c => (
                    <div key={c.id} className="card p-5 flex items-center justify-between">
                        <div>
                            <h3 className="font-semibold">{c.pond?.name} - {c.shrimp_type?.name}</h3>
                            <p className="text-sm text-gray-500">{t('petambak.cultivation.density')} {c.density} {t('petambak.cultivation.pct')} • {t('petambak.cultivation.started')} {new Date(c.start_date).toLocaleDateString()}</p>
                        </div>
                        <StatusBadge status={c.status} />
                    </div>
                ))}</div>
            )}
        </div>
    );
}
