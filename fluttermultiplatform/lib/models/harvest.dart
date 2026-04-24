import 'cultivation_cycle.dart';
import 'batch.dart';

class Harvest {
  final String id;
  final String cultivationCycleId;
  final String harvestDate;
  final double totalWeight;
  final String shrimpSize;
  final String qualityGrade;
  final String notes;
  final CultivationCycle? cultivationCycle;
  final List<Batch>? batches;
  final String createdAt;

  Harvest({required this.id, this.cultivationCycleId = '', this.harvestDate = '', this.totalWeight = 0, this.shrimpSize = '', this.qualityGrade = '', this.notes = '', this.cultivationCycle, this.batches, this.createdAt = ''});

  factory Harvest.fromJson(Map<String, dynamic> json) => Harvest(
        id: json['id']?.toString() ?? '',
        cultivationCycleId: json['cultivation_cycle_id']?.toString() ?? '',
        harvestDate: json['harvest_date'] ?? '',
        totalWeight: (json['total_weight'] ?? 0).toDouble(),
        shrimpSize: json['shrimp_size'] ?? '',
        qualityGrade: json['quality_grade'] ?? '',
        notes: json['notes'] ?? '',
        cultivationCycle: json['cultivation_cycle'] != null ? CultivationCycle.fromJson(json['cultivation_cycle']) : null,
        batches: json['batches'] != null ? (json['batches'] as List).map((e) => Batch.fromJson(e)).toList() : null,
        createdAt: json['created_at'] ?? '',
      );
}
