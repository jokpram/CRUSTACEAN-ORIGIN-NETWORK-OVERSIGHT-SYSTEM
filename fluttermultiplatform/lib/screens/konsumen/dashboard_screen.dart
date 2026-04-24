import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class KonsumenDashboardScreen extends StatefulWidget {
  const KonsumenDashboardScreen({super.key});
  @override
  State<KonsumenDashboardScreen> createState() => _State();
}

class _State extends State<KonsumenDashboardScreen> {
  Map<String, dynamic>? _data;
  List<dynamic> _recentOrders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try { final res = await DashboardApi.getKonsumen(); _data = res.data['data']; _recentOrders = _data?['recent_orders'] ?? []; } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('konsumen.dashboard.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      SizedBox(width: 240, child: StatCard(title: loc.t('konsumen.dashboard.total_orders'), value: '${_data?['total_orders'] ?? 0}', icon: Icons.shopping_bag_rounded, color: CronosColors.primary600)),
      const SizedBox(height: 32),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('konsumen.dashboard.recent_orders'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        TextButton(onPressed: () => context.go('/konsumen/orders'), child: Text(loc.t('konsumen.dashboard.view_all'))),
      ]),
      const SizedBox(height: 12),
      if (_recentOrders.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(loc.t('konsumen.dashboard.no_orders_yet'), style: TextStyle(color: CronosColors.gray500)),
          GestureDetector(onTap: () => context.go('/marketplace'), child: Text(loc.t('konsumen.dashboard.visit_marketplace'), style: const TextStyle(color: CronosColors.primary600, fontWeight: FontWeight.w600))),
        ]))))
      else ..._recentOrders.take(5).map((o) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('${(o['id'] ?? '').toString().substring(0, 8)}...', style: const TextStyle(fontFamily: 'monospace', fontSize: 13)),
        Text('Rp ${(o['total_amount'] ?? 0).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500)),
        StatusBadge(status: o['status'] ?? ''),
      ])))),
    ]);
  }
}
