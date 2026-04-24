import 'user.dart';
import 'batch.dart';
import 'product_image.dart';
import 'review.dart';

class Product {
  final String id;
  final String userId;
  final String? batchId;
  final String name;
  final String description;
  final double price;
  final int stock;
  final String shrimpType;
  final String size;
  final String unit;
  final bool isAvailable;
  final double ratingAvg;
  final int ratingCount;
  final User? user;
  final Batch? batch;
  final List<ProductImage>? images;
  final List<Review>? reviews;
  final String createdAt;

  Product({required this.id, this.userId = '', this.batchId, required this.name, this.description = '', this.price = 0, this.stock = 0, this.shrimpType = '', this.size = '', this.unit = 'kg', this.isAvailable = true, this.ratingAvg = 0, this.ratingCount = 0, this.user, this.batch, this.images, this.reviews, this.createdAt = ''});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        batchId: json['batch_id']?.toString(),
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        stock: (json['stock'] ?? 0).toInt(),
        shrimpType: json['shrimp_type'] ?? '',
        size: json['size'] ?? '',
        unit: json['unit'] ?? 'kg',
        isAvailable: json['is_available'] ?? true,
        ratingAvg: (json['rating_avg'] ?? 0).toDouble(),
        ratingCount: (json['rating_count'] ?? 0).toInt(),
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        batch: json['batch'] != null ? Batch.fromJson(json['batch']) : null,
        images: json['images'] != null ? (json['images'] as List).map((e) => ProductImage.fromJson(e)).toList() : null,
        reviews: json['reviews'] != null ? (json['reviews'] as List).map((e) => Review.fromJson(e)).toList() : null,
        createdAt: json['created_at'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'id': id, 'name': name, 'description': description, 'price': price, 'stock': stock, 'shrimp_type': shrimpType, 'size': size, 'unit': unit, 'is_available': isAvailable, 'rating_avg': ratingAvg, 'rating_count': ratingCount,
      };
}
