class ShipmentLog {
  final String id;
  final String shipmentId;
  final String status;
  final String location;
  final String notes;
  final String timestamp;

  ShipmentLog({required this.id, this.shipmentId = '', this.status = '', this.location = '', this.notes = '', this.timestamp = ''});

  factory ShipmentLog.fromJson(Map<String, dynamic> json) => ShipmentLog(
        id: json['id']?.toString() ?? '',
        shipmentId: json['shipment_id']?.toString() ?? '',
        status: json['status'] ?? '',
        location: json['location'] ?? '',
        notes: json['notes'] ?? '',
        timestamp: json['timestamp'] ?? '',
      );
}
