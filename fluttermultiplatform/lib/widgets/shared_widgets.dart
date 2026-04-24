import 'package:flutter/material.dart';
import '../config/theme.dart';

class LoadingSpinner extends StatelessWidget {
  final String? message;
  const LoadingSpinner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40, height: 40,
              child: CircularProgressIndicator(
                color: CronosColors.primary600,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(message ?? 'Memuat...', style: TextStyle(color: CronosColors.gray500, fontSize: 14)),
          ],
        ),
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String? title;
  final String? message;
  const EmptyState({super.key, this.title, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: CronosColors.gray100, borderRadius: BorderRadius.circular(32)),
              child: const Icon(Icons.inbox_rounded, size: 32, color: CronosColors.gray400),
            ),
            const SizedBox(height: 16),
            Text(title ?? 'Tidak ada data', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: CronosColors.gray700)),
            const SizedBox(height: 8),
            Text(message ?? 'Belum ada data yang tersedia.', style: const TextStyle(fontSize: 14, color: CronosColors.gray500), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  const ErrorState({super.key, this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(32)),
              child: Icon(Icons.warning_amber_rounded, size: 32, color: Colors.red.shade500),
            ),
            const SizedBox(height: 16),
            Text('Error', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.red.shade700)),
            const SizedBox(height: 8),
            Text(message ?? 'Terjadi kesalahan.', style: const TextStyle(fontSize: 14, color: CronosColors.gray500), textAlign: TextAlign.center),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(onPressed: onRetry, child: const Text('Coba Lagi')),
            ],
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({super.key, required this.title, required this.value, required this.icon, this.color = CronosColors.primary600});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, color: CronosColors.gray500)),
                  const SizedBox(height: 4),
                  Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: CronosColors.gray900), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.8)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
          ],
        ),
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final config = <String, Color>{
      'active': Colors.green, 'pending': Colors.orange, 'paid': Colors.green, 'processing': Colors.blue,
      'shipped': Colors.blue, 'delivered': Colors.green, 'completed': Colors.green, 'cancelled': Colors.red,
      'failed': Colors.red, 'expired': Colors.red, 'approved': Colors.green, 'rejected': Colors.red,
      'pickup': Colors.blue, 'transit': Colors.blue, 'available': Colors.green, 'verified': Colors.green,
      'unavailable': Colors.red,
    };
    final color = config[status] ?? CronosColors.gray500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.isNotEmpty ? status[0].toUpperCase() + status.substring(1) : '',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

class CronosModal extends StatelessWidget {
  final String title;
  final Widget child;
  final VoidCallback onClose;

  const CronosModal({super.key, required this.title, required this.child, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480, maxHeight: 600),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                  IconButton(onPressed: onClose, icon: const Icon(Icons.close, color: CronosColors.gray400)),
                ],
              ),
            ),
            const Divider(height: 1, color: CronosColors.gray100),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void showCronosModal(BuildContext context, {required String title, required Widget child}) {
  showDialog(
    context: context,
    builder: (ctx) => CronosModal(title: title, onClose: () => Navigator.pop(ctx), child: child),
  );
}

Future<bool?> showConfirmDialog(BuildContext context, {required String title, required String message}) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text(title),
      content: Text(message, style: const TextStyle(color: CronosColors.gray600)),
      actions: [
        OutlinedButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('Konfirmasi'),
        ),
      ],
    ),
  );
}
