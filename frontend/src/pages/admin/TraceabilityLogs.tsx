import { useState, useEffect } from 'react';
import { traceabilityApi } from '../../api/traceabilityApi';
import { LoadingSpinner, EmptyState, ErrorState } from '../../components/ui';
import type { TraceabilityLog } from '../../types';
import { FiCheckCircle, FiXCircle } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
export default function AdminTraceabilityLogs() {
    const [logs, setLogs] = useState<TraceabilityLog[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [chainValid, setChainValid] = useState<boolean | null>(null);
    const { t } = useTranslation();
    useEffect(() => {
        traceabilityApi.getAllLogs().then(r => setLogs(r.data.data || [])).catch(() => setError(t('admin.trace_logs.err_load'))).finally(() => setLoading(false));
    }, [t]);
    const verifyChain = () => {
        traceabilityApi.verifyChain().then(r => setChainValid(r.data.data?.valid)).catch(() => setChainValid(false));
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">{t('admin.trace_logs.title')}</h1>
                <button onClick={verifyChain} className="btn-ocean">{t('admin.trace_logs.btn_verify')}</button>
            </div>
            {chainValid !== null && (
                <div className={`card p-4 mb-6 ${chainValid ? 'bg-green-50 border-green-200' : 'bg-red-50 border-red-200'}`}>
                    <p className={`font-medium flex items-center gap-2 ${chainValid ? 'text-green-700' : 'text-red-700'}`}>
                        {chainValid ? <><FiCheckCircle /> {t('admin.trace_logs.msg_valid')}</> : <><FiXCircle /> {t('admin.trace_logs.msg_invalid')}</>}
                    </p>
                </div>
            )}
            {!logs.length ? <EmptyState title={t('admin.trace_logs.empty_title')} /> : (
                <div className="card overflow-x-auto"><table className="w-full text-sm"><thead className="bg-gray-50 border-b"><tr>
                    <th className="text-left p-4 font-semibold">{t('admin.trace_logs.col_event')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.trace_logs.col_actor')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.trace_logs.col_entity')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.trace_logs.col_hash')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.trace_logs.col_time')}</th>
                </tr></thead>
                    <tbody className="divide-y">{logs.map(l => (
                        <tr key={l.id} className="hover:bg-gray-50">
                            <td className="p-4"><span className="badge-info">{t(`trace.events.${l.event_type}`, l.event_type)}</span></td>
                            <td className="p-4">{l.actor?.name || l.actor_id?.slice(0, 8)}</td>
                            <td className="p-4 text-xs">{l.entity_type}/{l.entity_id?.slice(0, 8)}</td>
                            <td className="p-4 font-mono text-xs text-gray-400">{l.current_hash?.slice(0, 12)}...</td>
                            <td className="p-4 text-gray-500 text-xs">{new Date(l.timestamp).toLocaleString()}</td>
                        </tr>
                    ))}</tbody></table></div>
            )}
        </div>
    );
}
