import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/global_nav.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final loc = context.watch<AppLocalizations>();
    final features = [
      {'icon': Icons.security_rounded, 'titleKey': 'landing.feat1_title', 'descKey': 'landing.feat1_desc'},
      {'icon': Icons.search_rounded, 'titleKey': 'landing.feat2_title', 'descKey': 'landing.feat2_desc'},
      {'icon': Icons.local_shipping_rounded, 'titleKey': 'landing.feat3_title', 'descKey': 'landing.feat3_desc'},
      {'icon': Icons.payments_rounded, 'titleKey': 'landing.feat4_title', 'descKey': 'landing.feat4_desc'},
      {'icon': Icons.storage_rounded, 'titleKey': 'landing.feat5_title', 'descKey': 'landing.feat5_desc'},
      {'icon': Icons.people_rounded, 'titleKey': 'landing.feat6_title', 'descKey': 'landing.feat6_desc'},
    ];

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Navbar
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.white.withValues(alpha: 0.9),
                surfaceTintColor: Colors.transparent,
                title: GestureDetector(
                  onTap: () => context.go('/'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(gradient: CronosColors.logoBadge, borderRadius: BorderRadius.circular(10)),
                        child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))),
                      ),
                      const SizedBox(width: 10),
                      const Text('CRONOS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: CronosColors.gray900)),
                    ],
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => context.go('/marketplace'), child: Text(loc.t('nav.marketplace'))),
                  TextButton(onPressed: () => context.go('/traceability'), child: Text(loc.t('nav.traceability'))),
                  const SizedBox(width: 8),
                  if (auth.isAuthenticated)
                    ElevatedButton(onPressed: () => context.go(auth.dashboardRoute), child: Text(loc.t('nav.dashboard')))
                  else ...[
                    OutlinedButton(onPressed: () => context.go('/login'), child: Text(loc.t('nav.login'))),
                    const SizedBox(width: 8),
                    ElevatedButton(onPressed: () => context.go('/register'), child: Text(loc.t('nav.register'))),
                  ],
                  const SizedBox(width: 16),
                ],
              ),
              // Hero
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(gradient: CronosColors.heroGradient),
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(24)),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [const Icon(Icons.hexagon_outlined, color: Colors.white, size: 16), const SizedBox(width: 8), Text(loc.t('landing.badge'), style: const TextStyle(color: Colors.white, fontSize: 13))],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text('${loc.t('landing.title1')}\n${loc.t('landing.title2')}\n${loc.t('landing.title3')}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, color: Colors.white, height: 1.2)),
                      const SizedBox(height: 16),
                      Text(loc.t('landing.subtitle'), textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white.withValues(alpha: 0.85), height: 1.5)),
                      const SizedBox(height: 40),
                      Wrap(
                        spacing: 16, runSpacing: 12, alignment: WrapAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: () => context.go('/marketplace'),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: CronosColors.gray900, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)),
                            child: Text(loc.t('landing.btn_browse'), style: const TextStyle(fontWeight: FontWeight.bold)),
                          ),
                          OutlinedButton(
                            onPressed: () => context.go('/traceability'),
                            style: OutlinedButton.styleFrom(foregroundColor: Colors.white, side: BorderSide(color: Colors.white.withValues(alpha: 0.3), width: 2), padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18)),
                            child: Text(loc.t('landing.btn_trace')),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Features
              SliverToBoxAdapter(
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Column(
                    children: [
                      Text(loc.t('landing.why_title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(loc.t('landing.why_subtitle'), style: TextStyle(color: CronosColors.gray500), textAlign: TextAlign.center),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 24, runSpacing: 24,
                        children: features.map((f) => SizedBox(
                          width: 340,
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(28),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(width: 52, height: 52, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.primary50, CronosColors.accent100]), borderRadius: BorderRadius.circular(14)),
                                    child: Icon(f['icon'] as IconData, color: CronosColors.primary600, size: 24)),
                                  const SizedBox(height: 16),
                                  Text(loc.t(f['titleKey'] as String), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 8),
                                  Text(loc.t(f['descKey'] as String), style: TextStyle(fontSize: 13, color: CronosColors.gray500, height: 1.5)),
                                ],
                              ),
                            ),
                          ),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
              // How it works
              SliverToBoxAdapter(
                child: Container(
                  color: CronosColors.gray50,
                  padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
                  child: Column(
                    children: [
                      Text(loc.t('landing.how_title'), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 48),
                      Wrap(
                        spacing: 32, runSpacing: 32, alignment: WrapAlignment.center,
                        children: [
                          _StepWidget(icon: Icons.storage_rounded, label: loc.t('landing.step1')),
                          _StepWidget(icon: Icons.inventory_2_rounded, label: loc.t('landing.step2')),
                          _StepWidget(icon: Icons.shopping_cart_rounded, label: loc.t('landing.step3')),
                          _StepWidget(icon: Icons.local_shipping_rounded, label: loc.t('landing.step4')),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Footer
              SliverToBoxAdapter(
                child: Container(
                  color: CronosColors.gray900,
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Text(loc.t('landing.footer'), textAlign: TextAlign.center, style: TextStyle(color: CronosColors.gray400, fontSize: 13)),
                ),
              ),
            ],
          ),
          // GlobalNav floating widget
          const GlobalNav(),
        ],
      ),
    );
  }
}

class _StepWidget extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StepWidget({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Column(
        children: [
          Container(width: 60, height: 60, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.primary500, CronosColors.ocean500]), borderRadius: BorderRadius.circular(30)),
            child: Icon(icon, color: Colors.white, size: 28)),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: CronosColors.gray800), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
