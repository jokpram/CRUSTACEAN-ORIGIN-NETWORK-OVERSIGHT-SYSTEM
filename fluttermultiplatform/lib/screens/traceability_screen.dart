import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../models/traceability_log.dart';
import '../models/batch.dart';
import '../api/traceability_api.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/global_nav.dart';

class TraceabilityScreen extends StatefulWidget {
  final String? batchCode;
  const TraceabilityScreen({super.key, this.batchCode});
  @override
  State<TraceabilityScreen> createState() => _TraceabilityScreenState();
}

class _TraceabilityScreenState extends State<TraceabilityScreen> {
  final _codeCtrl = TextEditingController();
  List<TraceabilityLog> _logs = [];
  Batch? _batch;
  bool _loading = false;
  String _error = '';
  bool _searched = false;

  @override
  void initState() {
    super.initState();
    if (widget.batchCode != null) { _codeCtrl.text = widget.batchCode!; _search(widget.batchCode!); }
  }

  Future<void> _search([String? code]) async {
    final c = code ?? _codeCtrl.text.trim();
    if (c.isEmpty) return;
    setState(() { _loading = true; _error = ''; _searched = true; });
    try {
      final res = await TraceabilityApi.getByBatchCode(c);
      final data = res.data['data'];
      _logs = ((data?['logs'] ?? []) as List).map((e) => TraceabilityLog.fromJson(e)).toList();
      _batch = data?['batch'] != null ? Batch.fromJson(data['batch']) : null;
    } catch (_) { _error = 'trace.err_not_found'; _logs = []; _batch = null; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    TextButton.icon(onPressed: () => context.go('/'), icon: const Icon(Icons.arrow_back, size: 18), label: Text(loc.t('nav.back_to_home'))),
                    const SizedBox(height: 24),
                    Text(loc.t('trace.title'), style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text(loc.t('trace.subtitle'), style: TextStyle(color: CronosColors.gray500), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(loc.t('trace.lbl_enter_batch'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextField(controller: _codeCtrl, onSubmitted: (_) => _search(), decoration: const InputDecoration(prefixIcon: Icon(Icons.search, size: 20), hintText: 'CRN-VNM-2026-000001'))),
                        const SizedBox(width: 12),
                        ElevatedButton(onPressed: () => _search(), child: Text(loc.t('trace.btn_trace'))),
                      ]),
                    ]))),
                    const SizedBox(height: 24),
                    if (_loading) LoadingSpinner(message: loc.t('trace.msg_tracing')),
                    if (_error.isNotEmpty) ErrorState(message: loc.t(_error)),
                    if (!_loading && _error.isEmpty && _searched && _batch != null)
                      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(loc.t('trace.info_title'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 12),
                        _InfoRow(loc.t('trace.lbl_batch'), _batch!.batchCode),
                        _InfoRow(loc.t('trace.lbl_qty'), '${_batch!.quantity} kg'),
                      ]))),
                    if (!_loading && _error.isEmpty && _searched && _logs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Align(alignment: Alignment.centerLeft, child: Text(loc.t('trace.timeline_title'), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 16),
                      ...List.generate(_logs.length, (i) {
                        final log = _logs[i];
                        final isLast = i == _logs.length - 1;
                        return IntrinsicHeight(child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Column(children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: CronosColors.primary500, borderRadius: BorderRadius.circular(18)),
                              child: Icon(isLast ? Icons.check_circle : Icons.access_time, color: Colors.white, size: 18)),
                            if (!isLast) Expanded(child: Container(width: 2, color: CronosColors.gray200)),
                          ]),
                          const SizedBox(width: 16),
                          Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(loc.t('trace.event.${log.eventType}'), style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                              Text(_formatDate(log.timestamp), style: TextStyle(fontSize: 11, color: CronosColors.gray400)),
                            ]),
                            const SizedBox(height: 4),
                            Text('${loc.t('trace.lbl_hash')} ${log.currentHash.length > 16 ? log.currentHash.substring(0, 16) : log.currentHash}...', style: TextStyle(fontSize: 11, color: CronosColors.gray500)),
                            if (log.actor != null) Text('${loc.t('trace.lbl_by')} ${log.actor!.name}', style: TextStyle(fontSize: 11, color: CronosColors.gray500)),
                          ])))),
                        ]));
                      }),
                    ],
                    if (!_loading && _error.isEmpty && _searched && _logs.isEmpty && _batch == null)
                      EmptyState(title: loc.t('trace.empty_title'), message: loc.t('trace.empty_desc')),
                  ],
                ),
              ),
            ),
          ),
          const GlobalNav(),
        ],
      ),
    );
  }

  String _formatDate(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 16); } catch (_) { return s; } }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [
    Text(label, style: TextStyle(color: CronosColors.gray500, fontSize: 13)), const SizedBox(width: 8),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
  ]));
}
