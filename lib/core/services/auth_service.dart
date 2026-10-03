import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_client.dart';

/// Authentication & Patron User API Service matching API_DOCUMENTATION.md
class AuthService {
  final ApiClient _client;

  AuthService(this._client);

  /// Step 1: Initiate Patron Signup (dispatches OTP)
  Future<Map<String, dynamic>> signupInit(String email) async {
    final response = await _client.post(
      ApiConstants.signupInit,
      data: {'email': email.trim()},
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data;
  }

  /// Step 2: Verify Signup OTP
  Future<Map<String, dynamic>> signupVerify({
    required String email,
    required String sessionToken,
    required String otp,
  }) async {
    final response = await _client.post(
      ApiConstants.signupVerify,
      data: {
        'email': email.trim(),
        'sessionToken': sessionToken,
        'otp': otp.trim(),
      },
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data;
  }

  /// Step 3: Complete Profile & Register
  Future<Map<String, dynamic>> signupComplete({
    required String verificationToken,
    required String email,
    required String password,
    required String fullName,
    String? phone,
    String? location,
    String tier = 'VIP Private Client',
  }) async {
    final response = await _client.post(
      ApiConstants.signupComplete,
      data: {
        'verificationToken': verificationToken,
        'email': email.trim(),
        'password': password,
        'fullName': fullName.trim(),
        if (phone != null && phone.isNotEmpty) 'phone': phone.trim(),
        if (location != null && location.isNotEmpty) 'location': location.trim(),
        'tier': tier,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data;
  }

  /// Patron & Admin Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      ApiConstants.login,
      data: {
        'email': email.trim(),
        'password': password,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data;
  }

  /// Request Password Reset OTP
  Future<String> forgotPassword(String email) async {
    final response = await _client.post(
      ApiConstants.forgotPassword,
      data: {'email': email.trim()},
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data['sessionToken']?.toString() ?? '';
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
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    return data['resetToken']?.toString() ?? '';
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
    final response = await _client.get(ApiConstants.authMe);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userMap);
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
    final response = await _client.get(ApiConstants.userProfile);
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userMap);
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
        if (firstName != null) 'firstName': firstName,
        if (lastName != null) 'lastName': lastName,
        if (phone != null) 'phone': phone,
        if (address != null) 'address': address,
        if (city != null) 'city': city,
        if (country != null) 'country': country,
        if (fcmToken != null) 'fcmToken': fcmToken,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    final data = response.data['data'] as Map<String, dynamic>? ?? {};
    final userMap = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userMap);
  }
}
