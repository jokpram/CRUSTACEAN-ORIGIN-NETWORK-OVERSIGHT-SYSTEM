class FeedLog {
  final String id;
  final String cultivationCycleId;
  final String feedType;
  final double quantity;
  final String feedingTime;
  final String notes;
  final String createdAt;

  FeedLog({required this.id, this.cultivationCycleId = '', this.feedType = '', this.quantity = 0, this.feedingTime = '', this.notes = '', this.createdAt = ''});

  factory FeedLog.fromJson(Map<String, dynamic> json) => FeedLog(
        id: json['id']?.toString() ?? '',
        cultivationCycleId: json['cultivation_cycle_id']?.toString() ?? '',
        feedType: json['feed_type'] ?? '',
        quantity: (json['quantity'] ?? 0).toDouble(),
        feedingTime: json['feeding_time'] ?? '',
        notes: json['notes'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}
