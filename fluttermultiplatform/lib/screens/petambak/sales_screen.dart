import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/order.dart';
import '../../api/order_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakSalesScreen extends StatefulWidget {
  const PetambakSalesScreen({super.key});
  @override
  State<PetambakSalesScreen> createState() => _State();
}

class _State extends State<PetambakSalesScreen> {
  List<Order> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await OrderApi.getMySales(); _items = ((res.data['data'] ?? []) as List).map((e) => Order.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('petambak.sales.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: ['ID', loc.t('admin.orders.col_customer'), loc.t('admin.orders.col_amount'), loc.t('admin.orders.col_status'), loc.t('admin.orders.col_date')]
          .map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _items.map((o) => DataRow(cells: [
          DataCell(Text(o.id.length > 8 ? '${o.id.substring(0, 8)}...' : o.id, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          DataCell(Text(o.user?.name ?? '-', style: const TextStyle(fontSize: 13))),
          DataCell(Text('Rp ${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          DataCell(StatusBadge(status: o.status)),
          DataCell(Text(_fmt(o.createdAt), style: TextStyle(fontSize: 12, color: CronosColors.gray500))),
        ])).toList(),
      ))),
    ]);
  }
  String _fmt(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 10); } catch (_) { return s; } }
}
