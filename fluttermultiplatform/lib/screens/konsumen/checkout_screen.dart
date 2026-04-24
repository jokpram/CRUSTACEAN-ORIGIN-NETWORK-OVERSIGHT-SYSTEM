import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../providers/cart_provider.dart';
import '../../api/order_api.dart';


class KonsumenCheckoutScreen extends StatefulWidget {
  const KonsumenCheckoutScreen({super.key});
  @override
  State<KonsumenCheckoutScreen> createState() => _State();
}

class _State extends State<KonsumenCheckoutScreen> {
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  Future<void> _placeOrder() async {
    final cart = context.read<CartProvider>();
    final loc = context.read<AppLocalizations>();
    if (cart.items.isEmpty) return;
    setState(() => _loading = true);
    try {
      final orderItems = cart.items.map((i) => {'product_id': i.product.id, 'quantity': i.quantity}).toList();
      final res = await OrderApi.create({'items': orderItems, 'shipping_address': _addressCtrl.text, 'notes': _notesCtrl.text});
      final payUrl = res.data['data']?['payment_url'];
      cart.clear();
      if (!mounted) return;
      toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2));
      if (payUrl != null) { final uri = Uri.parse(payUrl); if (await canLaunchUrl(uri)) await launchUrl(uri, mode: LaunchMode.externalApplication); }
      if (mounted) {
        context.go('/konsumen/orders');
      }
    } catch (e) {
      if (mounted) toastification.show(context: context, title: Text(loc.t('global.error_state')), type: ToastificationType.error, autoCloseDuration: const Duration(seconds: 3));
    } finally { if (mounted) setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = context.watch<AppLocalizations>();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(loc.t('konsumen.checkout.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: Column(children: [
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.t('konsumen.checkout.order_items'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            ...cart.items.map((i) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text('${i.product.name} x${i.quantity}', style: const TextStyle(fontSize: 14))),
              Text('Rp ${(i.product.price * i.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w500)),
            ]))),
            const Divider(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(loc.t('konsumen.checkout.total'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Rp ${cart.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CronosColors.primary600)),
            ]),
          ]))),
          const SizedBox(height: 16),
          Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.t('konsumen.checkout.shipping_info'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            TextField(controller: _addressCtrl, decoration: const InputDecoration(labelText: 'Alamat Pengiriman', prefixIcon: Icon(Icons.location_on_outlined, size: 20)), maxLines: 3),
            const SizedBox(height: 12),
            TextField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Catatan (opsional)', prefixIcon: Icon(Icons.notes, size: 20)), maxLines: 2),
          ]))),
        ])),
        const SizedBox(width: 24),
        SizedBox(width: 320, child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.subtotal'), style: TextStyle(color: CronosColors.gray500)), Text('Rp ${cart.totalPrice.toStringAsFixed(0)}')]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.shipping'), style: TextStyle(color: CronosColors.gray500)), Text(loc.t('konsumen.cart.calculated'), style: TextStyle(fontSize: 12, color: CronosColors.gray400))]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.total'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Rp ${cart.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CronosColors.primary600))]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _loading || cart.items.isEmpty ? null : _placeOrder,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(_loading ? loc.t('konsumen.checkout.btn_processing') : '${loc.t('konsumen.checkout.btn_place_order')}${cart.totalPrice.toStringAsFixed(0)}'))),
        ])))),
      ]),
    ]);
  }
}
