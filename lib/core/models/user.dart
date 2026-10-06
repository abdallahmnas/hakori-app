/// User / Patron Model matching API_DOCUMENTATION.md and active backend payload:
/// {
///   "fullName": "Test customer",
///   "avatarUrl": "https://images.unsplash.com/...",
///   "id": "597eba2b-4c04-4a0a-8a9c-fdf4a5813973",
///   "email": "testcustomer@mailinator.com",
///   "firstName": "Test",
///   "lastName": "customer",
///   "middleName": "",
///   "role": "user",
///   "profilePic": "https://images.unsplash.com/...",
///   "gender": null,
///   "dateOfBirth": null,
///   "phone": "08011334466",
///   "address": "city hub",
///   "city": null,
///   "state": "Al Madinah",
///   "country": "nigeria",
///   "postalCode": null,
///   "department": "General",
///   "location": "Medina, nigeria",
///   "bio": null,
///   "isActive": true,
///   "tier": "Patron",
///   "standing": "ACTIVE",
///   "status": "Active",
///   "fcmToken": null,
///   "ordersCount": 0,
///   "lifetimeValue": 0,
///   "recentOrderDesc": "No active commissions",
///   "orders": []
/// }
class User {
  final String id;
  final String email;
  final String fullName;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final String role;
  final String? phone;
  final String? address;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;
  final String? department;
  final String? location;
  final String? bio;
  final bool isActive;
  final String? tier;
  final String? standing;
  final String? status;
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
    this.firstName,
    this.lastName,
    this.middleName,
    this.role = 'user',
    this.phone,
    this.address,
    this.city,
    this.state,
    this.country,
    this.postalCode,
    this.department,
    this.location,
    this.bio,
    this.isActive = true,
    this.tier = 'VIP Private Client',
    this.standing = 'ACTIVE',
    this.status = 'Active',
    this.fcmToken,
    this.avatarUrl,
    this.ordersCount = 0,
    this.lifetimeValue = 0.0,
    this.recentOrderDesc,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final fName = json['firstName']?.toString();
    final lName = json['lastName']?.toString();
    final composedName = [fName, lName].where((s) => s != null && s.trim().isNotEmpty).join(' ');

    final rawFullName = json['fullName']?.toString();
    final effectiveFullName = (rawFullName != null && rawFullName.trim().isNotEmpty)
        ? rawFullName
        : (composedName.isNotEmpty ? composedName : 'Patron');

    final rawAddress = json['address']?.toString();
    final rawCity = json['city']?.toString();
    final rawState = json['state']?.toString();
    final rawCountry = json['country']?.toString();

    final locationElements = [rawAddress, rawCity, rawState, rawCountry]
        .where((s) => s != null && s.trim().isNotEmpty)
        .join(', ');

    final rawLocation = json['location']?.toString();
    final effectiveLocation = (rawLocation != null && rawLocation.trim().isNotEmpty)
        ? rawLocation
        : (locationElements.isNotEmpty ? locationElements : null);

    return User(
      id: json['id']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      fullName: effectiveFullName,
      firstName: fName,
      lastName: lName,
      middleName: json['middleName']?.toString(),
      role: json['role']?.toString() ?? 'user',
      phone: json['phone']?.toString(),
      address: rawAddress,
      city: rawCity,
      state: rawState,
      country: rawCountry,
      postalCode: json['postalCode']?.toString(),
      department: json['department']?.toString(),
      location: effectiveLocation,
      bio: json['bio']?.toString(),
      isActive: json['isActive'] == null || json['isActive'] == true,
      tier: json['tier']?.toString() ?? 'VIP Private Client',
      standing: json['standing']?.toString() ?? 'ACTIVE',
      status: json['status']?.toString() ?? 'Active',
      fcmToken: json['fcmToken']?.toString(),
      avatarUrl: (json['avatarUrl'] ?? json['profilePic'])?.toString(),
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
      if (firstName != null) 'firstName': firstName,
      if (lastName != null) 'lastName': lastName,
      if (middleName != null) 'middleName': middleName,
      'role': role,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (postalCode != null) 'postalCode': postalCode,
      if (department != null) 'department': department,
      if (location != null) 'location': location,
      if (bio != null) 'bio': bio,
      'isActive': isActive,
      if (tier != null) 'tier': tier,
      if (standing != null) 'standing': standing,
      if (status != null) 'status': status,
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

  String get displayAddress {
    if (location != null && location!.trim().isNotEmpty) return location!;
    final parts = [address, city, state, country].where((s) => s != null && s.trim().isNotEmpty).join(', ');
    return parts.isNotEmpty ? parts : 'No address on file';
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? firstName,
    String? lastName,
    String? middleName,
    String? role,
    String? phone,
    String? address,
    String? city,
    String? state,
    String? country,
    String? postalCode,
    String? department,
    String? location,
    String? bio,
    bool? isActive,
    String? tier,
    String? standing,
    String? status,
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
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      middleName: middleName ?? this.middleName,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      department: department ?? this.department,
      location: location ?? this.location,
      bio: bio ?? this.bio,
      isActive: isActive ?? this.isActive,
      tier: tier ?? this.tier,
      standing: standing ?? this.standing,
      status: status ?? this.status,
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
