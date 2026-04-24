import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../providers/cart_provider.dart';

class KonsumenCartScreen extends StatelessWidget {
  const KonsumenCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final loc = context.watch<AppLocalizations>();
    final items = cart.items;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${loc.t('konsumen.cart.title')} (${items.length} ${loc.t('konsumen.cart.items')})', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      if (items.isEmpty)
        Card(child: Padding(padding: const EdgeInsets.all(48), child: Center(child: Column(children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: CronosColors.gray300),
          const SizedBox(height: 16),
          Text(loc.t('konsumen.cart.empty_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Text(loc.t('konsumen.cart.empty_desc'), style: TextStyle(color: CronosColors.gray500)),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => context.go('/marketplace'), child: Text(loc.t('konsumen.cart.btn_go_market'))),
        ]))))
      else Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(flex: 3, child: Column(children: items.map((item) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
          Container(width: 72, height: 72, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.ocean100, CronosColors.accent100]), borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.set_meal_rounded, color: CronosColors.primary500, size: 28))),
          const SizedBox(width: 16),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            Text('Rp ${item.product.price.toStringAsFixed(0)} / ${item.product.unit}', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
          ])),
          Row(children: [
            IconButton(onPressed: () => cart.updateQuantity(item.product.id, item.quantity - 1), icon: const Icon(Icons.remove_circle_outline, size: 20)),
            Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.w500)),
            IconButton(onPressed: () => cart.updateQuantity(item.product.id, item.quantity + 1), icon: const Icon(Icons.add_circle_outline, size: 20)),
          ]),
          const SizedBox(width: 12),
          Text('Rp ${(item.product.price * item.quantity).toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          IconButton(onPressed: () => cart.removeItem(item.product.id), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20)),
        ])))).toList())),
        const SizedBox(width: 24),
        SizedBox(width: 320, child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(loc.t('konsumen.cart.summary_title'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.subtotal'), style: TextStyle(color: CronosColors.gray500)), Text('Rp ${cart.totalPrice.toStringAsFixed(0)}')]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.shipping'), style: TextStyle(color: CronosColors.gray500)), Text(loc.t('konsumen.cart.calculated'), style: TextStyle(fontSize: 12, color: CronosColors.gray400))]),
          const Divider(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(loc.t('konsumen.cart.total'), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), Text('Rp ${cart.totalPrice.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: CronosColors.primary600))]),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () => context.go('/konsumen/checkout'), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: Text(loc.t('konsumen.cart.btn_checkout')))),
        ])))),
      ]),
    ]);
  }
}
