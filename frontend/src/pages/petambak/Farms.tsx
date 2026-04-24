import { useState, useEffect } from 'react';
import { farmApi } from '../../api/farmApi';
import { LoadingSpinner, EmptyState, ErrorState, Modal } from '../../components/ui';
import { FaWater } from 'react-icons/fa';
import type { Farm } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function PetambakFarms() {
    const [farms, setFarms] = useState<Farm[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [form, setForm] = useState({ name: '', location: '', area: 0, description: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); farmApi.getMyFarms().then(r => setFarms(r.data.data || [])).catch(() => setError(t('petambak.farms.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const handleSubmit = async () => {
        try {
            await farmApi.create(form);
            toast.success(t('petambak.farms.create_success', 'Farm created successfully'));
            setShowModal(false);
            setForm({ name: '', location: '', area: 0, description: '' });
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('petambak.farms.err_create'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} onRetry={fetch} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6"><h1 className="text-2xl font-bold">{t('petambak.farms.title')}</h1><button onClick={() => setShowModal(true)} className="btn-primary">{t('petambak.farms.btn_add')}</button></div>
            {!farms.length ? <EmptyState title={t('petambak.farms.empty_title')} message={t('petambak.farms.empty_desc')} /> : (
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">{farms.map(f => (
                    <div key={f.id} className="card p-6 hover:shadow-md transition-shadow">
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-accent-100 to-ocean-100 flex items-center justify-center mb-4"><FaWater className="w-6 h-6 text-primary-600" /></div>
                        <h3 className="font-semibold text-lg">{f.name}</h3>
                        <p className="text-sm text-gray-500 mt-1">{f.location}</p>
                        <p className="text-sm text-gray-500">{f.area} m²</p>
                        <p className="text-sm text-gray-400 mt-2">{f.ponds?.length || 0} {t('petambak.farms.ponds')}</p>
                    </div>
                ))}</div>
            )}
            <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={t('petambak.farms.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('petambak.farms.lbl_name')}</label><input value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} className="input" required /></div>
                    <div><label className="label">{t('petambak.farms.lbl_location')}</label><input value={form.location} onChange={e => setForm({ ...form, location: e.target.value })} className="input" /></div>
                    <div><label className="label">{t('petambak.farms.lbl_area')}</label><input type="number" value={form.area} onChange={e => setForm({ ...form, area: +e.target.value })} className="input" /></div>
                    <div><label className="label">{t('petambak.farms.lbl_desc')}</label><textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} className="input" rows={3} /></div>
                    <button onClick={handleSubmit} className="btn-primary w-full">{t('petambak.farms.btn_create')}</button>
                </div>
            </Modal>
        </div>
    );
}
