import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/shrimp_type.dart';
import '../../api/traceability_api.dart';
import '../../widgets/shared_widgets.dart';

class AdminShrimpTypesScreen extends StatefulWidget {
  const AdminShrimpTypesScreen({super.key});
  @override
  State<AdminShrimpTypesScreen> createState() => _State();
}

class _State extends State<AdminShrimpTypesScreen> {
  List<ShrimpType> _items = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await ShrimpTypeApi.getAll(); _items = ((res.data['data'] ?? []) as List).map((e) => ShrimpType.fromJson(e)).toList(); } catch (_) { _error = 'admin.shrimp_types.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('admin.shrimp_types.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showCreateModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('admin.shrimp_types.btn_add'))),
      ]),
      const SizedBox(height: 24),
      if (_items.isEmpty) EmptyState(title: loc.t('admin.shrimp_types.empty_title'), message: loc.t('admin.shrimp_types.empty_desc'))
      else Wrap(spacing: 16, runSpacing: 16, children: _items.map((s) => SizedBox(width: 300, child: Card(child: Padding(padding: const EdgeInsets.all(20), child: Row(children: [
        Container(width: 44, height: 44, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.ocean100, CronosColors.accent100]), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.water_drop, color: CronosColors.ocean600, size: 22)),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          if (s.description.isNotEmpty) Text(s.description, style: TextStyle(fontSize: 12, color: CronosColors.gray500), maxLines: 2),
        ])),
        IconButton(onPressed: () => _delete(s.id, loc), icon: Icon(Icons.delete_outline, color: Colors.red.shade400, size: 20)),
      ]))))).toList()),
    ]);
  }

  Future<void> _delete(String id, AppLocalizations loc) async {
    try {
      await ShrimpTypeApi.delete(id);
      if (mounted) {
        toastification.show(context: context, title: Text(loc.t('admin.shrimp_types.btn_delete')), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2));
      }
      _fetch();
    } catch (_) {}
  }

  void _showCreateModal() {
    final loc = context.read<AppLocalizations>();
    final nameCtrl = TextEditingController(), descCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('admin.shrimp_types.modal_title'), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nameCtrl, decoration: InputDecoration(labelText: loc.t('admin.users.col_name'))),
      const SizedBox(height: 12),
      TextField(controller: descCtrl, decoration: InputDecoration(labelText: loc.t('admin.shrimp_types.lbl_desc')), maxLines: 3),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try { await ShrimpTypeApi.create({'name': nameCtrl.text, 'description': descCtrl.text});
          if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (_) {}
      }, child: Text(loc.t('admin.shrimp_types.btn_add')))),
    ]));
  }
}
