import { Link } from 'react-router-dom';
import { FiShield, FiTruck, FiSearch, FiDollarSign, FiDatabase, FiUsers, FiHexagon, FiBox, FiShoppingCart } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import { useAuthStore } from '../store/authStore';
import WaterSurface from '../components/WaterSurface';
export default function Landing() {
    const { t } = useTranslation();
    const { isAuthenticated, user } = useAuthStore();
    const dashboardLink = user ? (user.role === 'admin' ? '/admin' : `/${user.role}`) : '/login';
    const features = [
        { icon: <FiShield className="w-6 h-6" />, title: t('landing.feat1_title'), desc: t('landing.feat1_desc') },
        { icon: <FiSearch className="w-6 h-6" />, title: t('landing.feat2_title'), desc: t('landing.feat2_desc') },
        { icon: <FiTruck className="w-6 h-6" />, title: t('landing.feat3_title'), desc: t('landing.feat3_desc') },
        { icon: <FiDollarSign className="w-6 h-6" />, title: t('landing.feat4_title'), desc: t('landing.feat4_desc') },
        { icon: <FiDatabase className="w-6 h-6" />, title: t('landing.feat5_title'), desc: t('landing.feat5_desc') },
        { icon: <FiUsers className="w-6 h-6" />, title: t('landing.feat6_title'), desc: t('landing.feat6_desc') },
    ];
    const howItWorks = [
        { text: t('landing.step1'), icon: <FiDatabase className="w-8 h-8" /> },
        { text: t('landing.step2'), icon: <FiBox className="w-8 h-8" /> },
        { text: t('landing.step3'), icon: <FiShoppingCart className="w-8 h-8" /> },
        { text: t('landing.step4'), icon: <FiTruck className="w-8 h-8" /> }
    ];
    return (
        <div className="min-h-screen relative">
            <WaterSurface />
            { }
            <nav className="bg-white/80 backdrop-blur-lg border-b border-gray-100 sticky top-0 z-50">
                <div className="max-w-7xl mx-auto px-6 py-4 flex items-center justify-between">
                    <Link to="/" className="flex items-center gap-3">
                        <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-ocean-500 to-accent-500 flex items-center justify-center font-bold text-white text-lg">C</div>
                        <span className="font-bold text-xl text-gray-900">CRONOS</span>
                    </Link>
                    <div className="flex items-center gap-4">
                        <Link to="/marketplace" className="text-sm text-gray-600 hover:text-primary-600 font-medium">{t('nav.marketplace')}</Link>
                        <Link to="/traceability" className="text-sm text-gray-600 hover:text-primary-600 font-medium">{t('nav.traceability')}</Link>
                        {isAuthenticated ? (
                            <Link to={dashboardLink} className="btn-primary btn-sm">{t('nav.dashboard', 'Dashboard')}</Link>
                        ) : (
                            <>
                                <Link to="/login" className="btn-outline btn-sm">{t('nav.login')}</Link>
                                <Link to="/register" className="btn-primary btn-sm">{t('nav.register')}</Link>
                            </>
                        )}
                    </div>
                </div>
            </nav>
            { }
            <section className="gradient-hero text-white">
                <div className="max-w-7xl mx-auto px-6 py-24 text-center">
                    <div className="inline-flex items-center gap-2 bg-white/10 backdrop-blur rounded-full px-4 py-1.5 text-sm mb-8">
                        <FiHexagon /> {t('landing.badge')}
                    </div>
                    <h1 className="text-5xl md:text-7xl font-bold mb-6 leading-tight">
                        {t('landing.title1')}<br />{t('landing.title2')} <span className="text-accent-300">{t('landing.title3')}</span>
                    </h1>
                    <p className="text-lg md:text-xl text-gray-200 max-w-2xl mx-auto mb-10">
                        {t('landing.subtitle')}
                    </p>
                    <div className="flex flex-col sm:flex-row gap-4 justify-center">
                        <Link to="/marketplace" className="btn-lg bg-white text-gray-900 font-bold hover:bg-gray-100 rounded-xl px-8 py-4 shadow-2xl">
                            {t('landing.btn_browse')}
                        </Link>
                        <Link to="/traceability" className="btn-lg border-2 border-white/30 text-white hover:bg-white/10 rounded-xl px-8 py-4">
                            {t('landing.btn_trace')}
                        </Link>
                    </div>
                </div>
            </section>
            { }
            <section className="py-24 bg-white">
                <div className="max-w-7xl mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-4">{t('landing.why_title')}</h2>
                    <p className="text-gray-500 text-center mb-16 max-w-xl mx-auto">{t('landing.why_subtitle')}</p>
                    <div className="grid md:grid-cols-3 gap-8">
                        {features.map((f, i) => (
                            <div key={i} className="card p-8 hover:shadow-lg transition-shadow group">
                                <div className="w-14 h-14 rounded-2xl bg-gradient-to-br from-primary-100 to-accent-100 flex items-center justify-center text-primary-600 mb-5 group-hover:scale-110 transition-transform">
                                    {f.icon}
                                </div>
                                <h3 className="font-semibold text-lg mb-2">{f.title}</h3>
                                <p className="text-gray-500 text-sm leading-relaxed">{f.desc}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
            { }
            <section className="py-24 bg-gray-50">
                <div className="max-w-7xl mx-auto px-6">
                    <h2 className="text-3xl font-bold text-center mb-16">{t('landing.how_title')}</h2>
                    <div className="grid md:grid-cols-4 gap-8">
                        {howItWorks.map((step, i) => (
                            <div key={i} className="text-center">
                                <div className="w-16 h-16 rounded-full bg-gradient-to-br from-primary-500 to-ocean-500 mx-auto mb-4 flex items-center justify-center text-white">
                                    {step.icon}
                                </div>
                                <p className="font-medium text-gray-800">{step.text}</p>
                            </div>
                        ))}
                    </div>
                </div>
            </section>
            { }
            <footer className="bg-gray-900 text-gray-400 py-12">
                <div className="max-w-7xl mx-auto px-6 text-center">
                    <p className="text-sm">{t('landing.footer')}</p>
                </div>
            </footer>
        </div>
    );
}
