import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/withdrawal.dart';
import '../../api/shipment_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminWithdrawalsScreen extends StatefulWidget {
  const AdminWithdrawalsScreen({super.key});
  @override
  State<AdminWithdrawalsScreen> createState() => _State();
}

class _State extends State<AdminWithdrawalsScreen> {
  List<Withdrawal> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await WithdrawalApi.getAll(); _items = ((res.data['data'] ?? []) as List).map((e) => Withdrawal.fromJson(e)).toList(); } catch (_) { _error = 'admin.withdrawals.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  void _showReviewModal(Withdrawal w) {
    final loc = context.read<AppLocalizations>();
    final notesCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('admin.withdrawals.modal_title'), child: Column(mainAxisSize: MainAxisSize.min, children: [
      _InfoRow('admin.withdrawals.lbl_user', w.user?.name ?? '-', loc),
      _InfoRow('admin.withdrawals.lbl_amount', 'Rp ${w.amount.toStringAsFixed(0)}', loc),
      _InfoRow('admin.withdrawals.lbl_bank', '${w.bankName} - ${w.accountNumber}', loc),
      const SizedBox(height: 12),
      TextField(controller: notesCtrl, decoration: InputDecoration(labelText: loc.t('admin.withdrawals.lbl_notes')), maxLines: 3),
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: OutlinedButton(onPressed: () async {
          try { await WithdrawalApi.update(w.id, {'status': 'rejected', 'admin_notes': notesCtrl.text});
            if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('Ditolak'), type: ToastificationType.info, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
          } catch (_) {}
        }, style: OutlinedButton.styleFrom(foregroundColor: Colors.red), child: Text(loc.t('admin.withdrawals.btn_reject')))),
        const SizedBox(width: 12),
        Expanded(child: ElevatedButton(onPressed: () async {
          try { await WithdrawalApi.update(w.id, {'status': 'approved', 'admin_notes': notesCtrl.text});
            if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('Disetujui'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
          } catch (_) {}
        }, child: Text(loc.t('admin.withdrawals.btn_approve')))),
      ]),
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('admin.withdrawals.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('admin.withdrawals.empty_title'))
      else Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: ['admin.withdrawals.col_user', 'admin.withdrawals.col_amount', 'admin.withdrawals.col_bank', 'admin.withdrawals.col_status', 'admin.withdrawals.col_actions']
          .map((c) => DataColumn(label: Text(loc.t(c), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _items.map((w) => DataRow(cells: [
          DataCell(Text(w.user?.name ?? '-')),
          DataCell(Text('Rp ${w.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500))),
          DataCell(Text('${w.bankName} - ${w.accountNumber}', style: TextStyle(fontSize: 12, color: CronosColors.gray500))),
          DataCell(StatusBadge(status: w.status)),
          DataCell(w.status == 'pending' ? ElevatedButton(onPressed: () => _showReviewModal(w),
            child: Text(loc.t('admin.withdrawals.btn_review'), style: const TextStyle(fontSize: 12))) : const SizedBox.shrink()),
        ])).toList(),
      ))),
    ]);
  }
}

class _InfoRow extends StatelessWidget {
  final String labelKey; final String value; final AppLocalizations loc;
  const _InfoRow(this.labelKey, this.value, this.loc);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    Text(loc.t(labelKey), style: TextStyle(color: CronosColors.gray500, fontSize: 13)), const SizedBox(width: 8),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
  ]));
}
