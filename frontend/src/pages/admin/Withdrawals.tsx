import { useState, useEffect } from 'react';
import { withdrawalApi } from '../../api/shipmentApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Withdrawal } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function AdminWithdrawals() {
    const [items, setItems] = useState<Withdrawal[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [selected, setSelected] = useState<Withdrawal | null>(null);
    const [notes, setNotes] = useState('');
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); withdrawalApi.getAllWithdrawals().then(r => setItems(r.data.data || [])).catch(() => setError(t('admin.withdrawals.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const handleAction = async (status: string) => {
        if (!selected) return;
        try {
            await withdrawalApi.update(selected.id, { status, notes });
            toast.success(t('admin.withdrawals.update_success', 'Withdrawal status updated'));
            setSelected(null);
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('admin.withdrawals.err_update'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('admin.withdrawals.title')}</h1>
            {!items.length ? <EmptyState title={t('admin.withdrawals.empty_title')} /> : (
                <div className="card overflow-x-auto">
                    <table className="w-full text-sm"><thead className="bg-gray-50 border-b"><tr>
                        <th className="text-left p-4 font-semibold">{t('admin.withdrawals.col_user')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.withdrawals.col_amount')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.withdrawals.col_bank')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.withdrawals.col_status')}</th>
                        <th className="text-left p-4 font-semibold">{t('admin.withdrawals.col_actions')}</th>
                    </tr></thead>
                        <tbody className="divide-y">{items.map(w => (
                            <tr key={w.id} className="hover:bg-gray-50">
                                <td className="p-4">{w.user?.name || '-'}</td>
                                <td className="p-4 font-medium">Rp {w.amount?.toLocaleString()}</td>
                                <td className="p-4 text-sm">{w.bank_name} - {w.account_number}</td>
                                <td className="p-4"><StatusBadge status={w.status} /></td>
                                <td className="p-4">{w.status === 'pending' && <button onClick={() => setSelected(w)} className="btn-primary btn-sm">{t('admin.withdrawals.btn_review')}</button>}</td>
                            </tr>
                        ))}</tbody></table>
                </div>
            )}
            <Modal isOpen={!!selected} onClose={() => setSelected(null)} title={t('admin.withdrawals.modal_title')}>
                {selected && (<div className="space-y-4">
                    <p className="text-sm"><strong>{t('admin.withdrawals.lbl_user')}</strong> {selected.user?.name}</p>
                    <p className="text-sm"><strong>{t('admin.withdrawals.lbl_amount')}</strong> Rp {selected.amount?.toLocaleString()}</p>
                    <p className="text-sm"><strong>{t('admin.withdrawals.lbl_bank')}</strong> {selected.bank_name} - {selected.account_number} ({selected.account_name})</p>
                    <div><label className="label">{t('admin.withdrawals.lbl_notes')}</label><textarea value={notes} onChange={e => setNotes(e.target.value)} className="input" rows={3} /></div>
                    <div className="flex gap-3 justify-end">
                        <button onClick={() => handleAction('rejected')} className="btn-danger btn-sm">{t('admin.withdrawals.btn_reject')}</button>
                        <button onClick={() => handleAction('approved')} className="btn-accent btn-sm">{t('admin.withdrawals.btn_approve')}</button>
                    </div>
                </div>)}
            </Modal>
        </div>
    );
}
