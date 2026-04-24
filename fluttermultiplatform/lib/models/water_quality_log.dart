class WaterQualityLog {
  final String id;
  final String cultivationCycleId;
  final double temperature;
  final double ph;
  final double salinity;
  final double dissolvedOxygen;
  final String recordedAt;
  final String notes;
  final String createdAt;

  WaterQualityLog({required this.id, this.cultivationCycleId = '', this.temperature = 0, this.ph = 0, this.salinity = 0, this.dissolvedOxygen = 0, this.recordedAt = '', this.notes = '', this.createdAt = ''});

  factory WaterQualityLog.fromJson(Map<String, dynamic> json) => WaterQualityLog(
        id: json['id']?.toString() ?? '',
        cultivationCycleId: json['cultivation_cycle_id']?.toString() ?? '',
        temperature: (json['temperature'] ?? 0).toDouble(),
        ph: (json['ph'] ?? 0).toDouble(),
        salinity: (json['salinity'] ?? 0).toDouble(),
        dissolvedOxygen: (json['dissolved_oxygen'] ?? 0).toDouble(),
        recordedAt: json['recorded_at'] ?? '',
        notes: json['notes'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}
