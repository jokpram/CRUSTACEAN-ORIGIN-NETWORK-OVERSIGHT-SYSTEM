import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { productApi } from '../api/productApi';
import { LoadingSpinner, EmptyState, ErrorState } from '../components/ui';
import { FiSearch, FiShoppingCart, FiStar } from 'react-icons/fi';
import { GiShrimp } from 'react-icons/gi';
import type { Product } from '../types';
import { useCartStore } from '../store/cartStore';
import { useAuthStore } from '../store/authStore';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function Marketplace() {
    const [products, setProducts] = useState<Product[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const [search, setSearch] = useState('');
    const [shrimpType, setShrimpType] = useState('');
    const [sortBy, setSortBy] = useState('newest');
    const addItem = useCartStore((s) => s.addItem);
    const user = useAuthStore((s) => s.user);
    const { t } = useTranslation();
    const fetchProducts = async () => {
        setLoading(true);
        setError('');
        try {
            const params: Record<string, string> = { sort: sortBy };
            if (search) params.search = search;
            if (shrimpType) params.shrimp_type = shrimpType;
            const res = await productApi.getMarketplace(params);
            setProducts(res.data.data || []);
        } catch {
            setError(t('market.err_load'));
        } finally {
            setLoading(false);
        }
    };
    useEffect(() => { fetchProducts(); }, [sortBy, shrimpType]);
    const handleSearch = (e: React.FormEvent) => { e.preventDefault(); fetchProducts(); };
    return (
        <div className="min-h-screen bg-gray-50">
            { }
            <nav className="bg-white border-b border-gray-200 sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
                    <Link to="/" className="flex items-center gap-2">
                        <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-ocean-500 to-accent-500 flex items-center justify-center font-bold text-white text-sm">C</div>
                        <span className="font-bold text-lg">CRONOS</span>
                    </Link>
                    <div className="flex items-center gap-4">
                        <Link to="/traceability" className="text-sm text-gray-600 hover:text-primary-600">{t('nav.traceability')}</Link>
                        {user ? (
                            <Link to={`/${user.role === 'admin' ? 'admin' : user.role}`} className="btn-primary btn-sm">{t('nav.dashboard')}</Link>
                        ) : (
                            <Link to="/login" className="btn-primary btn-sm">{t('nav.login')}</Link>
                        )}
                    </div>
                </div>
            </nav>
            <div className="max-w-7xl mx-auto px-6 py-8">
                <h1 className="text-3xl font-bold mb-2">{t('market.title')}</h1>
                <p className="text-gray-500 mb-8">{t('market.subtitle')}</p>
                { }
                <div className="card p-4 mb-8">
                    <div className="flex flex-col md:flex-row gap-4">
                        <form onSubmit={handleSearch} className="flex-1 relative">
                            <FiSearch className="absolute left-3 top-3 text-gray-400" />
                            <input type="text" value={search} onChange={(e) => setSearch(e.target.value)} placeholder={t('market.placeholder_search')} className="input pl-10" />
                        </form>
                        <select value={shrimpType} onChange={(e) => setShrimpType(e.target.value)} className="input w-auto">
                            <option value="">{t('market.filter_all')}</option>
                            <option value="Vannamei">{t('market.filter_vannamei')}</option>
                            <option value="Tiger">{t('market.filter_tiger')}</option>
                            <option value="Galah">{t('market.filter_galah')}</option>
                        </select>
                        <select value={sortBy} onChange={(e) => setSortBy(e.target.value)} className="input w-auto">
                            <option value="newest">{t('market.sort_newest')}</option>
                            <option value="price_asc">{t('market.sort_price_asc')}</option>
                            <option value="price_desc">{t('market.sort_price_desc')}</option>
                            <option value="rating">{t('market.sort_rating')}</option>
                        </select>
                    </div>
                </div>
                { }
                {loading ? <LoadingSpinner message={t('market.loading')} /> :
                    error ? <ErrorState message={error} onRetry={fetchProducts} /> :
                        products.length === 0 ? <EmptyState title={t('market.empty_title')} message={t('market.empty_desc')} /> : (
                            <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
                                {products.map((product) => (
                                    <div key={product.id} className="card group hover:shadow-lg transition-all duration-300">
                                        <div className="h-48 bg-gradient-to-br from-ocean-100 to-accent-100 flex items-center justify-center">
                                            <GiShrimp className="w-16 h-16 text-primary-500/80" />
                                        </div>
                                        <div className="p-5">
                                            <Link to={`/products/${product.id}`} className="font-semibold text-gray-900 hover:text-primary-600 line-clamp-1">{product.name}</Link>
                                            <p className="text-xs text-gray-500 mt-1">{product.shrimp_type} • {product.size}</p>
                                            <div className="flex items-center gap-1 mt-2">
                                                <FiStar className="w-3 h-3 text-yellow-400 fill-current" />
                                                <span className="text-xs text-gray-600">{product.rating_avg?.toFixed(1)} ({product.rating_count})</span>
                                            </div>
                                            <div className="flex items-center justify-between mt-4">
                                                <span className="text-lg font-bold text-primary-600">Rp {product.price?.toLocaleString()}</span>
                                                <span className="text-xs text-gray-400">{product.stock} {product.unit}</span>
                                            </div>
                                            {user?.role === 'konsumen' && (
                                                <button onClick={(e) => { e.preventDefault(); addItem(product); toast.success(t('market.added_to_cart', 'Added to cart')); }} className="btn-accent w-full mt-3 btn-sm">
                                                    <FiShoppingCart className="w-3 h-3" /> {t('market.add_to_cart')}
                                                </button>
                                            )}
                                        </div>
                                    </div>
                                ))}
                            </div>
                        )}
            </div>
        </div>
    );
}
