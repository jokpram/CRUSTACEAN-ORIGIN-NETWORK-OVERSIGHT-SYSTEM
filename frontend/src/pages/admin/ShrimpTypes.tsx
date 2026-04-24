import { useState, useEffect } from 'react';
import { shrimpTypeApi } from '../../api/traceabilityApi';
import { LoadingSpinner, EmptyState, ErrorState, Modal } from '../../components/ui';
import type { ShrimpType } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function AdminShrimpTypes() {
    const [items, setItems] = useState<ShrimpType[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [form, setForm] = useState({ name: '', description: '', image: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); shrimpTypeApi.getAll().then(r => setItems(r.data.data || [])).catch(() => setError(t('admin.shrimp_types.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const handleSubmit = async () => {
        try {
            await shrimpTypeApi.create(form);
            toast.success(t('admin.shrimp_types.create_success', 'Shrimp type added'));
            setShowModal(false);
            setForm({ name: '', description: '', image: '' });
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('admin.shrimp_types.err_create'));
        }
    };
    const handleDelete = async (id: string) => {
        try {
            await shrimpTypeApi.delete(id);
            toast.success(t('admin.shrimp_types.delete_success', 'Shrimp type deleted'));
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('admin.shrimp_types.err_delete'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">{t('admin.shrimp_types.title')}</h1>
                <button onClick={() => setShowModal(true)} className="btn-primary">{t('admin.shrimp_types.btn_add')}</button>
            </div>
            {!items.length ? <EmptyState title={t('admin.shrimp_types.empty_title')} message={t('admin.shrimp_types.empty_desc')} /> : (
                <div className="grid md:grid-cols-3 gap-6">{items.map(s => (
                    <div key={s.id} className="card p-5">
                        <h3 className="font-semibold text-lg">{s.name}</h3>
                        <p className="text-sm text-gray-500 mt-1">{s.description}</p>
                        <button onClick={() => handleDelete(s.id)} className="btn-danger btn-sm mt-4">{t('admin.shrimp_types.btn_delete')}</button>
                    </div>
                ))}</div>
            )}
            <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={t('admin.shrimp_types.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('admin.shrimp_types.lbl_name')}</label><input value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} className="input" placeholder="Vannamei" /></div>
                    <div><label className="label">{t('admin.shrimp_types.lbl_desc')}</label><textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} className="input" rows={3} /></div>
                    <button onClick={handleSubmit} className="btn-primary w-full">{t('admin.shrimp_types.btn_create')}</button>
                </div>
            </Modal>
        </div>
    );
}
