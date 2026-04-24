import 'user.dart';

class TraceabilityLog {
  final String id;
  final String previousHash;
  final String currentHash;
  final String timestamp;
  final String eventType;
  final String actorId;
  final String entityType;
  final String entityId;
  final String dataPayload;
  final User? actor;

  TraceabilityLog({required this.id, this.previousHash = '', this.currentHash = '', this.timestamp = '', this.eventType = '', this.actorId = '', this.entityType = '', this.entityId = '', this.dataPayload = '', this.actor});

  factory TraceabilityLog.fromJson(Map<String, dynamic> json) => TraceabilityLog(
        id: json['id']?.toString() ?? '',
        previousHash: json['previous_hash'] ?? '',
        currentHash: json['current_hash'] ?? '',
        timestamp: json['timestamp'] ?? '',
        eventType: json['event_type'] ?? '',
        actorId: json['actor_id']?.toString() ?? '',
        entityType: json['entity_type'] ?? '',
        entityId: json['entity_id']?.toString() ?? '',
        dataPayload: json['data_payload'] ?? '',
        actor: json['actor'] != null ? User.fromJson(json['actor']) : null,
      );
}
