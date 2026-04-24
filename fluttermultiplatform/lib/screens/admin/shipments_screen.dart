import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

import '../../config/app_localizations.dart';
import '../../models/shipment.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../api/shipment_api.dart';
import '../../api/order_api.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminShipmentsScreen extends StatefulWidget {
  const AdminShipmentsScreen({super.key});
  @override
  State<AdminShipmentsScreen> createState() => _State();
}

class _State extends State<AdminShipmentsScreen> {
  List<Shipment> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await ShipmentApi.getAll(); _items = ((res.data['data'] ?? []) as List).map((e) => Shipment.fromJson(e)).toList(); } catch (_) { _error = 'admin.shipments.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('admin.shipments.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showCreateModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('admin.shipments.btn_create'))),
      ]),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('admin.shipments.empty_title'))
      else Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: ['admin.shipments.col_order', 'admin.shipments.col_courier', 'admin.shipments.col_tracking', 'admin.shipments.col_status']
          .map((c) => DataColumn(label: Text(loc.t(c), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _items.map((s) => DataRow(cells: [
          DataCell(Text(s.orderId.length > 8 ? '${s.orderId.substring(0, 8)}...' : s.orderId, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          DataCell(Text(s.courier?.name ?? '-', style: const TextStyle(fontSize: 13))),
          DataCell(Text(s.trackingNumber, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))),
          DataCell(StatusBadge(status: s.status)),
        ])).toList(),
      ))),
    ]);
  }

  void _showCreateModal() {
    final loc = context.read<AppLocalizations>();
    List<Order> orders = [];
    List<User> couriers = [];
    String? selectedOrderId;
    String? selectedCourierId;
    final trackingCtrl = TextEditingController();
    Future.wait([OrderApi.getAll(), UserApi.getAll()]).then((results) {
      orders = ((results[0].data['data'] ?? []) as List).map((e) => Order.fromJson(e)).where((o) => o.status == 'paid').toList();
      couriers = ((results[1].data['data'] ?? []) as List).map((e) => User.fromJson(e)).where((u) => u.role == 'logistik').toList();
    });
    showCronosModal(context, title: loc.t('admin.shipments.modal_title'), child: StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      DropdownButtonFormField<String>(initialValue: selectedOrderId, decoration: InputDecoration(labelText: loc.t('admin.shipments.lbl_order')),
        items: orders.map((o) => DropdownMenuItem(value: o.id, child: Text('${o.id.substring(0, 8)}... (${o.user?.name ?? "-"})', style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (v) => setS(() => selectedOrderId = v)),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: selectedCourierId, decoration: InputDecoration(labelText: loc.t('admin.shipments.lbl_courier')),
        items: couriers.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, style: const TextStyle(fontSize: 13)))).toList(),
        onChanged: (v) => setS(() => selectedCourierId = v)),
      const SizedBox(height: 12),
      TextField(controller: trackingCtrl, decoration: InputDecoration(labelText: loc.t('admin.shipments.lbl_tracking'))),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        if (selectedOrderId == null || selectedCourierId == null) return;
        try { await ShipmentApi.create({'order_id': selectedOrderId, 'courier_id': selectedCourierId, 'tracking_number': trackingCtrl.text});
          if (ctx.mounted) { Navigator.pop(ctx); }
          if (mounted) { toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (_) {}
      }, child: Text(loc.t('admin.shipments.btn_create')))),
    ])));
  }
}
