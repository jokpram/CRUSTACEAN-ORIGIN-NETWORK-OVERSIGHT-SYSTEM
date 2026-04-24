import { useState, useEffect } from 'react';
import { useParams, Link } from 'react-router-dom';
import { productApi } from '../api/productApi';
import { LoadingSpinner, ErrorState, StatusBadge } from '../components/ui';
import { FiStar, FiShoppingCart, FiArrowLeft, FiUser } from 'react-icons/fi';
import { GiShrimp } from 'react-icons/gi';
import type { Product, Review } from '../types';
import { useCartStore } from '../store/cartStore';
import { useAuthStore } from '../store/authStore';
import { reviewApi } from '../api/traceabilityApi';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function ProductDetail() {
    const { id } = useParams<{ id: string }>();
    const [product, setProduct] = useState<Product | null>(null);
    const [reviews, setReviews] = useState<Review[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [qty, setQty] = useState(1);
    const addItem = useCartStore((s) => s.addItem);
    const user = useAuthStore((s) => s.user);
    const { t } = useTranslation();
    useEffect(() => {
        if (!id) return;
        setLoading(true);
        Promise.all([
            productApi.getProduct(id),
            reviewApi.getByProduct(id),
        ]).then(([pRes, rRes]) => {
            setProduct(pRes.data.data);
            setReviews(rRes.data.data || []);
        }).catch(() => setError(t('product.err_load'))).finally(() => setLoading(false));
    }, [id]);
    if (loading) return <LoadingSpinner />;
    if (error || !product) return <ErrorState message={error || t('product.not_found')} />;
    return (
        <div className="min-h-screen bg-gray-50">
            <div className="max-w-6xl mx-auto px-6 py-8">
                <Link to="/marketplace" className="inline-flex items-center gap-2 text-gray-500 hover:text-primary-600 mb-6">
                    <FiArrowLeft /> {t('product.back_market')}
                </Link>
                <div className="grid md:grid-cols-2 gap-8">
                    <div className="card overflow-hidden">
                        <div className="h-96 bg-gradient-to-br from-ocean-100 to-accent-100 flex items-center justify-center">
                            <GiShrimp className="w-32 h-32 text-primary-500 opacity-80" />
                        </div>
                    </div>
                    <div>
                        <h1 className="text-3xl font-bold text-gray-900">{product.name}</h1>
                        <div className="flex items-center gap-3 mt-3">
                            <div className="flex items-center gap-1">
                                <FiStar className="w-4 h-4 text-yellow-400" />
                                <span className="font-medium">{product.rating_avg?.toFixed(1)}</span>
                                <span className="text-gray-400 text-sm">({product.rating_count} {t('product.reviews').toLowerCase()})</span>
                            </div>
                            <StatusBadge status={product.is_available ? 'available' : 'unavailable'} />
                        </div>
                        <p className="text-3xl font-bold text-primary-600 mt-4">Rp {product.price?.toLocaleString()}</p>
                        <p className="text-sm text-gray-500 mt-1">{t('product.per')} {product.unit}</p>
                        <div className="mt-6 space-y-2 text-sm">
                            <div className="flex justify-between"><span className="text-gray-500">{t('product.type')}</span><span className="font-medium">{product.shrimp_type}</span></div>
                            <div className="flex justify-between"><span className="text-gray-500">{t('product.size')}</span><span className="font-medium">{product.size}</span></div>
                            <div className="flex justify-between"><span className="text-gray-500">{t('product.stock')}</span><span className="font-medium">{product.stock} {product.unit}</span></div>
                            {product.batch && (
                                <div className="flex justify-between"><span className="text-gray-500">{t('product.batch')}</span>
                                    <Link to={`/traceability/${product.batch.batch_code}`} className="text-primary-600 hover:underline font-medium">{product.batch.batch_code}</Link>
                                </div>
                            )}
                            {product.user && <div className="flex justify-between"><span className="text-gray-500">{t('product.farmer')}</span><span className="font-medium">{product.user.name}</span></div>}
                        </div>
                        <p className="text-gray-600 mt-6">{product.description}</p>
                        {user?.role === 'konsumen' && product.is_available && product.stock > 0 && (
                            <div className="mt-8 flex items-center gap-4">
                                <div className="flex items-center border border-gray-300 rounded-xl overflow-hidden">
                                    <button onClick={() => setQty(Math.max(1, qty - 1))} className="px-4 py-2 hover:bg-gray-100 cursor-pointer">-</button>
                                    <span className="px-4 py-2 font-medium">{qty}</span>
                                    <button onClick={() => setQty(Math.min(product.stock, qty + 1))} className="px-4 py-2 hover:bg-gray-100 cursor-pointer">+</button>
                                </div>
                                <button onClick={() => { addItem(product, qty); toast.success(t('market.added_to_cart', 'Added to cart')); }} className="btn-primary flex-1">
                                    <FiShoppingCart /> {t('market.add_to_cart')}
                                </button>
                            </div>
                        )}
                    </div>
                </div>
                { }
                <div className="mt-12">
                    <h2 className="text-2xl font-bold mb-6">{t('product.reviews')} ({reviews.length})</h2>
                    {reviews.length === 0 ? (
                        <div className="card p-8 text-center text-gray-500">{t('product.no_reviews')}</div>
                    ) : (
                        <div className="space-y-4">
                            {reviews.map((r) => (
                                <div key={r.id} className="card p-5">
                                    <div className="flex items-center gap-3 mb-2">
                                        <div className="w-8 h-8 rounded-full bg-primary-100 flex items-center justify-center"><FiUser className="text-primary-600" /></div>
                                        <div>
                                            <p className="font-medium text-sm">{r.user?.name || 'User'}</p>
                                            <div className="flex gap-0.5">{Array.from({ length: 5 }, (_, i) => <FiStar key={i} className={`w-3 h-3 ${i < r.rating ? 'text-yellow-400 fill-current' : 'text-gray-300'}`} />)}</div>
                                        </div>
                                    </div>
                                    <p className="text-gray-600 text-sm">{r.comment}</p>
                                </div>
                            ))}
                        </div>
                    )}
                </div>
            </div>
        </div>
    );
}
