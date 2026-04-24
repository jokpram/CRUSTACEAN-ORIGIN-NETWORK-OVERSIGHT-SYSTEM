import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/harvest.dart';
import '../../api/farm_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakHarvestsScreen extends StatefulWidget {
  const PetambakHarvestsScreen({super.key});
  @override
  State<PetambakHarvestsScreen> createState() => _State();
}

class _State extends State<PetambakHarvestsScreen> {
  List<Harvest> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await HarvestApi.getMyHarvests(); _items = ((res.data['data'] ?? []) as List).map((e) => Harvest.fromJson(e)).toList(); } catch (_) { _error = 'petambak.harvests.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('petambak.harvests.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('petambak.harvests.empty_title'))
      else ..._items.map((h) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${h.totalWeight} kg', style: const TextStyle(fontWeight: FontWeight.w600)),
          StatusBadge(status: h.qualityGrade),
        ]),
        const SizedBox(height: 4),
        Text('${loc.t('petambak.harvests.size')} ${h.shrimpSize} • ${loc.t('petambak.harvests.date')} ${_formatDate(h.harvestDate)}', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
      ])))),
    ]);
  }
  String _formatDate(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 10); } catch (_) { return s; } }
}
