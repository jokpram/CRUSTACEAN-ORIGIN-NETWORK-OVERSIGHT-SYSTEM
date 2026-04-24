class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // admin, petambak, logistik, konsumen
  final bool isVerified;
  final String address;
  final String avatar;
  final double balance;
  final String createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    required this.role,
    this.isVerified = false,
    this.address = '',
    this.avatar = '',
    this.balance = 0,
    this.createdAt = '',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'konsumen',
      isVerified: json['is_verified'] ?? false,
      address: json['address'] ?? '',
      avatar: json['avatar'] ?? '',
      balance: (json['balance'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'is_verified': isVerified,
        'address': address,
        'avatar': avatar,
        'balance': balance,
        'created_at': createdAt,
      };
}
