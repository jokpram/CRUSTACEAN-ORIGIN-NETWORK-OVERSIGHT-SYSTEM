import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/cultivation_cycle.dart';
import '../../api/farm_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakCultivationScreen extends StatefulWidget {
  const PetambakCultivationScreen({super.key});
  @override
  State<PetambakCultivationScreen> createState() => _State();
}

class _State extends State<PetambakCultivationScreen> {
  List<CultivationCycle> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await CultivationApi.getMyCycles(); _items = ((res.data['data'] ?? []) as List).map((e) => CultivationCycle.fromJson(e)).toList(); } catch (_) { _error = 'petambak.cultivation.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('petambak.cultivation.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('petambak.cultivation.empty_title'), message: loc.t('petambak.cultivation.empty_desc'))
      else ..._items.map((c) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${c.pond?.name ?? '-'} - ${c.shrimpType?.name ?? '-'}', style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text('${loc.t('petambak.cultivation.density')} ${c.density} ${loc.t('petambak.cultivation.pct')} • ${loc.t('petambak.cultivation.started')} ${_formatDate(c.startDate)}', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
        ]),
        StatusBadge(status: c.status),
      ])))),
    ]);
  }
  String _formatDate(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 10); } catch (_) { return s; } }
}
