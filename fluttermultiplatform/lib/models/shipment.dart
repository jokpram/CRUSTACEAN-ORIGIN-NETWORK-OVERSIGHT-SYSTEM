import 'user.dart';
import 'order.dart';
import 'shipment_log.dart';

class Shipment {
  final String id;
  final String orderId;
  final String? courierId;
  final String trackingNumber;
  final String status;
  final String? estimatedDelivery;
  final String? actualDelivery;
  final Order? order;
  final User? courier;
  final List<ShipmentLog>? shipmentLogs;
  final String createdAt;

  Shipment({required this.id, this.orderId = '', this.courierId, this.trackingNumber = '', this.status = '', this.estimatedDelivery, this.actualDelivery, this.order, this.courier, this.shipmentLogs, this.createdAt = ''});

  factory Shipment.fromJson(Map<String, dynamic> json) => Shipment(
        id: json['id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        courierId: json['courier_id']?.toString(),
        trackingNumber: json['tracking_number'] ?? '',
        status: json['status'] ?? '',
        estimatedDelivery: json['estimated_delivery'],
        actualDelivery: json['actual_delivery'],
        order: json['order'] != null ? Order.fromJson(json['order']) : null,
        courier: json['courier'] != null ? User.fromJson(json['courier']) : null,
        shipmentLogs: json['shipment_logs'] != null ? (json['shipment_logs'] as List).map((e) => ShipmentLog.fromJson(e)).toList() : null,
        createdAt: json['created_at'] ?? '',
      );
}
