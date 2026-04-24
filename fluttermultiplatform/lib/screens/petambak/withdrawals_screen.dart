import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/withdrawal.dart';
import '../../api/shipment_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakWithdrawalsScreen extends StatefulWidget {
  const PetambakWithdrawalsScreen({super.key});
  @override
  State<PetambakWithdrawalsScreen> createState() => _State();
}

class _State extends State<PetambakWithdrawalsScreen> {
  List<Withdrawal> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await WithdrawalApi.getMine(); _items = ((res.data['data'] ?? []) as List).map((e) => Withdrawal.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('petambak.withdrawals.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showRequestModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('petambak.withdrawals.btn_request'))),
      ]),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else ..._items.map((w) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Rp ${w.amount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text('${w.bankName} - ${w.accountNumber}', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
        ]),
        StatusBadge(status: w.status),
      ])))),
    ]);
  }

  void _showRequestModal() {
    final loc = context.read<AppLocalizations>();
    final amtCtrl = TextEditingController(), bankCtrl = TextEditingController(), accCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('petambak.withdrawals.btn_request'), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: amtCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Jumlah (Rp)')),
      const SizedBox(height: 12),
      TextField(controller: bankCtrl, decoration: const InputDecoration(labelText: 'Nama Bank')),
      const SizedBox(height: 12),
      TextField(controller: accCtrl, decoration: const InputDecoration(labelText: 'Nomor Rekening')),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try { await WithdrawalApi.create({'amount': double.tryParse(amtCtrl.text) ?? 0, 'bank_name': bankCtrl.text, 'account_number': accCtrl.text});
          if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (_) {}
      }, child: Text(loc.t('petambak.withdrawals.btn_submit')))),
    ]));
  }
}
