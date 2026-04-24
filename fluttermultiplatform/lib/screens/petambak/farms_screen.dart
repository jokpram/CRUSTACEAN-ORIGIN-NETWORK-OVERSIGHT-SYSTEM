import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import '../../config/theme.dart';
import '../../config/app_localizations.dart';
import '../../models/farm.dart';
import '../../api/farm_api.dart';
import '../../widgets/shared_widgets.dart';

class PetambakFarmsScreen extends StatefulWidget {
  const PetambakFarmsScreen({super.key});
  @override
  State<PetambakFarmsScreen> createState() => _State();
}

class _State extends State<PetambakFarmsScreen> {
  List<Farm> _farms = [];
  bool _loading = true;
  String _error = '';

  @override
  void initState() { super.initState(); _fetch(); }
  Future<void> _fetch() async {
    setState(() { _loading = true; _error = ''; });
    try { final res = await FarmApi.getMyFarms(); _farms = ((res.data['data'] ?? []) as List).map((e) => Farm.fromJson(e)).toList(); } catch (_) { _error = 'petambak.farms.err_load'; }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final loc = context.watch<AppLocalizations>();
    if (_loading) return const LoadingSpinner();
    if (_error.isNotEmpty) return ErrorState(message: loc.t(_error), onRetry: _fetch);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(loc.t('petambak.farms.title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ElevatedButton.icon(onPressed: _showCreateModal, icon: const Icon(Icons.add, size: 18), label: Text(loc.t('petambak.farms.btn_add'))),
      ]),
      const SizedBox(height: 24),
      if (_farms.isEmpty) EmptyState(title: loc.t('petambak.farms.empty_title'), message: loc.t('petambak.farms.empty_desc'))
      else Wrap(spacing: 16, runSpacing: 16, children: _farms.map((f) => SizedBox(width: 340, child: Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: [CronosColors.accent100, CronosColors.ocean100]), borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.water, color: CronosColors.primary600, size: 24)),
        const SizedBox(height: 16),
        Text(f.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        const SizedBox(height: 4),
        Text(f.location, style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
        Text('${f.area} m²', style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
        const SizedBox(height: 8),
        Text('${f.ponds?.length ?? 0} ${loc.t('petambak.farms.ponds')}', style: TextStyle(fontSize: 12, color: CronosColors.gray400)),
      ]))))).toList()),
    ]);
  }

  void _showCreateModal() {
    final loc = context.read<AppLocalizations>();
    final nameCtrl = TextEditingController(), locCtrl = TextEditingController(), areaCtrl = TextEditingController(), descCtrl = TextEditingController();
    showCronosModal(context, title: loc.t('petambak.farms.modal_title'), child: Column(mainAxisSize: MainAxisSize.min, children: [
      TextField(controller: nameCtrl, decoration: InputDecoration(labelText: loc.t('petambak.farms.lbl_name'))),
      const SizedBox(height: 12),
      TextField(controller: locCtrl, decoration: InputDecoration(labelText: loc.t('petambak.farms.lbl_location'))),
      const SizedBox(height: 12),
      TextField(controller: areaCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: loc.t('petambak.farms.lbl_area'))),
      const SizedBox(height: 12),
      TextField(controller: descCtrl, decoration: InputDecoration(labelText: loc.t('petambak.farms.lbl_desc')), maxLines: 3),
      const SizedBox(height: 20),
      SizedBox(width: double.infinity, child: ElevatedButton(onPressed: () async {
        try { await FarmApi.create({'name': nameCtrl.text, 'location': locCtrl.text, 'area': double.tryParse(areaCtrl.text) ?? 0, 'description': descCtrl.text});
          if (mounted) { Navigator.pop(context); toastification.show(context: context, title: const Text('✓'), type: ToastificationType.success, autoCloseDuration: const Duration(seconds: 2)); } _fetch();
        } catch (e) { if (mounted) toastification.show(context: context, title: Text(loc.t('petambak.farms.err_load')), type: ToastificationType.error, autoCloseDuration: const Duration(seconds: 3)); }
      }, child: Text(loc.t('petambak.farms.btn_create')))),
    ]));
  }
}
