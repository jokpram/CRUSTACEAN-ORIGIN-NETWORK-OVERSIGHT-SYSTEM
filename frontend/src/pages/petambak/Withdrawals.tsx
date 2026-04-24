import { useState, useEffect } from 'react';
import { withdrawalApi } from '../../api/shipmentApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Withdrawal } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function PetambakWithdrawals() {
    const [items, setItems] = useState<Withdrawal[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [form, setForm] = useState({ amount: 0, bank_name: '', account_number: '', account_name: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); withdrawalApi.getMyWithdrawals().then(r => setItems(r.data.data || [])).catch(() => setError(t('petambak.withdrawals.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const handleSubmit = async () => {
        try {
            await withdrawalApi.create(form);
            toast.success(t('petambak.withdrawals.create_success', 'Withdrawal request submitted'));
            setShowModal(false);
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('petambak.withdrawals.err_create'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6"><h1 className="text-2xl font-bold">{t('petambak.withdrawals.title')}</h1><button onClick={() => setShowModal(true)} className="btn-primary">{t('petambak.withdrawals.btn_request')}</button></div>
            {!items.length ? <EmptyState title={t('petambak.withdrawals.empty_title')} /> : (
                <div className="space-y-4">{items.map(w => (
                    <div key={w.id} className="card p-5 flex items-center justify-between">
                        <div><span className="font-semibold">Rp {w.amount?.toLocaleString()}</span><p className="text-sm text-gray-500">{w.bank_name} - {w.account_number}</p></div>
                        <StatusBadge status={w.status} />
                    </div>
                ))}</div>
            )}
            <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={t('petambak.withdrawals.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('petambak.withdrawals.lbl_amount')}</label><input type="number" value={form.amount} onChange={e => setForm({ ...form, amount: +e.target.value })} className="input" required /></div>
                    <div><label className="label">{t('petambak.withdrawals.lbl_bank')}</label><input value={form.bank_name} onChange={e => setForm({ ...form, bank_name: e.target.value })} className="input" required /></div>
                    <div><label className="label">{t('petambak.withdrawals.lbl_acct_num')}</label><input value={form.account_number} onChange={e => setForm({ ...form, account_number: e.target.value })} className="input" required /></div>
                    <div><label className="label">{t('petambak.withdrawals.lbl_acct_name')}</label><input value={form.account_name} onChange={e => setForm({ ...form, account_name: e.target.value })} className="input" required /></div>
                    <button onClick={handleSubmit} className="btn-primary w-full">{t('petambak.withdrawals.btn_submit')}</button>
                </div>
            </Modal>
        </div>
    );
}
