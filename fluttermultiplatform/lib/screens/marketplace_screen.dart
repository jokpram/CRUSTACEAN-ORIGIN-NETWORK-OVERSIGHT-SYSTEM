import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../models/product.dart';
import '../api/product_api.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/global_nav.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});
  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  List<Product> _products = [];
  bool _loading = true;
  String _error = '';
  String _search = '';
  String _shrimpType = '';
  String _sortBy = 'newest';

  @override
  void initState() { super.initState(); _fetch(); }

  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final params = <String, dynamic>{'sort': _sortBy};
      if (_search.isNotEmpty) params['search'] = _search;
      if (_shrimpType.isNotEmpty) params['shrimp_type'] = _shrimpType;
      final res = await ProductApi.getMarketplace(params: params);
      _products = ((res.data['data'] ?? []) as List).map((e) => Product.fromJson(e)).toList();
    } catch (_) { _error = 'market.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();
    final loc = context.watch<AppLocalizations>();
    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () => context.go('/'),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 32, height: 32, decoration: BoxDecoration(gradient: CronosColors.logoBadge, borderRadius: BorderRadius.circular(8)),
              child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))),
            const SizedBox(width: 8),
            const Text('CRONOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        ),
        actions: [
          TextButton(onPressed: () => context.go('/traceability'), child: Text(loc.t('nav.traceability'))),
          if (auth.isAuthenticated)
            ElevatedButton(onPressed: () => context.go(auth.dashboardRoute), child: Text(loc.t('nav.dashboard')))
          else
            ElevatedButton(onPressed: () => context.go('/login'), child: Text(loc.t('nav.login'))),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.t('market.title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(loc.t('market.subtitle'), style: TextStyle(color: CronosColors.gray500)),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Wrap(
                      spacing: 12, runSpacing: 12,
                      children: [
                        SizedBox(width: 280, child: TextField(
                          onChanged: (v) => _search = v,
                          onSubmitted: (_) => _fetch(),
                          decoration: InputDecoration(prefixIcon: const Icon(Icons.search, size: 20), hintText: loc.t('market.placeholder_search')),
                        )),
                        SizedBox(width: 160, child: DropdownButtonFormField<String>(
                          initialValue: _shrimpType.isEmpty ? null : _shrimpType,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                          hint: Text(loc.t('market.filter_all')),
                          items: [
                            DropdownMenuItem(value: '', child: Text(loc.t('market.filter_all'))),
                            const DropdownMenuItem(value: 'Vannamei', child: Text('Vannamei')),
                            const DropdownMenuItem(value: 'Tiger', child: Text('Tiger')),
                            const DropdownMenuItem(value: 'Galah', child: Text('Galah')),
                          ],
                          onChanged: (v) { _shrimpType = v ?? ''; _fetch(); },
                        )),
                        SizedBox(width: 200, child: DropdownButtonFormField<String>(
                          initialValue: _sortBy,
                          decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
                          items: [
                            DropdownMenuItem(value: 'newest', child: Text(loc.t('market.sort_newest'))),
                            DropdownMenuItem(value: 'price_asc', child: Text(loc.t('market.sort_price_asc'))),
                            DropdownMenuItem(value: 'price_desc', child: Text(loc.t('market.sort_price_desc'))),
                            DropdownMenuItem(value: 'rating', child: Text(loc.t('market.sort_rating'))),
                          ],
                          onChanged: (v) { _sortBy = v ?? 'newest'; _fetch(); },
                        )),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                if (_loading) Expanded(child: LoadingSpinner(message: loc.t('market.loading')))
                else if (_error.isNotEmpty) Expanded(child: ErrorState(message: loc.t(_error), onRetry: _fetch))
                else if (_products.isEmpty) Expanded(child: EmptyState(title: loc.t('market.empty_title'), message: loc.t('market.empty_desc')))
                else Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 320, childAspectRatio: 0.72, crossAxisSpacing: 16, mainAxisSpacing: 16),
                    itemCount: _products.length,
                    itemBuilder: (ctx, i) {
                      final p = _products[i];
                      return Card(
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(height: 130, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.ocean100, CronosColors.accent100])),
                              child: Center(child: Icon(Icons.set_meal_rounded, size: 48, color: CronosColors.primary500.withValues(alpha: 0.8)))),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () => context.go('/products/${p.id}'),
                                      child: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('${p.shrimpType} • ${p.size}', style: TextStyle(fontSize: 12, color: CronosColors.gray500)),
                                    const SizedBox(height: 6),
                                    Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4),
                                      Text('${p.ratingAvg.toStringAsFixed(1)} (${p.ratingCount})', style: TextStyle(fontSize: 12, color: CronosColors.gray600))]),
                                    const Spacer(),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('Rp ${p.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: CronosColors.primary600)),
                                      Text('${p.stock} ${p.unit}', style: TextStyle(fontSize: 12, color: CronosColors.gray400)),
                                    ]),
                                    if (auth.user?.role == 'konsumen') ...[
                                      const SizedBox(height: 10),
                                      SizedBox(width: double.infinity, child: ElevatedButton.icon(
                                        onPressed: () { cart.addItem(p); toastification.show(context: context, title: Text(loc.t('market.add_to_cart')), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); },
                                        icon: const Icon(Icons.shopping_cart_outlined, size: 16),
                                        label: Text(loc.t('market.add_to_cart'), style: const TextStyle(fontSize: 13)),
                                        style: ElevatedButton.styleFrom(backgroundColor: CronosColors.accent500, padding: const EdgeInsets.symmetric(vertical: 10)),
                                      )),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const GlobalNav(),
        ],
      ),
    );
  }
}
