import 'user.dart';
import 'order_item.dart';
import 'payment.dart';
import 'shipment.dart';

class Order {
  final String id;
  final String userId;
  final double totalAmount;
  final String status;
  final String shippingAddress;
  final String notes;
  final User? user;
  final List<OrderItem>? orderItems;
  final Payment? payment;
  final Shipment? shipment;
  final String? paymentUrl;
  final String createdAt;

  Order({required this.id, this.userId = '', this.totalAmount = 0, this.status = '', this.shippingAddress = '', this.notes = '', this.user, this.orderItems, this.payment, this.shipment, this.paymentUrl, this.createdAt = ''});

  /// Convenience getter — screens use `order.items`
  List<OrderItem> get items => orderItems ?? [];

  factory Order.fromJson(Map<String, dynamic> json) => Order(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        totalAmount: (json['total_amount'] ?? 0).toDouble(),
        status: json['status'] ?? '',
        shippingAddress: json['shipping_address'] ?? '',
        notes: json['notes'] ?? '',
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        orderItems: json['order_items'] != null ? (json['order_items'] as List).map((e) => OrderItem.fromJson(e)).toList() : null,
        payment: json['payment'] != null ? Payment.fromJson(json['payment']) : null,
        shipment: json['shipment'] != null ? Shipment.fromJson(json['shipment']) : null,
        paymentUrl: json['payment_url'] ?? json['payment']?['redirect_url'],
        createdAt: json['created_at'] ?? '',
      );
}
