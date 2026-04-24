import { useState, useEffect } from 'react';
import { shipmentApi } from '../../api/shipmentApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Shipment } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function LogistikShipments() {
    const [items, setItems] = useState<Shipment[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [selected, setSelected] = useState<Shipment | null>(null);
    const [updateForm, setUpdateForm] = useState({ status: '', location: '', notes: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); shipmentApi.getMyShipments().then(r => setItems(r.data.data || [])).catch(() => setError(t('logistik.shipments.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const nextStatus: Record<string, string> = { pending: 'pickup', pickup: 'transit', transit: 'delivered' };
    const handleUpdate = async () => {
        if (!selected) return;
        try {
            await shipmentApi.updateStatus(selected.id, updateForm);
            toast.success(t('logistik.shipments.update_success', 'Shipment status updated'));
            setSelected(null);
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('logistik.shipments.err_update'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('logistik.shipments.title')}</h1>
            {!items.length ? <EmptyState title={t('logistik.shipments.empty_title')} message={t('logistik.shipments.empty_desc')} /> : (
                <div className="space-y-4">{items.map(s => (
                    <div key={s.id} className="card p-5">
                        <div className="flex items-center justify-between mb-3">
                            <div>
                                <p className="font-semibold">{t('logistik.shipments.order')} {s.order_id?.slice(0, 8)}</p>
                                <p className="text-sm text-gray-500">{s.order?.user?.name} • {s.tracking_number}</p>
                            </div>
                            <StatusBadge status={s.status} />
                        </div>
                        {nextStatus[s.status] && (
                            <button onClick={() => { setSelected(s); setUpdateForm({ status: nextStatus[s.status], location: '', notes: '' }); }} className="btn-primary btn-sm">
                                {t('logistik.shipments.btn_update_to')} {nextStatus[s.status]}
                            </button>
                        )}
                    </div>
                ))}</div>
            )}
            <Modal isOpen={!!selected} onClose={() => setSelected(null)} title={t('logistik.shipments.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('logistik.shipments.lbl_new_status')}</label><input value={updateForm.status} className="input" disabled /></div>
                    <div><label className="label">{t('logistik.shipments.lbl_location')}</label><input value={updateForm.location} onChange={e => setUpdateForm({ ...updateForm, location: e.target.value })} className="input" placeholder={t('logistik.shipments.placeholder_location')} /></div>
                    <div><label className="label">{t('logistik.shipments.lbl_notes')}</label><textarea value={updateForm.notes} onChange={e => setUpdateForm({ ...updateForm, notes: e.target.value })} className="input" rows={3} /></div>
                    <button onClick={handleUpdate} className="btn-primary w-full">{t('logistik.shipments.btn_confirm')}</button>
                </div>
            </Modal>
        </div>
    );
}
