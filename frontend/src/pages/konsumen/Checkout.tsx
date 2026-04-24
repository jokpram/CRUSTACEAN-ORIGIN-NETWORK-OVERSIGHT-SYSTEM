import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { useCartStore } from '../../store/cartStore';
import { orderApi } from '../../api/orderApi';
import { paymentApi } from '../../api/shipmentApi';
import { EmptyState } from '../../components/ui';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function KonsumenCheckout() {
    const { items, getTotalAmount, clearCart } = useCartStore();
    const [address, setAddress] = useState('');
    const [notes, setNotes] = useState('');
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();
    const { t } = useTranslation();
    if (!items.length) return <EmptyState title={t('konsumen.checkout.empty_title')} message={t('konsumen.checkout.empty_desc')} />;
    const handleCheckout = async () => {
        if (!address.trim()) { setError(t('konsumen.checkout.err_address')); return; }
        setLoading(true);
        setError('');
        try {
            const orderRes = await orderApi.create({
                shipping_address: address,
                notes,
                items: items.map(i => ({ product_id: i.product.id, quantity: i.quantity })),
            });
            const orderId = orderRes.data.data?.id;
            const paymentRes = await paymentApi.createPayment(orderId);
            const snapUrl = paymentRes.data.data?.snap_url;
            clearCart();
            toast.success(t('konsumen.checkout.success', 'Order placed successfully!'));
            if (snapUrl) {
                window.open(snapUrl, '_blank');
            }
            navigate('/konsumen/orders');
        } catch (err: unknown) {
            const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || t('konsumen.checkout.err_failed');
            setError(msg);
            toast.error(msg);
        } finally {
            setLoading(false);
        }
    };
    return (
        <div className="max-w-2xl mx-auto">
            <h1 className="text-2xl font-bold mb-6">{t('konsumen.checkout.title')}</h1>
            <div className="card p-6 mb-6">
                <h2 className="font-semibold mb-4">{t('konsumen.checkout.order_items')}</h2>
                <div className="space-y-3 border-b pb-4 mb-4">{items.map(item => (
                    <div key={item.product.id} className="flex justify-between text-sm">
                        <span>{item.product.name} × {item.quantity}</span>
                        <span className="font-medium">Rp {(item.product.price * item.quantity).toLocaleString()}</span>
                    </div>
                ))}</div>
                <div className="flex justify-between font-bold text-lg"><span>{t('konsumen.checkout.total')}</span><span className="text-primary-600">Rp {getTotalAmount().toLocaleString()}</span></div>
            </div>
            <div className="card p-6 mb-6">
                <h2 className="font-semibold mb-4">{t('konsumen.checkout.shipping_info')}</h2>
                {error && <div className="bg-red-50 text-red-600 text-sm p-3 rounded-xl mb-4">{error}</div>}
                <div className="space-y-4">
                    <div><label className="label">{t('konsumen.checkout.lbl_address')}</label><textarea value={address} onChange={e => setAddress(e.target.value)} className="input" rows={3} placeholder={t('konsumen.checkout.placeholder_address')} required /></div>
                    <div><label className="label">{t('konsumen.checkout.lbl_notes')}</label><textarea value={notes} onChange={e => setNotes(e.target.value)} className="input" rows={2} placeholder={t('konsumen.checkout.placeholder_notes')} /></div>
                </div>
            </div>
            <button onClick={handleCheckout} disabled={loading} className="btn-primary w-full btn-lg">
                {loading ? t('konsumen.checkout.btn_processing') : `${t('konsumen.checkout.btn_place_order')}${getTotalAmount().toLocaleString()}`}
            </button>
        </div>
    );
}
