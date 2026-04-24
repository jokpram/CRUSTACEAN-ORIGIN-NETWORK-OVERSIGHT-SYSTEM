import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../api/product_api.dart';
import '../api/traceability_api.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/global_nav.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  List<Review> _reviews = [];
  bool _loading = true;
  String _error = '';
  int _qty = 1;

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final results = await Future.wait([ProductApi.getProduct(widget.productId), ReviewApi.getByProduct(widget.productId)]);
      _product = Product.fromJson(results[0].data['data']);
      _reviews = ((results[1].data['data'] ?? []) as List).map((e) => Review.fromJson(e)).toList();
    } catch (_) { _error = 'product.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const Scaffold(body: LoadingSpinner());
    if (_error.isNotEmpty || _product == null) return Scaffold(body: ErrorState(message: loc.t(_error.isEmpty ? 'product.not_found' : _error)));
    final p = _product!;
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();
    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextButton.icon(onPressed: () => context.go('/marketplace'), icon: const Icon(Icons.arrow_back, size: 18), label: Text(loc.t('product.back_market'))),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final isWide = constraints.maxWidth > 700;
                    final imageWidget = Card(
                      clipBehavior: Clip.antiAlias,
                      child: Container(height: 320, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.ocean100, CronosColors.accent100])),
                        child: Center(child: Icon(Icons.set_meal_rounded, size: 80, color: CronosColors.primary500.withValues(alpha: 0.8)))),
                    );
                    final infoWidget = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(children: [
                        const Icon(Icons.star, size: 18, color: Colors.amber), const SizedBox(width: 4),
                        Text(p.ratingAvg.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.w500)),
                        Text(' (${p.ratingCount} ${loc.t('product.reviews').toLowerCase()})', style: TextStyle(color: CronosColors.gray400, fontSize: 13)),
                        const SizedBox(width: 12),
                        StatusBadge(status: p.isAvailable ? 'available' : 'unavailable'),
                      ]),
                      const SizedBox(height: 12),
                      Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: CronosColors.primary600)),
                      Text('${loc.t('product.per')} ${p.unit}', style: TextStyle(color: CronosColors.gray500, fontSize: 13)),
                      const SizedBox(height: 20),
                      _InfoRow(loc.t('product.type'), p.shrimpType),
                      _InfoRow(loc.t('product.size'), p.size),
                      _InfoRow(loc.t('product.stock'), '${p.stock} ${p.unit}'),
                      if (p.batch != null) _InfoRow(loc.t('product.batch'), p.batch!.batchCode),
                      if (p.user != null) _InfoRow(loc.t('product.farmer'), p.user!.name),
                      const SizedBox(height: 16),
                      Text(p.description, style: const TextStyle(color: CronosColors.gray600)),
                      if (auth.user?.role == 'konsumen' && p.isAvailable && p.stock > 0) ...[
                        const SizedBox(height: 24),
                        Row(children: [
                          Container(decoration: BoxDecoration(border: Border.all(color: CronosColors.gray300), borderRadius: BorderRadius.circular(12)),
                            child: Row(children: [
                              IconButton(onPressed: () => setState(() => _qty = (_qty - 1).clamp(1, p.stock)), icon: const Icon(Icons.remove, size: 18)),
                              Text('$_qty', style: const TextStyle(fontWeight: FontWeight.w500)),
                              IconButton(onPressed: () => setState(() => _qty = (_qty + 1).clamp(1, p.stock)), icon: const Icon(Icons.add, size: 18)),
                            ])),
                          const SizedBox(width: 16),
                          Expanded(child: ElevatedButton.icon(onPressed: () { cart.addItem(p, _qty); toastification.show(context: context, title: Text(loc.t('market.add_to_cart')), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); },
                            icon: const Icon(Icons.shopping_cart, size: 18), label: Text(loc.t('market.add_to_cart')))),
                        ]),
                      ],
                    ]);
                    if (isWide) return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: imageWidget), const SizedBox(width: 32), Expanded(child: infoWidget)]);
                    return Column(children: [imageWidget, const SizedBox(height: 24), infoWidget]);
                  },
                ),
                const SizedBox(height: 40),
                Text('${loc.t('product.reviews')} (${_reviews.length})', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (_reviews.isEmpty)
                  Card(child: Padding(padding: const EdgeInsets.all(32), child: Center(child: Text(loc.t('product.no_reviews'), style: const TextStyle(color: CronosColors.gray500)))))
                else
                  ..._reviews.map((r) => Card(
                    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        CircleAvatar(radius: 16, backgroundColor: CronosColors.primary50, child: Icon(Icons.person, size: 16, color: CronosColors.primary600)),
                        const SizedBox(width: 10),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.user?.name ?? 'User', style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
                          Row(children: List.generate(5, (i) => Icon(Icons.star, size: 14, color: i < r.rating ? Colors.amber : CronosColors.gray300))),
                        ]),
                      ]),
                      const SizedBox(height: 8),
                      Text(r.comment, style: TextStyle(color: CronosColors.gray600, fontSize: 13)),
                    ])),
                  )),
              ],
            ),
          ),
          const GlobalNav(),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label; final String value;
  const _InfoRow(this.label, this.value);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    Text(label, style: TextStyle(color: CronosColors.gray500, fontSize: 13)),
    Text(value, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
  ]));
}
