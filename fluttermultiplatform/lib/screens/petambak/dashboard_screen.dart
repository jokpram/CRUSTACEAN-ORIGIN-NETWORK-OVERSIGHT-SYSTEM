import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakDashboardScreen extends StatefulWidget {
  const PetambakDashboardScreen({super.key});
  @override
  State<PetambakDashboardScreen> createState() => _State();
}

class _State extends State<PetambakDashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() => _loading = true);
    try { final res = await DashboardApi.getPetambak(); _data = res.data['data']; } catch (_) { _error = 'petambak.dashboard.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('petambak.dashboard.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Wrap(spacing: 16, runSpacing: 16, children: [
        SizedBox(width: 220, child: StatCard(title: loc.t('petambak.dashboard.farms'), value: '${_data?['total_farms'] ?? 0}', icon: Icons.map_rounded, color: CronosColors.primary600)),
        SizedBox(width: 220, child: StatCard(title: loc.t('petambak.dashboard.products'), value: '${_data?['total_products'] ?? 0}', icon: Icons.inventory_2_rounded, color: CronosColors.accent500)),
        SizedBox(width: 220, child: StatCard(title: loc.t('petambak.dashboard.cultivations'), value: '${_data?['total_cultivations'] ?? 0}', icon: Icons.water_drop_rounded, color: CronosColors.ocean500)),
        SizedBox(width: 220, child: StatCard(title: loc.t('petambak.dashboard.harvests'), value: '${_data?['total_harvests'] ?? 0}', icon: Icons.content_cut_rounded, color: Colors.orange)),
        SizedBox(width: 220, child: StatCard(title: loc.t('petambak.dashboard.revenue'), value: 'Rp ${((_data?['total_revenue'] ?? 0) as num).toStringAsFixed(0)}', icon: Icons.attach_money_rounded, color: Colors.purple)),
      ]),
    ]);
  }
}
