import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../widgets/app_layout.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/marketplace_screen.dart';
import '../screens/product_detail_screen.dart';
import '../screens/traceability_screen.dart';
import '../screens/chat_screen.dart';
import '../screens/admin/dashboard_screen.dart';
import '../screens/admin/users_screen.dart';
import '../screens/admin/orders_screen.dart';
import '../screens/admin/withdrawals_screen.dart';
import '../screens/admin/shrimp_types_screen.dart';
import '../screens/admin/shipments_screen.dart';
import '../screens/admin/traceability_logs_screen.dart';
import '../screens/petambak/dashboard_screen.dart';
import '../screens/petambak/farms_screen.dart';
import '../screens/petambak/cultivation_screen.dart';
import '../screens/petambak/harvests_screen.dart';
import '../screens/petambak/batches_screen.dart';
import '../screens/petambak/products_screen.dart';
import '../screens/petambak/sales_screen.dart';
import '../screens/petambak/withdrawals_screen.dart';
import '../screens/logistik/dashboard_screen.dart';
import '../screens/logistik/shipments_screen.dart';
import '../screens/konsumen/dashboard_screen.dart';
import '../screens/konsumen/orders_screen.dart';
import '../screens/konsumen/cart_screen.dart';
import '../screens/konsumen/checkout_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.toString();
      final loggedIn = authProvider.isAuthenticated;
      final role = authProvider.user?.role;

      // Auth pages: redirect to dashboard if logged in
      if (['/login', '/register'].contains(path) && loggedIn) {
        return authProvider.dashboardRoute;
      }

      // Protected routes
      if (path.startsWith('/admin') && (!loggedIn || role != 'admin')) return '/login';
      if (path.startsWith('/petambak') && (!loggedIn || role != 'petambak')) return '/login';
      if (path.startsWith('/logistik') && (!loggedIn || role != 'logistik')) return '/login';
      if (path.startsWith('/konsumen') && (!loggedIn || role != 'konsumen')) return '/login';
      if (path.startsWith('/chat') && !loggedIn) return '/login';

      return null;
    },
    routes: [
      // Public routes
      GoRoute(path: '/', builder: (_, _) => const LandingScreen()),
      GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
      GoRoute(path: '/marketplace', builder: (_, _) => const MarketplaceScreen()),
      GoRoute(path: '/products/:id', builder: (_, state) => ProductDetailScreen(productId: state.pathParameters['id']!)),
      GoRoute(path: '/traceability', builder: (_, _) => const TraceabilityScreen()),
      GoRoute(path: '/traceability/:code', builder: (_, state) => TraceabilityScreen(batchCode: state.pathParameters['code'])),

      // Authenticated routes with layout
      ShellRoute(
        builder: (_, _, child) => AppLayout(child: child),
        routes: [
          // Chat (all roles)
          GoRoute(path: '/chat', builder: (_, _) => const ChatScreen()),

          // Admin
          GoRoute(path: '/admin', builder: (_, _) => const AdminDashboardScreen()),
          GoRoute(path: '/admin/users', builder: (_, _) => const AdminUsersScreen()),
          GoRoute(path: '/admin/orders', builder: (_, _) => const AdminOrdersScreen()),
          GoRoute(path: '/admin/withdrawals', builder: (_, _) => const AdminWithdrawalsScreen()),
          GoRoute(path: '/admin/shrimp-types', builder: (_, _) => const AdminShrimpTypesScreen()),
          GoRoute(path: '/admin/shipments', builder: (_, _) => const AdminShipmentsScreen()),
          GoRoute(path: '/admin/traceability', builder: (_, _) => const AdminTraceabilityLogsScreen()),

          // Petambak
          GoRoute(path: '/petambak', builder: (_, _) => const PetambakDashboardScreen()),
          GoRoute(path: '/petambak/farms', builder: (_, _) => const PetambakFarmsScreen()),
          GoRoute(path: '/petambak/cultivation', builder: (_, _) => const PetambakCultivationScreen()),
          GoRoute(path: '/petambak/harvests', builder: (_, _) => const PetambakHarvestsScreen()),
          GoRoute(path: '/petambak/batches', builder: (_, _) => const PetambakBatchesScreen()),
          GoRoute(path: '/petambak/products', builder: (_, _) => const PetambakProductsScreen()),
          GoRoute(path: '/petambak/sales', builder: (_, _) => const PetambakSalesScreen()),
          GoRoute(path: '/petambak/withdrawals', builder: (_, _) => const PetambakWithdrawalsScreen()),

          // Logistik
          GoRoute(path: '/logistik', builder: (_, _) => const LogistikDashboardScreen()),
          GoRoute(path: '/logistik/shipments', builder: (_, _) => const LogistikShipmentsScreen()),

          // Konsumen
          GoRoute(path: '/konsumen', builder: (_, _) => const KonsumenDashboardScreen()),
          GoRoute(path: '/konsumen/orders', builder: (_, _) => const KonsumenOrdersScreen()),
          GoRoute(path: '/konsumen/cart', builder: (_, _) => const KonsumenCartScreen()),
          GoRoute(path: '/konsumen/checkout', builder: (_, _) => const KonsumenCheckoutScreen()),
        ],
      ),
    ],
  );
}
