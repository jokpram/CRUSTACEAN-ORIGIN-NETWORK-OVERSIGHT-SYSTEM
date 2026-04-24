import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/batch.dart';
import '../../api/farm_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakBatchesScreen extends StatefulWidget {
  const PetambakBatchesScreen({super.key});
  @override
  State<PetambakBatchesScreen> createState() => _State();
}

class _State extends State<PetambakBatchesScreen> {
  List<Batch> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await BatchApi.getMyBatches(); _items = ((res.data['data'] ?? []) as List).map((e) => Batch.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('petambak.batches.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else ..._items.map((b) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(b.batchCode, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
          const SizedBox(height: 4),
          Text('${b.quantity} kg • ${b.shrimpType?.name ?? "-"}', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
        ]),
        StatusBadge(status: b.status),
      ])))),
    ]);
  }
}
