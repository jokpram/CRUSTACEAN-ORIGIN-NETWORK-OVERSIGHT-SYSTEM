import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/product.dart';
import '../../api/product_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakProductsScreen extends StatefulWidget {
  const PetambakProductsScreen({super.key});
  @override
  State<PetambakProductsScreen> createState() => _State();
}

class _State extends State<PetambakProductsScreen> {
  List<Product> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await ProductApi.getMyProducts(); _items = ((res.data['data'] ?? []) as List).map((e) => Product.fromJson(e)).toList(); } catch (_) { _error = 'err'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t('global.error_state'), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('petambak.products.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showCreateModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('petambak.products.btn_add'))),
      ]),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('global.empty_state_title'), message: loc.t('global.empty_state_msg'))
      else Wrap(spacing: 16, runSpacing: 16, children: _items.map((p) => SizedBox(width: 300, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(height: 100, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.ocean100, CronosColors.accent100]), borderRadius: BorderRadius.circular(12)),
          child: Center(child: Icon(Icons.set_meal_rounded, size: 40, color: CronosColors.primary500.withValues(alpha: 0.8)))),
        const SizedBox(height: 12),
        Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('${p.shrimpType} • ${p.size}', style: TextStyle(fontSize: 12, color: CronosColors.gray500)),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.bold, color: CronosColors.primary600)),
          Text('${p.stock} ${p.unit}', style: TextStyle(fontSize: 12, color: CronosColors.gray400)),
        ]),
      ]))))).toList()),
    ]);
  }

  void _showCreateModal() {
    final loc = context.read<AppLocalizations>();
    final nameCtrl = TextEditingController(), descCtrl = TextEditingController(), priceCtrl = TextEditingController(), stockCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('petambak.products.btn_add'), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Nama Produk')),
      const SizedBox(height: 12),
      TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Harga (Rp)')),
      const SizedBox(height: 12),
      TextField(controller: stockCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Stok')),
      const SizedBox(height: 12),
      TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Deskripsi'), maxLines: 3),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try { await ProductApi.create({'name': nameCtrl.text, 'price': double.tryParse(priceCtrl.text) ?? 0, 'stock': int.tryParse(stockCtrl.text) ?? 0, 'description': descCtrl.text});
          if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (_) {}
      }, child: Text(loc.t('petambak.products.btn_create')))),
    ]));
  }
}
