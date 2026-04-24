import 'pond.dart';
import 'shrimp_type.dart';

class CultivationCycle {
  final String id;
  final String pondId;
  final String shrimpTypeId;
  final String startDate;
  final String? expectedEndDate;
  final String? actualEndDate;
  final String status;
  final double density;
  final String notes;
  final Pond? pond;
  final ShrimpType? shrimpType;
  final String createdAt;

  CultivationCycle({required this.id, this.pondId = '', this.shrimpTypeId = '', this.startDate = '', this.expectedEndDate, this.actualEndDate, this.status = '', this.density = 0, this.notes = '', this.pond, this.shrimpType, this.createdAt = ''});

  factory CultivationCycle.fromJson(Map<String, dynamic> json) => CultivationCycle(
        id: json['id']?.toString() ?? '',
        pondId: json['pond_id']?.toString() ?? '',
        shrimpTypeId: json['shrimp_type_id']?.toString() ?? '',
        startDate: json['start_date'] ?? '',
        expectedEndDate: json['expected_end_date'],
        actualEndDate: json['actual_end_date'],
        status: json['status'] ?? '',
        density: (json['density'] ?? 0).toDouble(),
        notes: json['notes'] ?? '',
        pond: json['pond'] != null ? Pond.fromJson(json['pond']) : null,
        shrimpType: json['shrimp_type'] != null ? ShrimpType.fromJson(json['shrimp_type']) : null,
        createdAt: json['created_at'] ?? '',
      );
}
