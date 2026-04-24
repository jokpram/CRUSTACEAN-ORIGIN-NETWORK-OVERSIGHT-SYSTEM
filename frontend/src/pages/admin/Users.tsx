import { useState, useEffect } from 'react';
import { userApi } from '../../api/traceabilityApi';
import { LoadingSpinner, EmptyState, ErrorState, StatusBadge } from '../../components/ui';
import type { User } from '../../types';
import { FiPlus, FiX } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
import toast from 'react-hot-toast';
export default function AdminUsers() {
    const [users, setUsers] = useState<User[]>([]);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState('');
    const { t } = useTranslation();
    const [isModalOpen, setIsModalOpen] = useState(false);
    const [createLoading, setCreateLoading] = useState(false);
    const [createError, setCreateError] = useState('');
    const [form, setForm] = useState({ name: '', email: '', password: '', phone: '', role: 'petambak' });
    const fetchUsers = () => {
        setLoading(true);
        userApi.getAll().then(res => setUsers(res.data.data || [])).catch(() => setError(t('admin.users.err_load'))).finally(() => setLoading(false));
    };
    useEffect(() => { fetchUsers(); }, [t]);
    const handleVerify = async (id: string) => {
        try {
            await userApi.verify(id);
            toast.success(t('admin.users.verify_success', 'User verified successfully'));
            fetchUsers();
        } catch (err: any) {
            toast.error(err.response?.data?.message || t('admin.users.err_verify', 'Failed to verify user'));
        }
    };
    const handleCreateUser = async (e: React.FormEvent) => {
        e.preventDefault();
        setCreateLoading(true);
        setCreateError('');
        try {
            await userApi.create(form);
            toast.success(t('admin.users.create_success', 'User created successfully'));
            setIsModalOpen(false);
            setForm({ name: '', email: '', password: '', phone: '', role: 'petambak' });
            fetchUsers();
        } catch (err: any) {
            const msg = err.response?.data?.message || t('admin.users.err_create');
            setCreateError(msg);
            toast.error(msg);
        } finally {
            setCreateLoading(false);
        }
    };
    if (loading) return <LoadingSpinner />;
    if (error) return <ErrorState message={error} onRetry={fetchUsers} />;
    return (
        <div>
            <div className="flex justify-between items-center mb-6">
                <h1 className="text-2xl font-bold">{t('admin.users.title')}</h1>
                <button onClick={() => setIsModalOpen(true)} className="btn-primary flex items-center gap-2">
                    <FiPlus /> {t('admin.users.create_new')}
                </button>
            </div>
            {users.length === 0 ? <EmptyState title={t('admin.users.empty_title')} message={t('admin.users.empty_desc')} /> : (
                <div className="card overflow-x-auto">
                    <table className="w-full text-sm">
                        <thead className="bg-gray-50 border-b">
                            <tr>
                                <th className="text-left p-4 font-semibold">{t('admin.users.col_name')}</th>
                                <th className="text-left p-4 font-semibold">{t('admin.users.col_email')}</th>
                                <th className="text-left p-4 font-semibold">{t('admin.users.col_role')}</th>
                                <th className="text-left p-4 font-semibold">{t('admin.users.col_status')}</th>
                                <th className="text-left p-4 font-semibold">{t('admin.users.col_actions')}</th>
                            </tr>
                        </thead>
                        <tbody className="divide-y">
                            {users.map(u => (
                                <tr key={u.id} className="hover:bg-gray-50">
                                    <td className="p-4 font-medium">{u.name}</td>
                                    <td className="p-4 text-gray-600">{u.email}</td>
                                    <td className="p-4"><span className="badge-info capitalize">{u.role}</span></td>
                                    <td className="p-4"><StatusBadge status={u.is_verified ? 'verified' : 'pending'} /></td>
                                    <td className="p-4">
                                        {!u.is_verified && u.role !== 'admin' && (
                                            <button onClick={() => handleVerify(u.id)} className="btn-accent btn-sm">{t('admin.users.btn_verify')}</button>
                                        )}
                                    </td>
                                </tr>
                            ))}
                        </tbody>
                    </table>
                </div>
            )}
            { }
            {isModalOpen && (
                <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/50 backdrop-blur-sm">
                    <div className="card w-full max-w-md bg-white">
                        <div className="flex items-center justify-between p-4 border-b">
                            <h2 className="text-lg font-bold">{t('admin.users.create_new')}</h2>
                            <button onClick={() => setIsModalOpen(false)} className="p-2 hover:bg-gray-100 rounded-full">
                                <FiX />
                            </button>
                        </div>
                        <form onSubmit={handleCreateUser} className="p-4">
                            {createError && <div className="bg-red-50 text-red-600 text-sm p-3 rounded-xl mb-4">{createError}</div>}
                            <div className="space-y-4">
                                <div>
                                    <label className="label">{t('admin.users.lbl_name')}</label>
                                    <input type="text" className="input" value={form.name} onChange={e => setForm({ ...form, name: e.target.value })} required />
                                </div>
                                <div>
                                    <label className="label">{t('admin.users.lbl_email')}</label>
                                    <input type="email" className="input" value={form.email} onChange={e => setForm({ ...form, email: e.target.value })} required />
                                </div>
                                <div>
                                    <label className="label">{t('admin.users.lbl_password')}</label>
                                    <input type="password" className="input" value={form.password} onChange={e => setForm({ ...form, password: e.target.value })} required minLength={6} placeholder="Min. 6 characters" />
                                </div>
                                <div>
                                    <label className="label">{t('admin.users.lbl_phone')}</label>
                                    <input type="text" className="input" value={form.phone} onChange={e => setForm({ ...form, phone: e.target.value })} />
                                </div>
                                <div>
                                    <label className="label">{t('admin.users.lbl_role')}</label>
                                    <select className="input" value={form.role} onChange={e => setForm({ ...form, role: e.target.value })} required>
                                        <option value="petambak">{t('admin.users.opt_petambak')}</option>
                                        <option value="logistik">{t('admin.users.opt_logistik')}</option>
                                    </select>
                                </div>
                            </div>
                            <div className="mt-6 flex gap-3 justify-end">
                                <button type="button" onClick={() => setIsModalOpen(false)} className="btn-secondary">{t('admin.users.btn_cancel')}</button>
                                <button type="submit" disabled={createLoading} className="btn-primary">
                                    {createLoading ? t('admin.users.btn_creating') : t('admin.users.btn_submit')}
                                </button>
                            </div>
                        </form>
                    </div>
                </div>
            )}
        </div>
    );
}
