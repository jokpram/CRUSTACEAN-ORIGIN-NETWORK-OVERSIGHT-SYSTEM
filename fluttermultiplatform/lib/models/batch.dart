import 'shrimp_type.dart';

class Batch {
  final String id;
  final String harvestId;
  final String batchCode;
  final double quantity;
  final String status;
  final ShrimpType? shrimpType;
  final String createdAt;

  Batch({required this.id, this.harvestId = '', this.batchCode = '', this.quantity = 0, this.status = '', this.shrimpType, this.createdAt = ''});

  factory Batch.fromJson(Map<String, dynamic> json) => Batch(
        id: json['id']?.toString() ?? '',
        harvestId: json['harvest_id']?.toString() ?? '',
        batchCode: json['batch_code'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        status: json['status'] ?? '',
        shrimpType: json['shrimp_type'] != null ? ShrimpType.fromJson(json['shrimp_type']) : null,
        createdAt: json['created_at'] ?? '',
      );
}
