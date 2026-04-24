class Payment {
  final String id;
  final String orderId;
  final double amount;
  final String method;
  final String status;
  final String? paidAt;
  final String? snapUrl;

  Payment({required this.id, this.orderId = '', this.amount = 0, this.method = '', this.status = '', this.paidAt, this.snapUrl});

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
        id: json['id']?.toString() ?? '',
        orderId: json['order_id']?.toString() ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        method: json['method'] ?? '',
        status: json['status'] ?? '',
        paidAt: json['paid_at'],
        snapUrl: json['midtrans_transaction'] != null ? json['midtrans_transaction']['snap_url'] : json['snap_url'],
      );
}
