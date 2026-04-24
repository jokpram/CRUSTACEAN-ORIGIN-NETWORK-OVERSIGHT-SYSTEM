import { FiLoader, FiInbox, FiAlertTriangle } from 'react-icons/fi';
import { useTranslation } from 'react-i18next';
export function LoadingSpinner({ message }: { message?: string }) {
    const { t } = useTranslation();
    return (
        <div className="flex flex-col items-center justify-center py-20 gap-4">
            <FiLoader className="w-10 h-10 text-primary-600 animate-spin" />
            <p className="text-gray-500 text-sm">{message || t('global.loading')}</p>
        </div>
    );
}
export function EmptyState({ title, message }: { title?: string; message?: string }) {
    const { t } = useTranslation();
    return (
        <div className="flex flex-col items-center justify-center py-20 gap-4">
            <div className="w-16 h-16 rounded-full bg-gray-100 flex items-center justify-center">
                <FiInbox className="w-8 h-8 text-gray-400" />
            </div>
            <h3 className="text-lg font-semibold text-gray-700">{title || t('global.empty_state_title')}</h3>
            <p className="text-gray-500 text-sm max-w-sm text-center">{message || t('global.empty_state_msg')}</p>
        </div>
    );
}
export function ErrorState({ message, onRetry }: { message?: string; onRetry?: () => void }) {
    const { t } = useTranslation();
    return (
        <div className="flex flex-col items-center justify-center py-20 gap-4">
            <div className="w-16 h-16 rounded-full bg-red-50 flex items-center justify-center">
                <FiAlertTriangle className="w-8 h-8 text-red-500" />
            </div>
            <h3 className="text-lg font-semibold text-red-700">{t('global.error')}</h3>
            <p className="text-gray-500 text-sm max-w-sm text-center">{message || t('global.error_state')}</p>
            {onRetry && (
                <button onClick={onRetry} className="btn-primary btn-sm">
                    {t('global.btn_try_again')}
                </button>
            )}
        </div>
    );
}
export function StatCard({ title, value, icon, color = 'primary' }: {
    title: string; value: string | number; icon: React.ReactNode; color?: string;
}) {
    const colorMap: Record<string, string> = {
        primary: 'from-primary-500 to-primary-600',
        accent: 'from-accent-500 to-accent-600',
        ocean: 'from-ocean-500 to-ocean-600',
        orange: 'from-orange-500 to-orange-600',
        purple: 'from-purple-500 to-purple-600',
        red: 'from-red-500 to-red-600',
    };
    return (
        <div className="card p-6 hover:shadow-md transition-shadow">
            <div className="flex items-center justify-between">
                <div>
                    <p className="text-sm text-gray-500 mb-1">{title}</p>
                    <p className="text-2xl font-bold text-gray-900">{value}</p>
                </div>
                <div className={`w-12 h-12 rounded-xl bg-gradient-to-br ${colorMap[color] || colorMap.primary} flex items-center justify-center text-white`}>
                    {icon}
                </div>
            </div>
        </div>
    );
}
export function StatusBadge({ status }: { status: string }) {
    const config: Record<string, string> = {
        active: 'badge-success',
        pending: 'badge-warning',
        paid: 'badge-success',
        processing: 'badge-info',
        shipped: 'badge-info',
        delivered: 'badge-success',
        completed: 'badge-success',
        cancelled: 'badge-danger',
        failed: 'badge-danger',
        expired: 'badge-danger',
        approved: 'badge-success',
        rejected: 'badge-danger',
        pickup: 'badge-info',
        transit: 'badge-info',
        available: 'badge-success',
        verified: 'badge-success',
    };
    return (
        <span className={config[status] || 'badge-gray'}>
            {status.charAt(0).toUpperCase() + status.slice(1)}
        </span>
    );
}
export function Modal({ isOpen, onClose, title, children }: {
    isOpen: boolean; onClose: () => void; title: string; children: React.ReactNode;
}) {
    if (!isOpen) return null;
    return (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4">
            <div className="fixed inset-0 bg-black/50 backdrop-blur-sm" onClick={onClose} />
            <div className="card relative z-10 w-full max-w-lg max-h-[90vh] overflow-y-auto">
                <div className="flex items-center justify-between p-6 border-b border-gray-100">
                    <h3 className="text-lg font-semibold text-gray-900">{title}</h3>
                    <button onClick={onClose} className="text-gray-400 hover:text-gray-600 text-xl cursor-pointer">&times;</button>
                </div>
                <div className="p-6">{children}</div>
            </div>
        </div>
    );
}
export function ConfirmDialog({ isOpen, onClose, onConfirm, title, message }: {
    isOpen: boolean; onClose: () => void; onConfirm: () => void; title: string; message: string;
}) {
    const { t } = useTranslation();
    if (!isOpen) return null;
    return (
        <Modal isOpen={isOpen} onClose={onClose} title={title}>
            <p className="text-gray-600 mb-6">{message}</p>
            <div className="flex gap-3 justify-end">
                <button onClick={onClose} className="btn-outline">{t('global.btn_cancel')}</button>
                <button onClick={() => { onConfirm(); onClose(); }} className="btn-danger">{t('global.btn_confirm')}</button>
            </div>
        </Modal>
    );
}
