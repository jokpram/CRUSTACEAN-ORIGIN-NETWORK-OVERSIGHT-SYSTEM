import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class LogistikDashboardScreen extends StatefulWidget {
  const LogistikDashboardScreen({super.key});
  @override
  State<LogistikDashboardScreen> createState() => _State();
}

class _State extends State<LogistikDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try { final res = await DashboardApi.getLogistik(); _data = res.data['data']; } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('logistik.dashboard.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: 220, child: StatCard(title: loc.t('logistik.dashboard.total_shipments'), value: '${_data?['total_shipments'] ?? 0}', icon: Icons.local_shipping_rounded, color: CronosColors.primary600)),
        SizedBox(width: 220, child: StatCard(title: loc.t('logistik.dashboard.pending'), value: '${_data?['pending'] ?? 0}', icon: Icons.schedule_rounded, color: Colors.orange)),
        SizedBox(width: 220, child: StatCard(title: loc.t('logistik.dashboard.in_transit'), value: '${_data?['in_transit'] ?? 0}', icon: Icons.directions_car_rounded, color: CronosColors.accent500)),
        SizedBox(width: 220, child: StatCard(title: loc.t('logistik.dashboard.delivered'), value: '${_data?['delivered'] ?? 0}', icon: Icons.check_circle_rounded, color: Colors.green)),
      ]),
    ]);
  }
}
