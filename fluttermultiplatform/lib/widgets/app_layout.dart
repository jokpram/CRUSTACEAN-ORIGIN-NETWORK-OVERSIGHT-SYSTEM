import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/global_nav.dart';

class _SidebarItem {
  final String labelKey;
  final IconData icon;
  final String path;
  _SidebarItem(this.labelKey, this.icon, this.path);
}

/// Sidebar config matching React AppLayout.tsx sidebarConfig exactly.
/// Each label is a t() key resolved at runtime for i18n.
final Map<String, List<_SidebarItem>> _sidebarConfig = {
  'admin': [
    _SidebarItem('nav.dashboard', Icons.dashboard_rounded, '/admin'),
    _SidebarItem('nav.users', Icons.people_rounded, '/admin/users'),
    _SidebarItem('nav.chat', Icons.chat_rounded, '/chat'),
    _SidebarItem('nav.orders', Icons.shopping_bag_rounded, '/admin/orders'),
    _SidebarItem('nav.withdrawals', Icons.attach_money_rounded, '/admin/withdrawals'),
    _SidebarItem('nav.shrimp_types', Icons.water_drop_rounded, '/admin/shrimp-types'),
    _SidebarItem('nav.shipments', Icons.local_shipping_rounded, '/admin/shipments'),
    _SidebarItem('nav.traceability', Icons.assignment_rounded, '/admin/traceability'),
  ],
  'petambak': [
    _SidebarItem('nav.dashboard', Icons.dashboard_rounded, '/petambak'),
    _SidebarItem('nav.chat', Icons.chat_rounded, '/chat'),
    _SidebarItem('nav.farms', Icons.map_rounded, '/petambak/farms'),
    _SidebarItem('nav.cultivation', Icons.water_drop_rounded, '/petambak/cultivation'),
    _SidebarItem('nav.harvests', Icons.content_cut_rounded, '/petambak/harvests'),
    _SidebarItem('nav.batches', Icons.layers_rounded, '/petambak/batches'),
    _SidebarItem('nav.products', Icons.inventory_2_rounded, '/petambak/products'),
    _SidebarItem('nav.sales', Icons.shopping_bag_rounded, '/petambak/sales'),
    _SidebarItem('nav.withdrawals', Icons.attach_money_rounded, '/petambak/withdrawals'),
  ],
  'logistik': [
    _SidebarItem('nav.dashboard', Icons.dashboard_rounded, '/logistik'),
    _SidebarItem('nav.chat', Icons.chat_rounded, '/chat'),
    _SidebarItem('nav.shipments', Icons.local_shipping_rounded, '/logistik/shipments'),
  ],
  'konsumen': [
    _SidebarItem('nav.dashboard', Icons.dashboard_rounded, '/konsumen'),
    _SidebarItem('nav.chat', Icons.chat_rounded, '/chat'),
    _SidebarItem('nav.marketplace', Icons.storefront_rounded, '/marketplace'),
    _SidebarItem('nav.my_orders', Icons.receipt_long_rounded, '/konsumen/orders'),
    _SidebarItem('nav.cart', Icons.shopping_cart_rounded, '/konsumen/cart'),
  ],
};

class AppLayout extends StatefulWidget {
  final Widget child;
  const AppLayout({super.key, required this.child});
  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  bool _sidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();
    final loc = context.watch<AppLocalizations>();
    final user = auth.user;
    final role = user?.role ?? 'konsumen';
    final menuItems = _sidebarConfig[role] ?? [];
    final currentPath = GoRouterState.of(context).uri.toString();
    final isWide = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Sidebar
              if (isWide || _sidebarOpen)
                Container(
                  width: 256,
                  color: CronosColors.gray900,
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Logo
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(gradient: CronosColors.logoBadge, borderRadius: BorderRadius.circular(12)),
                                child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18))),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CRONOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                                  Text('${role[0].toUpperCase()}${role.substring(1)} Panel', style: TextStyle(color: CronosColors.gray400, fontSize: 12)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Divider(color: CronosColors.gray800, height: 1),
                        // Nav items — labels resolved via loc.t()
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(12),
                            children: menuItems.map((item) {
                              final isActive = currentPath == item.path || (item.path != '/' && currentPath.startsWith('${item.path}/'));
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Material(
                                  color: isActive ? CronosColors.primary600 : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      context.go(item.path);
                                      if (!isWide) setState(() => _sidebarOpen = false);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                      child: Row(
                                        children: [
                                          Icon(item.icon, size: 20, color: isActive ? Colors.white : CronosColors.gray300),
                                          const SizedBox(width: 12),
                                          Text(loc.t(item.labelKey), style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isActive ? Colors.white : CronosColors.gray300)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // User info
                        const Divider(color: CronosColors.gray800, height: 1),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: CronosColors.gray800, borderRadius: BorderRadius.circular(12)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 32, height: 32,
                                      decoration: BoxDecoration(gradient: CronosColors.logoBadge, borderRadius: BorderRadius.circular(16)),
                                      child: Center(child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold))),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(user?.name ?? '', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis),
                                          Text(user?.email ?? '', style: TextStyle(color: CronosColors.gray400, fontSize: 11), overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () async {
                                  final confirm = await showConfirmDialog(context, title: loc.t('global.logout_confirm_title'), message: loc.t('global.logout_confirm_msg'));
                                  if (confirm == true && context.mounted) {
                                    auth.logout();
                                    context.go('/login');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.logout_rounded, size: 20, color: CronosColors.gray300),
                                      const SizedBox(width: 12),
                                      Text(loc.t('nav.logout'), style: const TextStyle(fontSize: 14, color: CronosColors.gray300)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Overlay for mobile sidebar
              if (_sidebarOpen && !isWide)
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _sidebarOpen = false),
                    child: Container(color: Colors.black54),
                  ),
                ),
              // Main content
              if (isWide || !_sidebarOpen)
                Expanded(
                  child: Column(
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(bottom: BorderSide(color: CronosColors.gray200)),
                        ),
                        child: Row(
                          children: [
                            if (!isWide)
                              IconButton(
                                icon: Icon(_sidebarOpen ? Icons.close : Icons.menu, color: CronosColors.gray600),
                                onPressed: () => setState(() => _sidebarOpen = !_sidebarOpen),
                              ),
                            const Spacer(),
                            // Home button
                            TextButton.icon(
                              onPressed: () => context.go('/'),
                              icon: const Icon(Icons.home_rounded, size: 20),
                              label: Text(loc.t('nav.back_to_home')),
                            ),
                            const SizedBox(width: 8),
                            // Cart for konsumen
                            if (role == 'konsumen')
                              Stack(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.shopping_cart_outlined, color: CronosColors.gray600),
                                    onPressed: () => context.go('/konsumen/cart'),
                                  ),
                                  if (cart.totalItems > 0)
                                    Positioned(
                                      right: 4, top: 4,
                                      child: Container(
                                        width: 18, height: 18,
                                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(9), border: Border.all(color: Colors.white, width: 2)),
                                        child: Center(child: Text('${cart.totalItems}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                                      ),
                                    ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      // Content
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: widget.child,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          // GlobalNav floating widget
          const GlobalNav(),
        ],
      ),
    );
  }
}
