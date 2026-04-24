import 'user.dart';

class Withdrawal {
  final String id;
  final String userId;
  final double amount;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final String status;
  final String notes;
  final String? processedAt;
  final User? user;
  final String createdAt;

  Withdrawal({required this.id, this.userId = '', this.amount = 0, this.bankName = '', this.accountNumber = '', this.accountName = '', this.status = '', this.notes = '', this.processedAt, this.user, this.createdAt = ''});

  factory Withdrawal.fromJson(Map<String, dynamic> json) => Withdrawal(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        amount: (json['amount'] ?? 0).toDouble(),
        bankName: json['bank_name'] ?? '',
        accountNumber: json['account_number'] ?? '',
        accountName: json['account_name'] ?? '',
        status: json['status'] ?? '',
        notes: json['notes'] ?? '',
        processedAt: json['processed_at'],
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        createdAt: json['created_at'] ?? '',
      );
}
