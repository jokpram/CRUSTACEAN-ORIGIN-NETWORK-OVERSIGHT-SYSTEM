import { Link, useNavigate } from 'react-router-dom';
import { useCartStore } from '../../store/cartStore';
import { EmptyState } from '../../components/ui';
import { FiTrash2, FiMinus, FiPlus, FiShoppingBag } from 'react-icons/fi';
import { GiShrimp } from 'react-icons/gi';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function KonsumenCart() {
    const { items, removeItem, updateQuantity, getTotalAmount } = useCartStore();
    const navigate = useNavigate();
    const { t } = useTranslation();
    if (!items.length) return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('konsumen.cart.title')}</h1>
            <EmptyState title={t('konsumen.cart.empty_title')} message={t('konsumen.cart.empty_desc')} />
            <div className="text-center mt-4"><Link to="/marketplace" className="btn-primary">{t('konsumen.cart.btn_go_market')}</Link></div>
        </div>
    );
    return (
        <div>
            <h1 className="text-2xl font-bold mb-6">{t('konsumen.cart.title')} ({items.length} {t('konsumen.cart.items')})</h1>
            <div className="grid lg:grid-cols-3 gap-6">
                <div className="lg:col-span-2 space-y-4">
                    {items.map(item => (
                        <div key={item.product.id} className="card p-5 flex items-center gap-4">
                            <div className="w-16 h-16 rounded-xl bg-gradient-to-br from-ocean-100 to-accent-100 flex items-center justify-center shrink-0"><GiShrimp className="w-8 h-8 text-primary-600" /></div>
                            <div className="flex-1">
                                <h3 className="font-semibold">{item.product.name}</h3>
                                <p className="text-sm text-gray-500">{item.product.shrimp_type} • {item.product.size}</p>
                                <p className="text-primary-600 font-medium mt-1">Rp {item.product.price?.toLocaleString()}</p>
                            </div>
                            <div className="flex items-center gap-2">
                                <button onClick={() => { updateQuantity(item.product.id, item.quantity - 1); toast.success(t('konsumen.cart.updated', 'Cart updated')); }} className="w-8 h-8 rounded-lg border flex items-center justify-center hover:bg-gray-100 cursor-pointer"><FiMinus className="w-3 h-3" /></button>
                                <span className="w-8 text-center font-medium">{item.quantity}</span>
                                <button onClick={() => { updateQuantity(item.product.id, item.quantity + 1); toast.success(t('konsumen.cart.updated', 'Cart updated')); }} className="w-8 h-8 rounded-lg border flex items-center justify-center hover:bg-gray-100 cursor-pointer"><FiPlus className="w-3 h-3" /></button>
                            </div>
                            <span className="font-bold min-w-[100px] text-right">Rp {(item.product.price * item.quantity).toLocaleString()}</span>
                            <button onClick={() => { removeItem(item.product.id); toast.success(t('konsumen.cart.removed', 'Item removed from cart')); }} className="text-red-400 hover:text-red-600 cursor-pointer"><FiTrash2 /></button>
                        </div>
                    ))}
                </div>
                <div className="card p-6 h-fit sticky top-6">
                    <h3 className="font-semibold text-lg mb-4">{t('konsumen.cart.summary_title')}</h3>
                    <div className="space-y-3 text-sm border-b pb-4 mb-4">
                        <div className="flex justify-between"><span>{t('konsumen.cart.subtotal')}</span><span>Rp {getTotalAmount().toLocaleString()}</span></div>
                        <div className="flex justify-between"><span>{t('konsumen.cart.shipping')}</span><span className="text-gray-400">{t('konsumen.cart.calculated')}</span></div>
                    </div>
                    <div className="flex justify-between font-bold text-lg mb-6"><span>{t('konsumen.cart.total')}</span><span className="text-primary-600">Rp {getTotalAmount().toLocaleString()}</span></div>
                    <button onClick={() => navigate('/konsumen/checkout')} className="btn-primary w-full btn-lg"><FiShoppingBag /> {t('konsumen.cart.btn_checkout')}</button>
                </div>
            </div>
        </div>
    );
}
