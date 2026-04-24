import { useState } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { authApi } from '../api/authApi';
import { useAuthStore } from '../store/authStore';
import { FiMail, FiLock, FiUser, FiPhone, FiEye, FiEyeOff } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
import WaterSurface from '../components/WaterSurface';

export default function Register() {
    const [form, setForm] = useState({ name: '', email: '', password: '', phone: '', role: 'konsumen' });
    const [showPassword, setShowPassword] = useState(false);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState('');
    const navigate = useNavigate();
    const { setAuth } = useAuthStore();
    const { t } = useTranslation();

    const handleSubmit = async (e: React.FormEvent) => {
        e.preventDefault();
        setLoading(true);
        setError('');
        try {
            const res = await authApi.register(form);
            const { user, token } = res.data.data;
            setAuth(user, token);
            toast.success(t('auth.reg_success', 'Account created successfully!'));
            if (user.role === 'konsumen') {
                navigate('/konsumen');
            } else {
                navigate('/login');
            }
        } catch (err: unknown) {
            const msg = (err as { response?: { data?: { message?: string } } })?.response?.data?.message || t('global.error');
            setError(msg);
            toast.error(msg);
        } finally {
            setLoading(false);
        }
    };

    return (
        <div className="relative min-h-screen flex items-center justify-center p-4 overflow-hidden">
            <div className="absolute inset-0 z-0 opacity-30 pointer-events-none">
                <WaterSurface />
            </div>

            <div className="w-full max-w-md relative z-10">
                <div className="text-center mb-8">
                    <Link to="/" className="inline-flex items-center gap-3 mb-4">
                        <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-ocean-500 to-accent-500 flex items-center justify-center font-bold text-white text-xl">C</div>
                    </Link>
                    <h1 className="text-2xl font-bold text-gray-900">{t('auth.create_account')}</h1>
                    <p className="text-gray-500 text-sm mt-1">{t('auth.join_sub')}</p>
                </div>
                <form onSubmit={handleSubmit} className="card p-8 bg-white/80 backdrop-blur-md">
                    {error && <div className="bg-red-50 text-red-600 text-sm p-3 rounded-xl mb-4">{error}</div>}
                    <div className="mb-4">
                        <label className="label">{t('auth.full_name')}</label>
                        <div className="relative">
                            <FiUser className="absolute left-3 top-3 text-gray-400" />
                            <input type="text" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} placeholder="Eddie Vedder" className="input pl-10 bg-white/50" required />
                        </div>
                    </div>
                    <div className="mb-4">
                        <label className="label">{t('auth.email')}</label>
                        <div className="relative">
                            <FiMail className="absolute left-3 top-3 text-gray-400" />
                            <input type="email" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} placeholder="eddievedder@pearljam.com" className="input pl-10 bg-white/50" required />
                        </div>
                    </div>
                    <div className="mb-4">
                        <label className="label">{t('auth.phone')}</label>
                        <div className="relative">
                            <FiPhone className="absolute left-3 top-3 text-gray-400" />
                            <input type="tel" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} placeholder="000000000000" className="input pl-10 bg-white/50" />
                        </div>
                    </div>
                    <div className="mb-6">
                        <label className="label">{t('auth.password')}</label>
                        <div className="relative">
                            <FiLock className="absolute left-3 top-3 text-gray-400" />
                            <input type={showPassword ? 'text' : 'password'} value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} placeholder="Min 6 characters" className="input pl-10 pr-10 bg-white/50" required minLength={6} />
                            <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-3 text-gray-400 cursor-pointer">
                                {showPassword ? <FiEyeOff /> : <FiEye />}
                            </button>
                        </div>
                    </div>
                    <button type="submit" disabled={loading} className="btn-primary w-full btn-lg">
                        {loading ? t('auth.creating_account') : t('auth.btn_register')}
                    </button>
                    <p className="text-center text-sm text-gray-500 mt-6">
                        {t('auth.has_account')} <Link to="/login" className="text-primary-600 font-medium hover:underline">{t('auth.sign_in')}</Link>
                    </p>
                </form>
            </div>
        </div>
    );
}
