import 'user.dart';

class Review {
  final String id;
  final String userId;
  final String productId;
  final int rating;
  final String comment;
  final User? user;
  final String createdAt;

  Review({required this.id, this.userId = '', this.productId = '', this.rating = 0, this.comment = '', this.user, this.createdAt = ''});

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        productId: json['product_id']?.toString() ?? '',
        rating: (json['rating'] ?? 0).toInt(),
        comment: json['comment'] ?? '',
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        createdAt: json['created_at'] ?? '',
      );
}
