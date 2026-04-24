class ProductImage {
  final String id;
  final String productId;
  final String imageUrl;
  final bool isPrimary;

  ProductImage({required this.id, this.productId = '', this.imageUrl = '', this.isPrimary = false});

  factory ProductImage.fromJson(Map<String, dynamic> json) => ProductImage(
        id: json['id']?.toString() ?? '',
        productId: json['product_id']?.toString() ?? '',
        imageUrl: json['image_url'] ?? '',
        isPrimary: json['is_primary'] ?? false,
      );
}
