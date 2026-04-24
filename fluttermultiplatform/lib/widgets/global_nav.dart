import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';

/// Floating bottom-right navigation widget mirroring React GlobalNav.tsx
/// Shows a language switcher globe + home button on non-home pages.
class GlobalNav extends StatefulWidget {
  const GlobalNav({super.key});
  @override
  State<GlobalNav> createState() => _GlobalNavState();
}

class _GlobalNavState extends State<GlobalNav> {
  bool _langOpen = false;

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    final currentPath = GoRouterState.of(context).uri.toString();
    final isHome = currentPath == '/';

    return Positioned(
      bottom: 24,
      right: 24,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Language popup
          if (_langOpen)
            Container(
              width: 192,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 24, offset: const Offset(0, 8))],
                border: Border.all(color: CronosColors.gray100),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Language', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CronosColors.gray400, letterSpacing: 1.5)),
                        InkWell(
                          onTap: () => setState(() => _langOpen = false),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(20)),
                            child: Icon(Icons.close, size: 14, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: CronosColors.gray100),
                  _LangButton(label: 'ID (Indonesia)', locale: 'id', current: loc.locale, onTap: () { loc.setLocale('id'); setState(() => _langOpen = false); }),
                  _LangButton(label: 'EN (English)', locale: 'en', current: loc.locale, onTap: () { loc.setLocale('en'); setState(() => _langOpen = false); }),
                  _LangButton(label: 'NL (Nederlands)', locale: 'nl', current: loc.locale, onTap: () { loc.setLocale('nl'); setState(() => _langOpen = false); }),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          // Language button
          _FloatingButton(
            icon: _langOpen ? Icons.close : Icons.language_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            iconColor: _langOpen ? CronosColors.gray600 : CronosColors.gray500,
            onTap: () => setState(() => _langOpen = !_langOpen),
            tooltip: 'Change Language',
          ),
          // Home button (only on non-home pages)
          if (!isHome) ...[
            const SizedBox(height: 12),
            _FloatingButton(
              icon: Icons.home_rounded,
              color: CronosColors.primary600,
              iconColor: Colors.white,
              onTap: () => context.go('/'),
              tooltip: loc.t('nav.back_to_home'),
              shadow: CronosColors.primary600.withValues(alpha: 0.3),
            ),
          ],
        ],
      ),
    );
  }
}

class _FloatingButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;
  final String tooltip;
  final Color? shadow;

  const _FloatingButton({required this.icon, required this.color, required this.iconColor, required this.onTap, required this.tooltip, this.shadow});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        elevation: 6,
        shadowColor: shadow ?? Colors.black.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
              border: shadow == null ? Border.all(color: CronosColors.gray200.withValues(alpha: 0.5)) : null,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
        ),
      ),
    );
  }
}

class _LangButton extends StatelessWidget {
  final String label;
  final String locale;
  final String current;
  final VoidCallback onTap;

  const _LangButton({required this.label, required this.locale, required this.current, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isActive = current == locale;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isActive ? CronosColors.primary50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: isActive ? CronosColors.primary600 : CronosColors.gray600)),
            ),
          ),
        ),
      ),
    );
  }
}
