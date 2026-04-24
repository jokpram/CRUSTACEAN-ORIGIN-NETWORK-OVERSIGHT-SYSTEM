import { useState } from 'react';
import { useNavigate, useLocation } from 'react-router-dom';
import { useTranslation } from 'react-i18next';
import { FiHome, FiGlobe, FiX } from 'react-icons/fi';
export default function GlobalNav() {
    const navigate = useNavigate();
    const location = useLocation();
    const { t, i18n } = useTranslation();
    const [langOpen, setLangOpen] = useState(false);
    const isHome = location.pathname === '/';
    return (
        <div className="fixed bottom-6 right-6 z-50 flex flex-col gap-3 items-end">
            {}
            <div className="relative">
                <button
                    onClick={() => setLangOpen(!langOpen)}
                    className="bg-white/90 backdrop-blur-md p-3.5 rounded-2xl shadow-xl border border-gray-200/50 text-gray-500 hover:text-primary-600 transition-colors flex items-center justify-center cursor-pointer"
                    title="Change Language"
                >
                    {langOpen ? <FiX className="w-5 h-5" /> : <FiGlobe className="w-5 h-5" />}
                </button>
                {langOpen && (
                    <div className="absolute bottom-full right-0 mb-4 w-48 bg-white p-2 rounded-2xl shadow-2xl border border-gray-100 flex flex-col gap-1 origin-bottom-right">
                        <div className="flex items-center justify-between px-3 py-2 mb-1 border-b border-gray-50">
                            <span className="text-xs font-semibold text-gray-400 uppercase tracking-wider">Language</span>
                            <button onClick={() => setLangOpen(false)} className="text-gray-400 hover:text-red-500 transition-colors p-1 cursor-pointer bg-red-50 hover:bg-red-100 rounded-full">
                                <FiX size={14} />
                            </button>
                        </div>
                        <button
                            onClick={() => { i18n.changeLanguage('id'); setLangOpen(false); }}
                            className={`px-3 py-2 text-sm rounded-xl hover:bg-gray-50 transition-colors text-left font-medium cursor-pointer ${i18n.language.startsWith('id') ? 'text-primary-600 bg-primary-50' : 'text-gray-600'}`}
                        >
                            ID (Indonesia)
                        </button>
                        <button
                            onClick={() => { i18n.changeLanguage('en'); setLangOpen(false); }}
                            className={`px-3 py-2 text-sm rounded-xl hover:bg-gray-50 transition-colors text-left font-medium cursor-pointer ${i18n.language.startsWith('en') ? 'text-primary-600 bg-primary-50' : 'text-gray-600'}`}
                        >
                            EN (English)
                        </button>
                        <button
                            onClick={() => { i18n.changeLanguage('nl'); setLangOpen(false); }}
                            className={`px-3 py-2 text-sm rounded-xl hover:bg-gray-50 transition-colors text-left font-medium cursor-pointer ${i18n.language.startsWith('nl') ? 'text-primary-600 bg-primary-50' : 'text-gray-600'}`}
                        >
                            NL (Nederlands)
                        </button>
                    </div>
                )}
            </div>
            {}
            {!isHome && (
                <button
                    onClick={() => navigate('/')}
                    className="bg-primary-600 hover:bg-primary-700 text-white p-4 rounded-2xl shadow-xl shadow-primary-600/30 transition-transform hover:scale-105 hover:-translate-y-1 flex items-center justify-center cursor-pointer"
                    title={t('nav.back_to_home')}
                >
                    <FiHome className="w-5 h-5" />
                </button>
            )}
        </div>
    );
}
