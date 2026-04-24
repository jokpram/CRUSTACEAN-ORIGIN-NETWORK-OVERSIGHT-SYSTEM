class ShrimpType {
  final String id;
  final String name;
  final String description;
  final String image;

  ShrimpType({required this.id, required this.name, this.description = '', this.image = ''});

  factory ShrimpType.fromJson(Map<String, dynamic> json) => ShrimpType(
        id: json['id']?.toString() ?? '',
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        image: json['image'] ?? '',
      );
}
