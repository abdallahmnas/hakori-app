import 'package:flutter/foundation.dart';
import '../models/user.dart';
import 'auth_service.dart';
import 'storage_service.dart';
import 'api_client.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// Central Auth & User Profile Provider matching requirements
class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StorageService _storageService;

  AuthStatus _status = AuthStatus.initial;
  User? _currentUser;
  String? _errorMessage;

  // Transient onboarding & recovery tokens
  String? _signupSessionToken;
  String? _signupVerificationToken;
  String? _resetSessionToken;
  String? _resetToken;
  String? _lastEmail;

  // Pending signup details for step 3
  String? _pendingFullName;
  String? _pendingPhone;
  String? _pendingPassword;

  AuthProvider(this._authService, this._storageService);

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get signupSessionToken => _signupSessionToken;
  String? get signupVerificationToken => _signupVerificationToken;
  String? get resetSessionToken => _resetSessionToken;
  String? get resetToken => _resetToken;
  String? get lastEmail => _lastEmail;
  String? get pendingFullName => _pendingFullName;
  String? get pendingPhone => _pendingPhone;
  String? get pendingPassword => _pendingPassword;

  void setPendingRegistration({
    required String fullName,
    required String phone,
    required String password,
  }) {
    _pendingFullName = fullName;
    _pendingPhone = phone;
    _pendingPassword = password;
  }

  /// Startup session restoration
  Future<bool> restoreSession() async {
    _status = AuthStatus.loading;
    notifyListeners();

    final token = _storageService.getToken();
    final cachedUser = _storageService.getUser();

    if (token == null || token.isEmpty) {
      _status = AuthStatus.unauthenticated;
      _currentUser = null;
      notifyListeners();
      return false;
    }

    // Pre-populate with cached user for immediate rendering
    if (cachedUser != null) {
      _currentUser = cachedUser;
    }

    try {
      final user = await _authService.getProfile();
      _currentUser = user;
      await _storageService.saveUser(user);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      if (e.isAuthError) {
        await _storageService.clearAuthSession();
        _currentUser = null;
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
      // If network is offline, keep cached session if available
      if (cachedUser != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    } catch (_) {
      if (cachedUser != null) {
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Patron Login
  Future<bool> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.login(email: email, password: password);
      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>? ?? {};
      final user = User.fromJson(userMap);

      await _storageService.saveToken(token);
      await _storageService.saveUser(user);
      if (rememberMe) {
        await _storageService.saveSavedEmail(email);
      }

      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Login failed. Please check your credentials.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Signup Step 1: Initiate
  Future<bool> initiateSignup(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _lastEmail = email.trim();
    notifyListeners();

    try {
      final data = await _authService.signupInit(email);
      _signupSessionToken = data['sessionToken']?.toString();
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Could not dispatch verification code. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Signup Step 2: Verify OTP
  Future<bool> verifySignupOtp(String otp) async {
    if (_lastEmail == null || _signupSessionToken == null) {
      _errorMessage = 'Session expired. Please restart registration.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.signupVerify(
        email: _lastEmail!,
        sessionToken: _signupSessionToken!,
        otp: otp,
      );
      _signupVerificationToken = data['verificationToken']?.toString();
      _status = AuthStatus.unauthenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Invalid verification code. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Signup Step 3: Complete Profile & Enter App
  Future<bool> completeSignup({
    required String password,
    required String fullName,
    String? phone,
    String? location,
    String tier = 'VIP Private Client',
  }) async {
    if (_lastEmail == null || _signupVerificationToken == null) {
      _errorMessage = 'Verification token missing. Please start again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.signupComplete(
        verificationToken: _signupVerificationToken!,
        email: _lastEmail!,
        password: password,
        fullName: fullName,
        phone: phone,
        location: location,
        tier: tier,
      );

      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>? ?? {};
      final user = User.fromJson(userMap);

      await _storageService.saveToken(token);
      await _storageService.saveUser(user);

      _currentUser = user;
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Registration completion failed. Please try again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Password Recovery Step 1
  Future<bool> forgotPassword(String email) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    _lastEmail = email.trim();
    notifyListeners();

    try {
      _resetSessionToken = await _authService.forgotPassword(email);
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to request password reset code.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Password Recovery Step 2
  Future<bool> verifyResetOtp(String otp) async {
    if (_lastEmail == null || _resetSessionToken == null) {
      _errorMessage = 'Reset session expired.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _resetToken = await _authService.verifyResetOtp(
        email: _lastEmail!,
        sessionToken: _resetSessionToken!,
        otp: otp,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Invalid reset OTP.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Password Recovery Step 3
  Future<bool> resetPassword(String newPassword) async {
    if (_lastEmail == null || _resetToken == null) {
      _errorMessage = 'Reset token missing.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        email: _lastEmail!,
        resetToken: _resetToken!,
        newPassword: newPassword,
      );
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to reset password.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Update Profile Details
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    String? address,
    String? city,
    String? country,
    String? fcmToken,
    String? avatarUrl,
  }) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        phone: phone,
        address: address,
        city: city,
        country: country,
        fcmToken: fcmToken,
        avatarUrl: avatarUrl,
      );
      _currentUser = updated;
      await _storageService.saveUser(updated);
      _status = AuthStatus.authenticated;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Failed to update profile.';
      _status = AuthStatus.authenticated;
      notifyListeners();
      return false;
    }
  }

  /// Refresh Profile
  Future<void> refreshProfile() async {
    if (!isAuthenticated) return;
    try {
      final user = await _authService.getProfile();
      _currentUser = user;
      await _storageService.saveUser(user);
      notifyListeners();
    } catch (_) {}
  }

  /// Logout
  Future<void> logout() async {
    try {
      await _authService.logout();
    } catch (_) {}
    await _storageService.clearAuthSession();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = null;
    notifyListeners();
  }

  /// 401 Central Interceptor Callback
  void onSessionExpired() {
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _errorMessage = 'Session expired. Please log in.';
    notifyListeners();
  }
}
