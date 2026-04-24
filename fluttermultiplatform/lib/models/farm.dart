import 'pond.dart';
import 'user.dart';

class Farm {
  final String id;
  final String userId;
  final String name;
  final String location;
  final double area;
  final String description;
  final String image;
  final List<Pond>? ponds;
  final User? user;
  final String createdAt;

  Farm({required this.id, this.userId = '', required this.name, this.location = '', this.area = 0, this.description = '', this.image = '', this.ponds, this.user, this.createdAt = ''});

  factory Farm.fromJson(Map<String, dynamic> json) => Farm(
        id: json['id']?.toString() ?? '',
        userId: json['user_id']?.toString() ?? '',
        name: json['name'] ?? '',
        location: json['location'] ?? '',
        area: (json['area'] ?? 0).toDouble(),
        description: json['description'] ?? '',
        image: json['image'] ?? '',
        ponds: json['ponds'] != null ? (json['ponds'] as List).map((e) => Pond.fromJson(e)).toList() : null,
        user: json['user'] != null ? User.fromJson(json['user']) : null,
        createdAt: json['created_at'] ?? '',
      );
}
