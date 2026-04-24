import { useState, useEffect } from 'react';
import { batchApi } from '../../api/farmApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge } from '../../components/ui';
import { Link } from 'react-router-dom';
import type { Batch } from '../../types';
import { useTranslation } from 'react-i18next';
export default function PetambakBatches() {
    const [batches, setBatches] = useState<Batch[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    useEffect(() => { batchApi.getMyBatches().then(r => setBatches(r.data.data || [])).catch(() => setError(t('petambak.batches.err_load'))).finally(() => setLoading(false)); }, [t]);
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('petambak.batches.title')}</h1>
            {!batches.length ? <EmptyState title={t('petambak.batches.empty_title')} /> : (
                <div className="space-y-4">{batches.map(b => (
                    <div key={b.id} className="card p-5 flex items-center justify-between">
                        <div>
                            <Link to={`/traceability/${b.batch_code}`} className="font-semibold text-primary-600 hover:underline font-mono">{b.batch_code}</Link>
                            <p className="text-sm text-gray-500 mt-1">{b.quantity} kg</p>
                        </div>
                        <StatusBadge status={b.status} />
                    </div>
                ))}</div>
            )}
        </div>
    );
}
