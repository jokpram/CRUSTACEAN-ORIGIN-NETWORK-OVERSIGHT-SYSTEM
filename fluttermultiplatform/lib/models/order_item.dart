import 'product.dart';

class OrderItem {
  final String id;
  final String orderId;
  final String productId;
  final int quantity;
  final double price;
  final double subtotal;
  final Product? product;

  OrderItem({required this.id, this.orderId = '', this.productId = '', this.quantity = 0, this.price = 0, this.subtotal = 0, this.product});

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        id: json['id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        productId: json['product_id']?.toString() ?? '',
        quantity: (json['quantity'] ?? 0).toInt(),
        price: (json['price'] ?? 0).toDouble(),
        subtotal: (json['subtotal'] ?? 0).toDouble(),
        product: json['product'] != null ? Product.fromJson(json['product']) : null,
      );
}
