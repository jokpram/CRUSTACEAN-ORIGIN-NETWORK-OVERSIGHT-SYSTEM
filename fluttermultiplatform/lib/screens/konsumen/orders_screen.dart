import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/order.dart';
import '../../api/order_api.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class KonsumenOrdersScreen extends StatefulWidget {
  const KonsumenOrdersScreen({super.key});
  @override
  State<KonsumenOrdersScreen> createState() => _State();
}

class _State extends State<KonsumenOrdersScreen> {
  List<Order> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await OrderApi.getMyOrders(); _items = ((res.data['data'] ?? []) as List).map((e) => Order.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('konsumen.orders.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else ..._items.map((o) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(o.id.length > 8 ? '${o.id.substring(0, 8)}...' : o.id, style: const TextStyle(fontFamily: 'monospace', fontSize: 13, fontWeight: FontWeight.w500)),
          StatusBadge(status: o.status),
        ]),
        const SizedBox(height: 8),
        if (o.items.isNotEmpty)
          ...o.items.map((item) => Padding(padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('${item.product?.name ?? "Produk"} x${item.quantity}', style: TextStyle(fontSize: 13, color: CronosColors.gray600)))),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('${loc.t('konsumen.orders.total')} Rp ${o.totalAmount.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: CronosColors.primary600)),
          Row(children: [
            if (o.status == 'pending' && o.paymentUrl != null)
              ElevatedButton(onPressed: () => _pay(o.paymentUrl!), child: Text(loc.t('konsumen.orders.btn_pay'), style: const TextStyle(fontSize: 12))),
            if (o.status == 'pending') ...[const SizedBox(width: 8),
              OutlinedButton(onPressed: () => _cancel(o.id, loc), style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                child: Text(loc.t('konsumen.orders.btn_cancel'), style: const TextStyle(fontSize: 12)))],
            if (o.status == 'delivered')
              ElevatedButton(onPressed: () => _showReviewModal(o, loc), style: ElevatedButton.styleFrom(backgroundColor: CronosColors.accent500),
                child: Text(loc.t('konsumen.orders.btn_review'), style: const TextStyle(fontSize: 12))),
          ]),
        ]),
      ])))),
    ]);
  }

  Future<void> _pay(String url) async { final uri = Uri.parse(url); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }

  Future<void> _cancel(String id, AppLocalizations loc) async {
    final confirm = await showConfirmDialog(context, title: loc.t('global.btn_confirm'), message: loc.t('konsumen.orders.cancel_confirm'));
    if (confirm != true) return;
    try {
      await OrderApi.cancel(id);
      if (mounted) {
        toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2));
      }
      _fetch();
    } catch (_) {}
  }

  void _showReviewModal(Order o, AppLocalizations loc) {
    int rating = 5; final commentCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('konsumen.orders.modal_review_title'), child: StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: List.generate(5, (i) => IconButton(
        icon: Icon(i < rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 32),
        onPressed: () => setS(() => rating = i + 1)))),
      const SizedBox(height: 12),
      TextField(controller: commentCtrl, decoration: InputDecoration(hintText: loc.t('konsumen.orders.modal_review_title')), maxLines: 3),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try {
          final productId = o.items.isNotEmpty ? o.items.first.product?.id : null;
          if (productId == null) return;
          await ReviewApi.create({'product_id': productId, 'rating': rating, 'comment': commentCtrl.text});
          if (ctx.mounted) { Navigator.pop(ctx); }
          if (mounted) { toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (_) {}
      }, child: Text(loc.t('konsumen.orders.btn_submit_review')))),
    ])));
  }
}
