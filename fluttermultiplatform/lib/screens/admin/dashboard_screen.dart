import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});
  @override
  State<AdminDashboardScreen> createState() => _State();
}

class _State extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try { final res = await DashboardApi.getAdmin(); _data = res.data['data']; } catch (_) { _error = 'admin.dashboard.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    final users = (_data?['users_by_role'] ?? {}) as Map<String, dynamic>;
    final orders = (_data?['orders_by_status'] ?? {}) as Map<String, dynamic>;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('admin.dashboard.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: 240, child: StatCard(title: loc.t('admin.dashboard.total_users'), value: '${_data?['total_users'] ?? 0}', icon: Icons.people_rounded, color: CronosColors.primary600)),
        SizedBox(width: 240, child: StatCard(title: loc.t('admin.dashboard.total_orders'), value: '${_data?['total_orders'] ?? 0}', icon: Icons.shopping_bag_rounded, color: CronosColors.accent500)),
        SizedBox(width: 240, child: StatCard(title: loc.t('admin.dashboard.revenue'), value: 'Rp ${((_data?['total_revenue'] ?? 0) as num).toStringAsFixed(0)}', icon: Icons.attach_money_rounded, color: CronosColors.ocean500)),
        SizedBox(width: 240, child: StatCard(title: loc.t('admin.dashboard.paid_orders'), value: '${_data?['paid_orders'] ?? 0}', icon: Icons.check_circle_rounded, color: Colors.green)),
      ]),
      const SizedBox(height: 32),
      Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: 380, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.t('admin.dashboard.users_by_role'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          ...users.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(e.key, style: TextStyle(color: CronosColors.gray600, fontSize: 13)),
            Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]))),
        ])))),
        SizedBox(width: 380, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.t('admin.dashboard.orders_by_status'), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const SizedBox(height: 12),
          ...orders.entries.map((e) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            StatusBadge(status: e.key),
            Text('${e.value}', style: const TextStyle(fontWeight: FontWeight.bold)),
          ]))),
        ])))),
      ]),
    ]);
  }
}
