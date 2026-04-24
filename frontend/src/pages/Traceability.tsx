import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { traceabilityApi } from '../api/traceabilityApi';
import { LoadingSpinner, EmptyState, ErrorState } from '../components/ui';
import { FiSearch, FiArrowLeft, FiCheckCircle, FiClock } from 'react-icons/fi';
import type { TraceabilityLog, Batch } from '../types';
import { useTranslation } from 'react-i18next';
export default function Traceability() {
    const { batchCode: paramCode } = useParams<{ batchCode?: string }>();
    const [batchCode, setBatchCode] = useState(paramCode || '');
    const [logs, setLogs] = useState<TraceabilityLog[]>([]);
    const [batch, setBatch] = useState<Batch | null>(null);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const [searched, setSearched] = useState(!!paramCode);
    const { t } = useTranslation();
    const handleSearch = async (code?: string) => {
        const searchCode = code || batchCode;
        if (!searchCode.trim()) return;
        setLoading(true);
        setError('');
        setSearched(true);
        try {
            const res = await traceabilityApi.getByBatchCode(searchCode);
            setLogs(res.data.data?.logs || []);
            setBatch(res.data.data?.batch || null);
        } catch {
            setError(t('trace.err_not_found'));
            setLogs([]);
            setBatch(null);
        } finally {
            setLoading(false);
        }
    };
    useEffect(() => { if (paramCode) handleSearch(paramCode); }, [paramCode]);
    return (
        <div className="min-h-screen bg-gray-50">
            <div className="max-w-4xl mx-auto px-6 py-12">
                <Link to="/" className="inline-flex items-center gap-2 text-gray-500 hover:text-primary-600 mb-8">
                    <FiArrowLeft /> {t('nav.back_to_home')}
                </Link>
                <div className="text-center mb-10">
                    <h1 className="text-4xl font-bold mb-3">{t('trace.title')}</h1>
                    <p className="text-gray-500">{t('trace.subtitle')}</p>
                </div>
                {}
                <form onSubmit={(e) => { e.preventDefault(); handleSearch(); }} className="card p-6 mb-10">
                    <label className="label">{t('trace.lbl_enter_batch')}</label>
                    <div className="flex gap-3">
                        <div className="relative flex-1">
                            <FiSearch className="absolute left-3 top-3 text-gray-400" />
                            <input value={batchCode} onChange={(e) => setBatchCode(e.target.value)} placeholder={t('trace.placeholder_batch')} className="input pl-10" />
                        </div>
                        <button type="submit" className="btn-primary">{t('trace.btn_trace')}</button>
                    </div>
                </form>
                {loading && <LoadingSpinner message={t('trace.msg_tracing')} />}
                {error && <ErrorState message={error} />}
                {!loading && !error && searched && batch && (
                    <div className="card p-6 mb-8">
                        <h2 className="font-semibold text-lg mb-4">{t('trace.info_title')}</h2>
                        <div className="grid grid-cols-2 gap-4 text-sm">
                            <div><span className="text-gray-500">{t('trace.lbl_batch')}</span> <span className="font-medium">{batch.batch_code}</span></div>
                            <div><span className="text-gray-500">{t('trace.lbl_qty')}</span> <span className="font-medium">{batch.quantity} kg</span></div>
                            {batch.harvest?.cultivation_cycle?.shrimp_type && (
                                <div><span className="text-gray-500">{t('trace.lbl_type')}</span> <span className="font-medium">{batch.harvest.cultivation_cycle.shrimp_type.name}</span></div>
                            )}
                            {batch.harvest?.cultivation_cycle?.pond?.farm && (
                                <div><span className="text-gray-500">{t('trace.lbl_farm')}</span> <span className="font-medium">{batch.harvest.cultivation_cycle.pond.farm.name}</span></div>
                            )}
                        </div>
                    </div>
                )}
                {!loading && !error && searched && logs.length > 0 && (
                    <div>
                        <h2 className="font-semibold text-lg mb-6">{t('trace.timeline_title')}</h2>
                        <div className="relative">
                            <div className="absolute left-5 top-0 bottom-0 w-0.5 bg-gray-200" />
                            <div className="space-y-6">
                                {logs.map((log, i) => {
                                    return (
                                        <div key={log.id || i} className="flex gap-4 relative">
                                            <div className={`w-10 h-10 rounded-full bg-primary-500 flex items-center justify-center text-white z-10 shrink-0`}>
                                                {i === logs.length - 1 ? <FiCheckCircle /> : <FiClock />}
                                            </div>
                                            <div className="card p-4 flex-1">
                                                <div className="flex items-center justify-between mb-1">
                                                    <span className="font-medium text-sm">{t(`trace.events.${log.event_type}`, log.event_type)}</span>
                                                    <span className="text-xs text-gray-400">{new Date(log.timestamp).toLocaleString()}</span>
                                                </div>
                                                <p className="text-xs text-gray-500">{t('trace.lbl_hash')} {log.current_hash?.slice(0, 16)}...</p>
                                                {log.actor && <p className="text-xs text-gray-500 mt-1">{t('trace.lbl_by')} {log.actor.name}</p>}
                                            </div>
                                        </div>
                                    );
                                })}
                            </div>
                        </div>
                    </div>
                )}
                {!loading && !error && searched && logs.length === 0 && !batch && (
                    <EmptyState title={t('trace.empty_title')} message={t('trace.empty_desc')} />
                )}
            </div>
        </div>
    );
}
