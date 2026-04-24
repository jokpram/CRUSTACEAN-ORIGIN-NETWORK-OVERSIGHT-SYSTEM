import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { useAuthStore } from '../store/authStore';
import AppLayout from '../layouts/AppLayout';
import { lazy, Suspense } from 'react';
import { LoadingSpinner } from '../components/ui';
const Landing = lazy(() => import('../pages/Landing'));
const Login = lazy(() => import('../pages/Login'));
const Register = lazy(() => import('../pages/Register'));
const Marketplace = lazy(() => import('../pages/Marketplace'));
const ProductDetail = lazy(() => import('../pages/ProductDetail'));
const Traceability = lazy(() => import('../pages/Traceability'));
const Chat = lazy(() => import('../pages/Chat'));
const AdminDashboard = lazy(() => import('../pages/admin/Dashboard'));
const AdminUsers = lazy(() => import('../pages/admin/Users'));
const AdminOrders = lazy(() => import('../pages/admin/Orders'));
const AdminWithdrawals = lazy(() => import('../pages/admin/Withdrawals'));
const AdminShrimpTypes = lazy(() => import('../pages/admin/ShrimpTypes'));
const AdminShipments = lazy(() => import('../pages/admin/Shipments'));
const AdminTraceability = lazy(() => import('../pages/admin/TraceabilityLogs'));
const PetambakDashboard = lazy(() => import('../pages/petambak/Dashboard'));
const PetambakFarms = lazy(() => import('../pages/petambak/Farms'));
const PetambakCultivation = lazy(() => import('../pages/petambak/Cultivation'));
const PetambakHarvests = lazy(() => import('../pages/petambak/Harvests'));
const PetambakBatches = lazy(() => import('../pages/petambak/Batches'));
const PetambakProducts = lazy(() => import('../pages/petambak/Products'));
const PetambakSales = lazy(() => import('../pages/petambak/Sales'));
const PetambakWithdrawals = lazy(() => import('../pages/petambak/Withdrawals'));
const LogistikDashboard = lazy(() => import('../pages/logistik/Dashboard'));
const LogistikShipments = lazy(() => import('../pages/logistik/Shipments'));
const KonsumenDashboard = lazy(() => import('../pages/konsumen/Dashboard'));
const KonsumenOrders = lazy(() => import('../pages/konsumen/Orders'));
const KonsumenCart = lazy(() => import('../pages/konsumen/Cart'));
const KonsumenCheckout = lazy(() => import('../pages/konsumen/Checkout'));
function ProtectedRoute({ children, roles }: { children: React.ReactNode; roles?: string[] }) {
    const { isAuthenticated, user } = useAuthStore();
    if (!isAuthenticated) return <Navigate to="/login" replace />;
    if (roles && user && !roles.includes(user.role)) {
        const dashboard = user.role === 'admin' ? '/admin' : `/${user.role}`;
        return <Navigate to={dashboard} replace />;
    }
    return <>{children}</>;
}

function PublicRoute({ children }: { children: React.ReactNode }) {
    const { isAuthenticated, user } = useAuthStore();
    if (isAuthenticated && user) {
        const dashboard = user.role === 'admin' ? '/admin' : `/${user.role}`;
        return <Navigate to={dashboard} replace />;
    }
    return <>{children}</>;
}

function DynamicRedirect() {
    const { isAuthenticated, user } = useAuthStore();
    if (isAuthenticated && user) {
        const dashboard = user.role === 'admin' ? '/admin' : `/${user.role}`;
        return <Navigate to={dashboard} replace />;
    }
    return <Navigate to="/" replace />;
}
export default function AppRouter() {
    return (
        <BrowserRouter>
            <Toaster position="top-center" reverseOrder={false} gutter={8} containerClassName="" containerStyle={{}} toastOptions={{ duration: 3000, style: { background: '#111827', color: '#fff', borderRadius: '12px' } }} />
            <Suspense fallback={<LoadingSpinner message="Loading page..." />}>
                <Routes>
                    { }
                    <Route path="/" element={<Landing />} />
                    <Route path="/login" element={<PublicRoute><Login /></PublicRoute>} />
                    <Route path="/register" element={<PublicRoute><Register /></PublicRoute>} />
                    <Route path="/marketplace" element={<Marketplace />} />
                    <Route path="/products/:id" element={<ProductDetail />} />
                    <Route path="/traceability" element={<Traceability />} />
                    <Route path="/traceability/:batchCode" element={<Traceability />} />
                    { }
                    <Route element={<ProtectedRoute><AppLayout /></ProtectedRoute>}>
                        <Route path="/chat" element={<Chat />} />
                    </Route>
                    { }
                    <Route path="/admin" element={<ProtectedRoute roles={['admin']}><AppLayout /></ProtectedRoute>}>
                        <Route index element={<AdminDashboard />} />
                        <Route path="users" element={<AdminUsers />} />
                        <Route path="orders" element={<AdminOrders />} />
                        <Route path="withdrawals" element={<AdminWithdrawals />} />
                        <Route path="shrimp-types" element={<AdminShrimpTypes />} />
                        <Route path="shipments" element={<AdminShipments />} />
                        <Route path="traceability" element={<AdminTraceability />} />
                    </Route>
                    { }
                    <Route path="/petambak" element={<ProtectedRoute roles={['petambak']}><AppLayout /></ProtectedRoute>}>
                        <Route index element={<PetambakDashboard />} />
                        <Route path="farms" element={<PetambakFarms />} />
                        <Route path="cultivation" element={<PetambakCultivation />} />
                        <Route path="harvests" element={<PetambakHarvests />} />
                        <Route path="batches" element={<PetambakBatches />} />
                        <Route path="products" element={<PetambakProducts />} />
                        <Route path="sales" element={<PetambakSales />} />
                        <Route path="withdrawals" element={<PetambakWithdrawals />} />
                    </Route>
                    { }
                    <Route path="/logistik" element={<ProtectedRoute roles={['logistik']}><AppLayout /></ProtectedRoute>}>
                        <Route index element={<LogistikDashboard />} />
                        <Route path="shipments" element={<LogistikShipments />} />
                    </Route>
                    { }
                    <Route path="/konsumen" element={<ProtectedRoute roles={['konsumen']}><AppLayout /></ProtectedRoute>}>
                        <Route index element={<KonsumenDashboard />} />
                        <Route path="orders" element={<KonsumenOrders />} />
                        <Route path="cart" element={<KonsumenCart />} />
                        <Route path="checkout" element={<KonsumenCheckout />} />
                    </Route>
                    { }
                    <Route path="*" element={<DynamicRedirect />} />
                </Routes>
            </Suspense>
        </BrowserRouter>
    );
}
