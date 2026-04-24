import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../config/theme.dart';
import '../config/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../widgets/global_nav.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _showPassword = false;
  bool _loading = false;
  String _error = '';

  Future<void> _handleSubmit() async {
    setState(() { _loading = true; _error = ''; });
    try {
      final auth = context.read<AuthProvider>();
      await auth.register({'name': _nameCtrl.text, 'email': _emailCtrl.text, 'password': _passCtrl.text, 'phone': _phoneCtrl.text, 'role': 'konsumen'});
      if (mounted) {
        toastification.show(context: context, title: Text(context.read<AppLocalizations>().t('auth.create_account')), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 3));
        context.go('/konsumen');
      }
    } catch (e) {
      final msg = _extractError(e);
      setState(() => _error = msg);
      if (mounted) toastification.show(context: context, title: Text(msg), type: ToastificationType.error, autoCloseDuration: const Duration(seconds: 3));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _extractError(dynamic e) {
    try { return e.response?.data?['message'] ?? 'Terjadi kesalahan'; } catch (_) { return 'Terjadi kesalahan'; }
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/'),
                      child: Container(width: 48, height: 48, decoration: BoxDecoration(gradient: CronosColors.logoBadge, borderRadius: BorderRadius.circular(14)),
                        child: const Center(child: Text('C', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))),
                    ),
                    const SizedBox(height: 24),
                    Text(loc.t('auth.create_account'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(loc.t('auth.join_sub'), style: TextStyle(color: CronosColors.gray500, fontSize: 14)),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_error.isNotEmpty)
                              Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.only(bottom: 16), decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                                child: Text(_error, style: TextStyle(color: Colors.red.shade600, fontSize: 13))),
                            Text(loc.t('auth.full_name'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(controller: _nameCtrl, decoration: const InputDecoration(prefixIcon: Icon(Icons.person_outline, size: 20), hintText: 'Eddie Vedder')),
                            const SizedBox(height: 16),
                            Text(loc.t('auth.email'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(controller: _emailCtrl, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(prefixIcon: Icon(Icons.email_outlined, size: 20), hintText: 'eddievedder@pearljam.com')),
                            const SizedBox(height: 16),
                            Text(loc.t('auth.phone'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(controller: _phoneCtrl, keyboardType: TextInputType.phone, decoration: const InputDecoration(prefixIcon: Icon(Icons.phone_outlined, size: 20), hintText: '000000000000')),
                            const SizedBox(height: 16),
                            Text(loc.t('auth.password'), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            const SizedBox(height: 6),
                            TextField(controller: _passCtrl, obscureText: !_showPassword, decoration: InputDecoration(prefixIcon: const Icon(Icons.lock_outline, size: 20), hintText: 'Min 6 karakter',
                              suffixIcon: IconButton(icon: Icon(_showPassword ? Icons.visibility_off : Icons.visibility, size: 20), onPressed: () => setState(() => _showPassword = !_showPassword)))),
                            const SizedBox(height: 24),
                            ElevatedButton(onPressed: _loading ? null : _handleSubmit, style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text(_loading ? loc.t('auth.creating_account') : loc.t('auth.btn_register'))),
                            const SizedBox(height: 20),
                            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('${loc.t('auth.has_account')} ', style: TextStyle(color: CronosColors.gray500, fontSize: 13)),
                              GestureDetector(onTap: () => context.go('/login'), child: Text(loc.t('nav.login'), style: const TextStyle(color: CronosColors.primary600, fontWeight: FontWeight.w600, fontSize: 13))),
                            ]),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const GlobalNav(),
        ],
      ),
    );
  }
}
