import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/shipment.dart';
import '../../api/shipment_api.dart';
import '../../widgets/shared_widgets.dart';

class LogistikShipmentsScreen extends StatefulWidget {
  const LogistikShipmentsScreen({super.key});
  @override
  State<LogistikShipmentsScreen> createState() => _State();
}

class _State extends State<LogistikShipmentsScreen> {
  List<Shipment> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await ShipmentApi.getMine(); _items = ((res.data['data'] ?? []) as List).map((e) => Shipment.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  String? _nextStatus(String s) => const {'pending': 'picked_up', 'picked_up': 'in_transit', 'in_transit': 'delivered'}[s];

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('logistik.shipments.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else ..._items.map((s) {
        final next = _nextStatus(s.status);
        return Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s.trackingNumber, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace')),
            const SizedBox(height: 4),
            Row(children: [StatusBadge(status: s.status), const SizedBox(width: 8), Text('Order: ${s.orderId.length > 8 ? s.orderId.substring(0, 8) : s.orderId}...', style: TextStyle(fontSize: 12, color: CronosColors.gray500))]),
          ])),
          if (next != null) ElevatedButton(onPressed: () => _updateStatus(s.id, next, loc), child: Text('${loc.t('logistik.shipments.btn_update_to')} $next', style: const TextStyle(fontSize: 12))),
        ])));
      }),
    ]);
  }

  Future<void> _updateStatus(String id, String status, AppLocalizations loc) async {
    final confirm = await showConfirmDialog(context, title: loc.t('logistik.shipments.btn_confirm'), message: '${loc.t('logistik.shipments.btn_update_to')} $status?');
    if (confirm != true) return;
    try { await ShipmentApi.updateStatus(id, {'status': status});
      if (mounted) toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2));
      _fetch();
    } catch (_) {}
  }
}
