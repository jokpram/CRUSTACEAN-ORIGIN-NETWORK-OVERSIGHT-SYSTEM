import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/traceability_log.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminTraceabilityLogsScreen extends StatefulWidget {
  const AdminTraceabilityLogsScreen({super.key});
  @override
  State<AdminTraceabilityLogsScreen> createState() => _State();
}

class _State extends State<AdminTraceabilityLogsScreen> {
  List<TraceabilityLog> _logs = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await TraceabilityApi.getAll(); _logs = ((res.data['data'] ?? []) as List).map((e) => TraceabilityLog.fromJson(e)).toList(); } catch (_) { _error = 'admin.trace_logs.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _verifyChain() async {
    final loc = context.read<AppLocalizations>();
    try {
      final res = await TraceabilityApi.verifyChain();
      final valid = res.data['data']?['is_valid'] == true;
      if (mounted) {
        toastification.show(context: context, title: Text(valid ? loc.t('admin.trace_logs.msg_valid') : loc.t('admin.trace_logs.msg_invalid')),
          type: valid ? ToastificationType.success : ToastificationType.error, autoCloseDuration: const Duration(seconds: 3));
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('admin.trace_logs.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _verifyChain, icon: const Icon(Icons.verified_rounded, size: 18), label: Text(loc.t('admin.trace_logs.btn_verify'))),
      ]),
      const SizedBox(height: 24),
      if (_logs.isEmpty) EmptyState(title: loc.t('admin.trace_logs.empty_title'))
      else Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: ['admin.trace_logs.col_event', 'admin.trace_logs.col_actor', 'admin.trace_logs.col_entity', 'admin.trace_logs.col_hash', 'admin.trace_logs.col_time']
          .map((c) => DataColumn(label: Text(loc.t(c), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _logs.map((l) => DataRow(cells: [
          DataCell(Text(loc.t('trace.event.${l.eventType}'), style: const TextStyle(fontSize: 13))),
          DataCell(Text(l.actor?.name ?? '-', style: const TextStyle(fontSize: 13))),
          DataCell(Text(l.entityType, style: TextStyle(fontSize: 12, color: CronosColors.gray500))),
          DataCell(Text(l.currentHash.length > 12 ? '${l.currentHash.substring(0, 12)}...' : l.currentHash, style: const TextStyle(fontFamily: 'monospace', fontSize: 11))),
          DataCell(Text(_formatDate(l.timestamp), style: TextStyle(fontSize: 12, color: CronosColors.gray500))),
        ])).toList(),
      ))),
    ]);
  }
  String _formatDate(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 16); } catch (_) { return s; } }
}
