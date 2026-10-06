import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_client.dart';

/// Authentication & User API Service matching API_DOCUMENTATION.md
class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// Step 1: Initiate Signup (dispatches 6-digit OTP)
  Future<Map<String, dynamic>> signupInit(String email) async {
    final response = await _client.post(
      ApiConstants.signupInit,
      data: {'email': email.trim()},
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      final inner = map['data'];
      if (inner is Map<String, dynamic>) {
        return inner;
      }
      return map;
    }
    return {};
  }

  /// Step 2: Verify Signup OTP
  Future<Map<String, dynamic>> signupVerify({
    required String email,
    required String sessionToken,
    required String otp,
  }) async {
    final response = await _client.post(
      ApiConstants.signupVerify,
      options: Options(headers: {'Authorization': 'Bearer $sessionToken'}),
      data: {
        'otp': otp.trim(),
        'token': sessionToken,
        'email': email.trim(),
        'sessionToken': sessionToken,
      },
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      final inner = map['data'];
      if (inner is Map<String, dynamic>) {
        return inner;
      }
      return map;
    }
    return {};
  }

  /// Step 3: Complete Profile & Register in Database
  Future<Map<String, dynamic>> signupComplete({
    required String verificationToken,
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? fullName,
    String? phone,
    String? city,
    String? country,
    String? address,
    String? location,
    String tier = 'VIP Private Client',
  }) async {
    final effectiveFirstName =
        firstName ??
        (fullName != null ? fullName.trim().split(' ').first : 'Patron');
    final effectiveLastName =
        lastName ??
        (fullName != null && fullName.trim().contains(' ')
            ? fullName.trim().split(' ').sublist(1).join(' ')
            : '');
    final effectiveFullName =
        fullName ?? '$effectiveFirstName $effectiveLastName'.trim();
    final effectiveLocation =
        location ??
        [
          address,
          city,
          country,
        ].where((e) => e != null && e.trim().isNotEmpty).join(', ');

    final response = await _client.post(
      ApiConstants.signupComplete,
      options: Options(headers: {'Authorization': 'Bearer $verificationToken'}),
      data: {
        'token': verificationToken,
        'verificationToken': verificationToken,
        'email': email.trim(),
        'password': password,
        'firstName': effectiveFirstName,
        'lastName': effectiveLastName,
        'fullName': effectiveFullName,
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (city != null && city.isNotEmpty) 'city': city.trim(),
        if (country != null && country.isNotEmpty) 'country': country.trim(),
        if (address != null && address.isNotEmpty) 'address': address.trim(),
        if (effectiveLocation.isNotEmpty) 'location': effectiveLocation,
        'tier': tier,
      },
    );
    if (response.data is Map<String, dynamic>) {
      final map = response.data as Map<String, dynamic>;
      final inner = map['data'];
      if (inner is Map<String, dynamic>) {
        return inner;
      }
      return map;
    }
    return {};
  }

  /// Patron & Admin Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {'email': email.trim(), 'password': password},
    );
    final data =
        response.data['data'] as Map<String, dynamic>? ??
        response.data as Map<String, dynamic>? ??
        {};
    return data;
  }

  /// Request Password Reset OTP
  Future<String> forgotPassword(String email) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email.trim()},
    );
    final map = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;
    return data['token']?.toString() ?? data['sessionToken']?.toString() ?? '';
  }

  /// Verify Password Reset OTP
  Future<String> verifyResetOtp({
    required String email,
    required String sessionToken,
    required String otp,
  }) async {
    final response = await _client.post(
      ApiConstants.verifyResetOtp,
      data: {
        'email': email.trim(),
        'sessionToken': sessionToken,
        'otp': otp.trim(),
      },
    );
    final map = response.data is Map<String, dynamic>
        ? response.data as Map<String, dynamic>
        : {};
    final data = map['data'] is Map<String, dynamic>
        ? map['data'] as Map<String, dynamic>
        : map;
    return data['token']?.toString() ?? data['resetToken']?.toString() ?? '';
  }

  /// Set New Password
  Future<void> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    await _client.post(
      ApiConstants.resetPassword,
      data: {
        'email': email.trim(),
        'resetToken': resetToken,
        'newPassword': newPassword,
      },
    );
  }

  /// Get Active Authenticated User
  Future<User> getMe() async {
    try {
      final response = await _client.get(ApiConstants.authMe);
      return _parseUserResponse(response.data);
    } catch (_) {
      return getProfile();
    }
  }

  /// Logout Active User
  Future<void> logout() async {
    try {
      await _client.post(ApiConstants.logout);
    } catch (_) {
      // Allow local logout even if server endpoint fails
    }
  }

  /// Get Patron Profile & Dynamic Metrics
  Future<User> getProfile() async {
    try {
      final response = await _client.get(ApiConstants.userProfile);
      return _parseUserResponse(response.data);
    } catch (_) {
      try {
        final fallback = await _client.get(ApiConstants.authMe);
        return _parseUserResponse(fallback.data);
      } catch (e) {
        rethrow;
      }
    }
  }

  /// Update Patron Profile & FCM Token
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? fcmToken,
    String? avatarUrl,
  }) async {
    final response = await _client.put(
      ApiConstants.userProfile,
      data: {
        'firstName': ?firstName,
        'lastName': ?lastName,
        'phone': ?phone,
        'address': ?address,
        'city': ?city,
        'country': ?country,
        'fcmToken': ?fcmToken,
        'avatarUrl': ?avatarUrl,
      },
    );
    return _parseUserResponse(response.data);
  }

  User _parseUserResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      final dataField = raw['data'];
      if (dataField is Map<String, dynamic>) {
        final userField = dataField['user'];
        if (userField is Map<String, dynamic>) {
          return User.fromJson(userField);
        }
        return User.fromJson(dataField);
      }
      final userField = raw['user'];
      if (userField is Map<String, dynamic>) {
        return User.fromJson(userField);
      }
      return User.fromJson(raw);
    }
    return const User(id: '', email: '', fullName: '');
  }
}
