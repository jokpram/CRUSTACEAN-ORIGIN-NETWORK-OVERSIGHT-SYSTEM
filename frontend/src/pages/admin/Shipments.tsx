import { useState, useEffect } from 'react';
import { shipmentApi } from '../../api/shipmentApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Shipment } from '../../types';
import { userApi } from '../../api/traceabilityApi';
import { orderApi } from '../../api/orderApi';
import type { User, Order } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function AdminShipments() {
    const [items, setItems] = useState<Shipment[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [couriers, setCouriers] = useState<User[]>([]);
    const [orders, setOrders] = useState<Order[]>([]);
    const [form, setForm] = useState({ order_id: '', courier_id: '', tracking_number: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); shipmentApi.getAllShipments().then(r => setItems(r.data.data || [])).catch(() => setError(t('admin.shipments.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const openCreate = () => {
        userApi.getAll({ role: 'logistik' }).then(r => setCouriers(r.data.data?.filter((u: User) => u.role === 'logistik') || []));
        orderApi.getAllOrders({ status: 'paid' }).then(r => setOrders(r.data.data || []));
        setShowModal(true);
    };
    const handleCreate = async () => {
        try {
            await shipmentApi.create(form);
            toast.success(t('admin.shipments.create_success', 'Shipment created'));
            setShowModal(false);
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('admin.shipments.err_create'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">{t('admin.shipments.title')}</h1>
                <button onClick={openCreate} className="btn-primary">{t('admin.shipments.btn_create')}</button>
            </div>
            {!items.length ? <EmptyState title={t('admin.shipments.empty_title')} /> : (
                <div className="card overflow-x-auto"><table className="w-full text-sm"><thead className="bg-gray-50 border-b"><tr>
                    <th className="text-left p-4 font-semibold">{t('admin.shipments.col_order')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.shipments.col_courier')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.shipments.col_tracking')}</th>
                    <th className="text-left p-4 font-semibold">{t('admin.shipments.col_status')}</th>
                </tr></thead>
                    <tbody className="divide-y">{items.map(s => (
                        <tr key={s.id} className="hover:bg-gray-50">
                            <td className="p-4 font-mono text-xs">{s.order_id?.slice(0, 8)}...</td>
                            <td className="p-4">{s.courier?.name || '-'}</td>
                            <td className="p-4">{s.tracking_number || '-'}</td>
                            <td className="p-4"><StatusBadge status={s.status} /></td>
                        </tr>
                    ))}</tbody></table></div>
            )}
            <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={t('admin.shipments.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('admin.shipments.lbl_order')}</label>
                        <select value={form.order_id} onChange={e => setForm({ ...form, order_id: e.target.value })} className="input">
                            <option value="">{t('admin.shipments.opt_select_order')}</option>
                            {orders.map(o => <option key={o.id} value={o.id}>{o.id.slice(0, 8)} - Rp {o.total_amount?.toLocaleString()}</option>)}
                        </select>
                    </div>
                    <div><label className="label">{t('admin.shipments.lbl_courier')}</label>
                        <select value={form.courier_id} onChange={e => setForm({ ...form, courier_id: e.target.value })} className="input">
                            <option value="">{t('admin.shipments.opt_select_courier')}</option>
                            {couriers.map(c => <option key={c.id} value={c.id}>{c.name}</option>)}
                        </select>
                    </div>
                    <div><label className="label">{t('admin.shipments.lbl_tracking')}</label><input value={form.tracking_number} onChange={e => setForm({ ...form, tracking_number: e.target.value })} className="input" /></div>
                    <button onClick={handleCreate} className="btn-primary w-full">{t('admin.shrimp_types.btn_create')}</button>
                </div>
            </Modal>
        </div>
    );
}
