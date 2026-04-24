import { useState, useEffect } from 'react';
import { orderApi } from '../../api/orderApi';
import { paymentApi } from '../../api/shipmentApi';
import { reviewApi } from '../../api/traceabilityApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge, Modal } from '../../components/ui';
import type { Order } from '../../types';
import { FiStar } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function KonsumenOrders() {
    const [orders, setOrders] = useState<Order[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [reviewModal, setReviewModal] = useState<{ productId: string; orderId: string } | null>(null);
    const [reviewForm, setReviewForm] = useState({ rating: 5, comment: '' });
    const { t } = useTranslation();
    const fetch = () => { setLoading(true); orderApi.getMyOrders().then(r => setOrders(r.data.data || [])).catch(() => setError(t('konsumen.orders.err_load'))).finally(() => setLoading(false)); };
    useEffect(fetch, [t]);
    const handlePay = async (orderId: string) => {
        try {
            const res = await paymentApi.createPayment(orderId);
            const snapUrl = res.data.data?.snap_url;
            if (snapUrl) window.open(snapUrl, '_blank');
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('konsumen.orders.err_pay'));
        }
    };
    const handleCancel = async (orderId: string) => {
        try {
            await orderApi.cancel(orderId);
            toast.success(t('konsumen.orders.cancel_success', 'Order cancelled'));
            fetch();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('konsumen.orders.err_cancel'));
        }
    };
    const handleReview = async () => {
        if (!reviewModal) return;
        try {
            await reviewApi.create({ product_id: reviewModal.productId, ...reviewForm });
            toast.success(t('konsumen.orders.review_success', 'Review submitted successfully'));
            setReviewModal(null);
            setReviewForm({ rating: 5, comment: '' });
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('konsumen.orders.err_review'));
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} />;
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('konsumen.orders.title')}</h1>
            {!orders.length ? <EmptyState title={t('konsumen.orders.empty_title')} message={t('konsumen.orders.empty_desc')} /> : (
                <div className="space-y-4">{orders.map(o => (
                    <div key={o.id} className="card p-5">
                        <div className="flex items-center justify-between mb-3">
                            <div><p className="font-mono text-sm">{o.id.slice(0, 8)}...</p><p className="text-xs text-gray-500">{new Date(o.created_at).toLocaleDateString()}</p></div>
                            <StatusBadge status={o.status} />
                        </div>
                        <div className="space-y-2 mb-3">{o.order_items?.map(item => (
                            <div key={item.id} className="flex justify-between text-sm">
                                <span>{item.product?.name} × {item.quantity}</span>
                                <span className="font-medium">Rp {item.subtotal?.toLocaleString()}</span>
                            </div>
                        ))}</div>
                        <div className="flex items-center justify-between border-t pt-3">
                            <span className="font-bold">{t('konsumen.orders.total')} Rp {o.total_amount?.toLocaleString()}</span>
                            <div className="flex gap-2">
                                {o.status === 'pending' && <><button onClick={() => handlePay(o.id)} className="btn-primary btn-sm">{t('konsumen.orders.btn_pay')}</button><button onClick={() => handleCancel(o.id)} className="btn-outline btn-sm">{t('konsumen.orders.btn_cancel')}</button></>}
                                {o.status === 'delivered' && o.order_items?.map(item => (
                                    <button key={item.id} onClick={() => setReviewModal({ productId: item.product_id, orderId: o.id })} className="btn-accent btn-sm">{t('konsumen.orders.btn_review')}</button>
                                ))}
                            </div>
                        </div>
                    </div>
                ))}</div>
            )}
            <Modal isOpen={!!reviewModal} onClose={() => setReviewModal(null)} title={t('konsumen.orders.modal_review_title')}>
                <div className="space-y-4">
                    <div><label className="label">{t('konsumen.orders.lbl_rating')}</label><div className="flex gap-1">{[1, 2, 3, 4, 5].map(s => (
                        <button key={s} onClick={() => setReviewForm({ ...reviewForm, rating: s })} className="cursor-pointer">
                            <FiStar className={`w-6 h-6 ${s <= reviewForm.rating ? 'text-yellow-400 fill-current' : 'text-gray-300'}`} />
                        </button>
                    ))}</div></div>
                    <div><label className="label">{t('konsumen.orders.lbl_comment')}</label><textarea value={reviewForm.comment} onChange={e => setReviewForm({ ...reviewForm, comment: e.target.value })} className="input" rows={4} /></div>
                    <button onClick={handleReview} className="btn-primary w-full">{t('konsumen.orders.btn_submit_review')}</button>
                </div>
            </Modal>
        </div>
    );
}
