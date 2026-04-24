import { useState, useEffect } from 'react';
import { productApi } from '../../api/productApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Product } from '../../types';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function PetambakProducts() {
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [showModal, setShowModal] = useState(false);
    const [form, setForm] = useState({ name: '', description: '', price: 0, stock: 0, shrimp_type: '', size: '', unit: 'kg', is_available: true });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); productApi.getMyProducts().then(r => setProducts(r.data.data || [])).catch(() => setError(t('petambak.products.err_load'))).finally(() => setLoading(false)); };
    useEffect(() => { fetch(); }, [t]);
    const handleSubmit = async () => {
        try {
            await productApi.create(form);
            toast.success(t('petambak.products.create_success', 'Product listed for sale'));
            setShowModal(false);
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('petambak.products.err_create'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6"><h1 className="text-2xl font-bold">{t('petambak.products.title')}</h1><button onClick={() => setShowModal(true)} className="btn-primary">{t('petambak.products.btn_add')}</button></div>
            {!products.length ? <EmptyState title={t('petambak.products.empty_title')} message={t('petambak.products.empty_desc')} /> : (
                <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">{products.map(p => (
                    <div key={p.id} className="card p-5">
                        <h3 className="font-semibold">{p.name}</h3>
                        <p className="text-sm text-gray-500">{p.shrimp_type} • {p.size}</p>
                        <div className="flex items-center justify-between mt-3">
                            <span className="font-bold text-primary-600">Rp {p.price?.toLocaleString()}</span>
                            <span className="text-sm text-gray-400">{p.stock} {p.unit}</span>
                        </div>
                        <div className="mt-2"><StatusBadge status={p.is_available ? 'available' : 'unavailable'} /></div>
                    </div>
                ))}</div>
            )}
            <Modal isOpen={showModal} onClose={() => setShowModal(false)} title={t('petambak.products.modal_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('petambak.products.lbl_name')}</label><input value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} className="input" required /></div>
                    <div><label className="label">{t('petambak.products.lbl_desc')}</label><textarea value={form.description} onChange={e => setForm({ ...form, description: e.target.value })} className="input" rows={3} /></div>
                    <div className="grid grid-cols-2 gap-4">
                        <div><label className="label">{t('petambak.products.lbl_price')}</label><input type="number" value={form.price} onChange={e => setForm({ ...form, price: +e.target.value })} className="input" /></div>
                        <div><label className="label">{t('petambak.products.lbl_stock')}</label><input type="number" value={form.stock} onChange={e => setForm({ ...form, stock: +e.target.value })} className="input" /></div>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                        <div><label className="label">{t('petambak.products.lbl_type')}</label><input value={form.shrimp_type} onChange={e => setForm({ ...form, shrimp_type: e.target.value })} className="input" placeholder="Vannamei" /></div>
                        <div><label className="label">{t('petambak.products.lbl_size')}</label><input value={form.size} onChange={e => setForm({ ...form, size: e.target.value })} className="input" placeholder="30/40" /></div>
                    </div>
                    <button onClick={handleSubmit} className="btn-primary w-full">{t('petambak.products.btn_create')}</button>
                </div>
            </Modal>
        </div>
    );
}
