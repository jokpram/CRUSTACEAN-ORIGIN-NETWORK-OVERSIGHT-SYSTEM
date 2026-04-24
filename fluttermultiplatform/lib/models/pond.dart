class Pond {
  final String id;
  final String farmId;
  final String name;
  final double area;
  final double depth;
  final String status;
  final String createdAt;

  Pond({required this.id, this.farmId = '', required this.name, this.area = 0, this.depth = 0, this.status = '', this.createdAt = ''});

  factory Pond.fromJson(Map<String, dynamic> json) => Pond(
        id: json['id']?.toString() ?? '',
        farmId: json['farm_id']?.toString() ?? '',
        name: json['name'] ?? '',
        area: (json['area'] ?? 0).toDouble(),
        depth: (json['depth'] ?? 0).toDouble(),
        status: json['status'] ?? '',
        createdAt: json['created_at'] ?? '',
      );
}
