import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/order.dart';
import '../../api/order_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});
  @override
  State<AdminOrdersScreen> createState() => _State();
}

class _State extends State<AdminOrdersScreen> {
  List<Order> _orders = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await OrderApi.getAll(); _orders = ((res.data['data'] ?? []) as List).map((e) => Order.fromJson(e)).toList(); } catch (_) { _error = 'admin.orders.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('admin.orders.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_orders.isEmpty) EmptyState(title: loc.t('admin.orders.empty_title'))
      else Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: [loc.t('admin.orders.col_id'), loc.t('admin.orders.col_customer'), loc.t('admin.orders.col_amount'), loc.t('admin.orders.col_status'), loc.t('admin.orders.col_date')]
          .map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _orders.map((o) => DataRow(cells: [
          DataCell(Text(o.id.length > 8 ? '${o.id.substring(0, 8)}...' : o.id, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          DataCell(Text(o.user?.name ?? '-', style: const TextStyle(fontSize: 13))),
          DataCell(Text('Rp ${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13))),
          DataCell(StatusBadge(status: o.status)),
          DataCell(Text(_formatDate(o.createdAt), style: TextStyle(fontSize: 12, color: CronosColors.gray500))),
        ])).toList(),
      ))),
    ]);
  }
  String _formatDate(String s) { try { return DateTime.parse(s).toLocal().toString().substring(0, 10); } catch (_) { return s; } }
}
