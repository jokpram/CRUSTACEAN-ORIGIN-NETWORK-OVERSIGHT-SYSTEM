import { useState } from 'react';
import { Link, Outlet, useNavigate, useLocation } from 'react-router-dom';
import { useAuthStore } from '../store/authStore';
import { useCartStore } from '../store/cartStore';
import {
    FiHome, FiUsers, FiPackage, FiDollarSign, FiTruck,
    FiMap, FiDroplet, FiScissors, FiLayers, FiShoppingBag, FiLogOut,
    FiMenu, FiX, FiShoppingCart, FiClipboard, FiFileText, FiSettings, FiGlobe, FiMessageSquare
} from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import { ConfirmDialog } from '../components/ui';
import WaterSurface from '../components/WaterSurface';
const sidebarConfig: Record<string, { labelKey: string; icon: React.ReactNode; path: string }[]> = {
    admin: [
        { labelKey: 'dashboard', icon: <FiHome />, path: '/admin' },
        { labelKey: 'users', icon: <FiUsers />, path: '/admin/users' },
        { labelKey: 'chat', icon: <FiMessageSquare />, path: '/chat' },
        { labelKey: 'orders', icon: <FiShoppingBag />, path: '/admin/orders' },
        { labelKey: 'withdrawals', icon: <FiDollarSign />, path: '/admin/withdrawals' },
        { labelKey: 'shrimp_types', icon: <FiDroplet />, path: '/admin/shrimp-types' },
        { labelKey: 'shipments', icon: <FiTruck />, path: '/admin/shipments' },
        { labelKey: 'traceability', icon: <FiClipboard />, path: '/admin/traceability' },
    ],
    petambak: [
        { labelKey: 'dashboard', icon: <FiHome />, path: '/petambak' },
        { labelKey: 'chat', icon: <FiMessageSquare />, path: '/chat' },
        { labelKey: 'farms', icon: <FiMap />, path: '/petambak/farms' },
        { labelKey: 'cultivation', icon: <FiDroplet />, path: '/petambak/cultivation' },
        { labelKey: 'harvests', icon: <FiScissors />, path: '/petambak/harvests' },
        { labelKey: 'batches', icon: <FiLayers />, path: '/petambak/batches' },
        { labelKey: 'products', icon: <FiPackage />, path: '/petambak/products' },
        { labelKey: 'sales', icon: <FiShoppingBag />, path: '/petambak/sales' },
        { labelKey: 'withdrawals', icon: <FiDollarSign />, path: '/petambak/withdrawals' },
    ],
    logistik: [
        { labelKey: 'dashboard', icon: <FiHome />, path: '/logistik' },
        { labelKey: 'chat', icon: <FiMessageSquare />, path: '/chat' },
        { labelKey: 'shipments', icon: <FiTruck />, path: '/logistik/shipments' },
    ],
    konsumen: [
        { labelKey: 'dashboard', icon: <FiHome />, path: '/konsumen' },
        { labelKey: 'chat', icon: <FiMessageSquare />, path: '/chat' },
        { labelKey: 'marketplace', icon: <FiShoppingBag />, path: '/marketplace' },
        { labelKey: 'my_orders', icon: <FiFileText />, path: '/konsumen/orders' },
        { labelKey: 'cart', icon: <FiShoppingCart />, path: '/konsumen/cart' },
    ],
};
export default function AppLayout() {
    const { user, logout } = useAuthStore();
    const { t, i18n } = useTranslation();
    const totalItems = useCartStore((s) => s.getTotalItems());
    const navigate = useNavigate();
    const location = useLocation();
    const [sidebarOpen, setSidebarOpen] = useState(false);
    const [langOpen, setLangOpen] = useState(false);
    const [settingsOpen, setSettingsOpen] = useState(false);
    const [showLogoutModal, setShowLogoutModal] = useState(false);
    const role = user?.role || 'konsumen';
    const menuItems = sidebarConfig[role] || [];
    const handleLogout = () => {
        setShowLogoutModal(true);
    };
    const confirmLogout = () => {
        logout();
        navigate('/login');
    };
    return (
        <div className="flex h-screen bg-gray-50">
            { }
            <aside className={`fixed inset-y-0 left-0 z-40 w-64 bg-gray-900 text-white transform transition-transform duration-300 lg:translate-x-0 lg:static ${sidebarOpen ? 'translate-x-0' : '-translate-x-full'}`}>
                <div className="flex items-center gap-3 p-6 border-b border-gray-800">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-ocean-500 to-accent-500 flex items-center justify-center font-bold text-lg">C</div>
                    <div>
                        <h1 className="font-bold text-lg">CRONOS</h1>
                        <p className="text-xs text-gray-400 capitalize">{role} Panel</p>
                    </div>
                </div>
                <nav className="p-4 space-y-1 flex-1">
                    {menuItems.map((item) => {
                        const isActive = location.pathname === item.path || (item.path !== '/' && location.pathname.startsWith(item.path + '/'));
                        return (
                            <Link
                                key={item.path}
                                to={item.path}
                                onClick={() => setSidebarOpen(false)}
                                className={`flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm font-medium transition-all ${isActive
                                    ? 'bg-primary-600 text-white shadow-lg shadow-primary-600/30'
                                    : 'text-gray-300 hover:bg-gray-800 hover:text-white'
                                    }`}
                            >
                                {item.icon}
                                {t(`nav.${item.labelKey}`)}
                            </Link>
                        );
                    })}
                </nav>
                <div className="p-4 border-t border-gray-800">
                    <div className="flex items-center gap-3 p-3 rounded-xl bg-gray-800 mb-3">
                        <div className="w-8 h-8 rounded-full bg-gradient-to-br from-primary-500 to-accent-500 flex items-center justify-center text-xs font-bold">
                            {user?.name?.charAt(0)?.toUpperCase()}
                        </div>
                        <div className="flex-1 min-w-0">
                            <p className="text-sm font-medium truncate">{user?.name}</p>
                            <p className="text-xs text-gray-400 truncate">{user?.email}</p>
                        </div>
                    </div>
                    <button onClick={handleLogout} className="w-full flex items-center gap-3 px-4 py-2.5 rounded-xl text-sm text-gray-300 hover:bg-red-600/20 hover:text-red-400 transition-colors cursor-pointer">
                        <FiLogOut /> {t('nav.logout')}
                    </button>
                </div>
            </aside>
            { }
            {sidebarOpen && <div className="fixed inset-0 z-30 bg-black/50 lg:hidden" onClick={() => setSidebarOpen(false)} />}
            { }
            <div className="flex-1 flex flex-col overflow-hidden">
                { }
                <header className="bg-white border-b border-gray-200 px-6 py-4 flex items-center justify-between">
                    <button onClick={() => setSidebarOpen(!sidebarOpen)} className="lg:hidden text-gray-600 cursor-pointer">
                        {sidebarOpen ? <FiX size={24} /> : <FiMenu size={24} />}
                    </button>
                    <div className="flex items-center gap-4 ml-auto">
                        <Link to="/" className="text-gray-600 hover:text-primary-600 flex items-center gap-2 text-sm font-medium pr-4 border-r border-gray-100" title={t('nav.back_to_home')}>
                            <FiHome size={20} />
                            <span className="hidden sm:inline">{t('nav.back_to_home')}</span>
                        </Link>

                        {/* Language Selection */}
                        <div className="relative">
                            <button
                                onClick={() => { setLangOpen(!langOpen); setSettingsOpen(false); }}
                                className={`p-2 rounded-xl transition-all flex items-center justify-center cursor-pointer ${langOpen ? 'bg-primary-50 text-primary-600' : 'text-gray-600 hover:bg-gray-50'}`}
                                title="Change Language"
                            >
                                <FiGlobe size={20} />
                            </button>
                            {langOpen && (
                                <div className="absolute top-full right-0 mt-2 w-48 bg-white p-2 rounded-2xl shadow-2xl border border-gray-100 flex flex-col gap-1 z-[60] animate-in fade-in slide-in-from-top-2">
                                    <div className="px-3 py-2 mb-1 border-b border-gray-50 flex items-center justify-between">
                                        <span className="text-[10px] font-bold text-gray-400 uppercase tracking-widest">Language</span>
                                        <button onClick={() => setLangOpen(false)} className="text-gray-400 hover:text-red-500"><FiX size={14} /></button>
                                    </div>
                                    {['id', 'en', 'nl'].map((l) => (
                                        <button
                                            key={l}
                                            onClick={() => { i18n.changeLanguage(l); setLangOpen(false); }}
                                            className={`px-3 py-2 text-sm rounded-xl hover:bg-gray-50 transition-colors text-left font-medium cursor-pointer ${i18n.language.startsWith(l) ? 'text-primary-600 bg-primary-50' : 'text-gray-600'}`}
                                        >
                                            {l === 'id' ? 'ID (Indonesia)' : l === 'en' ? 'EN (English)' : 'NL (Nederlands)'}
                                        </button>
                                    ))}
                                </div>
                            )}
                        </div>

                        {role === 'konsumen' && (
                            <Link to="/konsumen/cart" className="relative text-gray-600 hover:bg-gray-50 p-2 rounded-xl">
                                <FiShoppingCart size={20} />
                                {totalItems > 0 && (
                                    <span className="absolute -top-1 -right-1 w-5 h-5 bg-red-500 rounded-full text-white text-[10px] flex items-center justify-center border-2 border-white">
                                        {totalItems}
                                    </span>
                                )}
                            </Link>
                        )}

                        {/* Settings Dropdown */}
                        <div className="relative">
                            <button
                                onClick={() => { setSettingsOpen(!settingsOpen); setLangOpen(false); }}
                                className={`p-2 rounded-xl transition-all flex items-center justify-center cursor-pointer ${settingsOpen ? 'bg-primary-50 text-primary-600' : 'text-gray-600 hover:bg-gray-50'}`}
                                title="Account Settings"
                            >
                                <FiSettings size={20} />
                            </button>
                            {settingsOpen && (
                                <div className="absolute top-full right-0 mt-2 w-56 bg-white p-2 rounded-2xl shadow-2xl border border-gray-100 flex flex-col gap-1 z-[60] animate-in fade-in slide-in-from-top-2">
                                    <div className="px-3 py-3 border-b border-gray-50 mb-1">
                                        <p className="text-xs font-bold text-gray-900 truncate">{user?.name}</p>
                                        <p className="text-[10px] text-gray-500 truncate">{user?.email}</p>
                                    </div>
                                    <button
                                        onClick={() => { navigate(`/${role === 'admin' ? 'admin' : role}`); setSettingsOpen(false); }}
                                        className="flex items-center gap-2 px-3 py-2.5 text-sm text-gray-600 rounded-xl hover:bg-gray-50 cursor-pointer"
                                    >
                                        <FiHome size={16} /> {t('nav.dashboard')}
                                    </button>
                                    <button
                                        onClick={handleLogout}
                                        className="flex items-center gap-2 px-3 py-2.5 text-sm text-red-600 rounded-xl hover:bg-red-50 cursor-pointer mt-1"
                                    >
                                        <FiLogOut size={16} /> {t('nav.logout')}
                                    </button>
                                </div>
                            )}
                        </div>
                    </div>
                </header>
                { }
                <main className="flex-1 overflow-y-auto p-6 relative">
                    <div className="absolute inset-0 z-0 opacity-20 pointer-events-none">
                        <WaterSurface />
                    </div>
                    <div className="relative z-10">
                        <Outlet />
                    </div>
                </main>
            </div>
            <ConfirmDialog
                isOpen={showLogoutModal}
                onClose={() => setShowLogoutModal(false)}
                onConfirm={confirmLogout}
                title={t('global.logout_confirm_title')}
                message={t('global.logout_confirm_msg')}
            />
        </div>
    );
}
