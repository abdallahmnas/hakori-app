/// User / Patron Model matching API_DOCUMENTATION.md
class User {
  final String id;
  final String email;
  final String fullName;
  final String role;
  final String? phone;
  final String? location;
  final String? tier;
  final String? standing;
  final String? fcmToken;
  final String? avatarUrl;
  final int ordersCount;
  final double lifetimeValue;
  final String? recentOrderDesc;
  final String? createdAt;
  final String? updatedAt;

  const User({
    required this.id,
    required this.email,
    required this.fullName,
    this.role = 'user',
    this.phone,
    this.location,
    this.tier = 'VIP Private Client',
    this.standing = 'ACTIVE',
    this.fcmToken,
    this.avatarUrl,
    this.ordersCount = 0,
    this.lifetimeValue = 0.0,
    this.recentOrderDesc,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: json['fullName']?.toString() ??
          (json['firstName'] != null
              ? '${json['firstName']} ${json['lastName'] ?? ''}'.trim()
              : ''),
      role: json['role']?.toString() ?? 'user',
      phone: json['phone']?.toString(),
      location: json['location']?.toString() ?? json['address']?.toString(),
      tier: json['tier']?.toString() ?? 'VIP Private Client',
      standing: json['standing']?.toString() ?? 'ACTIVE',
      fcmToken: json['fcmToken']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      ordersCount: (json['ordersCount'] as num?)?.toInt() ?? 0,
      lifetimeValue: (json['lifetimeValue'] as num?)?.toDouble() ?? 0.0,
      recentOrderDesc: json['recentOrderDesc']?.toString(),
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role,
      if (phone != null) 'phone': phone,
      if (location != null) 'location': location,
      if (tier != null) 'tier': tier,
      if (standing != null) 'standing': standing,
      if (fcmToken != null) 'fcmToken': fcmToken,
      if (avatarUrl != null) 'avatarUrl': avatarUrl,
      'ordersCount': ordersCount,
      'lifetimeValue': lifetimeValue,
      if (recentOrderDesc != null) 'recentOrderDesc': recentOrderDesc,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  String get name => fullName;

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? role,
    String? phone,
    String? location,
    String? tier,
    String? standing,
    String? fcmToken,
    String? avatarUrl,
    int? ordersCount,
    double? lifetimeValue,
    String? recentOrderDesc,
    String? createdAt,
    String? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      tier: tier ?? this.tier,
      standing: standing ?? this.standing,
      fcmToken: fcmToken ?? this.fcmToken,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      ordersCount: ordersCount ?? this.ordersCount,
      lifetimeValue: lifetimeValue ?? this.lifetimeValue,
      recentOrderDesc: recentOrderDesc ?? this.recentOrderDesc,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
