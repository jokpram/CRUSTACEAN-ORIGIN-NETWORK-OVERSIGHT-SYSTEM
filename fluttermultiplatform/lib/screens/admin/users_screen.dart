import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/user.dart';
import '../../api/traceability_api.dart';
import '../../api/auth_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});
  @override
  State<AdminUsersScreen> createState() => _State();
}

class _State extends State<AdminUsersScreen> {
  List<User> _users = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await UserApi.getAll(); _users = ((res.data['data'] ?? []) as List).map((e) => User.fromJson(e)).toList(); } catch (_) { _error = 'admin.users.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('admin.users.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showCreateModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('admin.users.create_new'))),
      ]),
      const SizedBox(height: 24),
      Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: DataTable(
        columns: [loc.t('admin.users.col_name'), loc.t('admin.users.col_email'), loc.t('admin.users.col_role'), loc.t('admin.users.col_status'), loc.t('admin.users.col_actions')]
          .map((c) => DataColumn(label: Text(c, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))).toList(),
        rows: _users.map((u) => DataRow(cells: [
          DataCell(Text(u.name, style: const TextStyle(fontSize: 13))),
          DataCell(Text(u.email, style: TextStyle(fontSize: 13, color: CronosColors.gray500))),
          DataCell(StatusBadge(status: u.role)),
          DataCell(StatusBadge(status: u.isVerified ? 'verified' : 'unverified')),
          DataCell(!u.isVerified ? ElevatedButton(onPressed: () => _verify(u.id), style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4)),
            child: Text(loc.t('admin.users.btn_verify'), style: const TextStyle(fontSize: 12))) : const SizedBox.shrink()),
        ])).toList(),
      ))),
    ]);
  }

  Future<void> _verify(String id) async {
    try { await UserApi.verify(id); _fetch(); } catch (_) {}
  }

  void _showCreateModal() {
    final loc = context.read<AppLocalizations>();
    final nameCtrl = TextEditingController(), emailCtrl = TextEditingController(), passCtrl = TextEditingController(), phoneCtrl = TextEditingController();
    String role = 'petambak';
    showCronosModal(context, title: loc.t('admin.users.create_new'), child: StatefulBuilder(builder: (ctx, setS) => Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nameCtrl, decoration: InputDecoration(labelText: loc.t('admin.users.col_name'))),
      const SizedBox(height: 12),
      TextField(controller: emailCtrl, decoration: InputDecoration(labelText: loc.t('admin.users.col_email'))),
      const SizedBox(height: 12),
      TextField(controller: passCtrl, obscureText: true, decoration: InputDecoration(labelText: loc.t('auth.password'))),
      const SizedBox(height: 12),
      TextField(controller: phoneCtrl, decoration: InputDecoration(labelText: loc.t('auth.phone'))),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: role, decoration: InputDecoration(labelText: loc.t('admin.users.col_role')),
        items: ['petambak', 'logistik', 'admin'].map((r) => DropdownMenuItem(value: r, child: Text(r[0].toUpperCase() + r.substring(1)))).toList(),
        onChanged: (v) => setS(() => role = v ?? 'petambak')),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try { await AuthApi.register({'name': nameCtrl.text, 'email': emailCtrl.text, 'password': passCtrl.text, 'phone': phoneCtrl.text, 'role': role});
          if (ctx.mounted) { Navigator.pop(ctx); }
          if (mounted) { toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (e) { if (ctx.mounted) toastification.show(context: ctx, title: Text(loc.t('admin.users.err_load')), type: ToastificationType.error, autoCloseDuration: const Duration(seconds: 3)); }
      }, child: Text(loc.t('admin.users.create_new')))),
    ])));
  }
}
