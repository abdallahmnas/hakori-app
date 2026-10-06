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
  String? _pendingFirstName;
  String? _pendingLastName;
  String? _pendingPhone;
  String? _pendingPassword;

  AuthProvider(this._authService, this._storageService);

  AuthStatus get status => _status;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _currentUser != null;
  bool get isLoading => _status == AuthStatus.loading;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  String? get signupSessionToken => _signupSessionToken ?? _storageService.getSignupSessionToken();
  String? get signupVerificationToken => _signupVerificationToken ?? _storageService.getSignupVerificationToken();
  String? get resetSessionToken => _resetSessionToken;
  String? get resetToken => _resetToken;
  String? get lastEmail => _lastEmail ?? _storageService.getSignupEmail();
  String? get pendingFullName => _pendingFullName;
  String? get pendingFirstName => _pendingFirstName;
  String? get pendingLastName => _pendingLastName;
  String? get pendingPhone => _pendingPhone;
  String? get pendingPassword => _pendingPassword;

  void setPendingStep1({
    required String email,
    required String phone,
    required String password,
  }) {
    _lastEmail = email.trim();
    _pendingPhone = phone.trim();
    _pendingPassword = password;
  }

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
      _status = AuthStatus.authenticated;
      notifyListeners();
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
      final token = data['token']?.toString() ??
          data['sessionToken']?.toString() ??
          data['data']?['token']?.toString() ??
          data['data']?['sessionToken']?.toString();

      _signupSessionToken = token;
      if (token != null && token.isNotEmpty) {
        await _storageService.saveSignupSession(
          email: _lastEmail!,
          sessionToken: token,
        );
      }
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
    final email = _lastEmail ?? _storageService.getSignupEmail();
    final sessionToken =
        _signupSessionToken ?? _storageService.getSignupSessionToken();

    if (email == null ||
        sessionToken == null ||
        email.isEmpty ||
        sessionToken.isEmpty) {
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
        email: email,
        sessionToken: sessionToken,
        otp: otp,
      );
      final verifiedToken = data['token']?.toString() ??
          data['verificationToken']?.toString() ??
          data['completionToken']?.toString() ??
          data['data']?['token']?.toString();

      _signupVerificationToken = verifiedToken;
      if (verifiedToken != null && verifiedToken.isNotEmpty) {
        await _storageService.saveSignupVerificationToken(verifiedToken);
      }
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
    String? firstName,
    String? lastName,
    String? fullName,
    String? password,
    String? phone,
    String? city,
    String? country,
    String? address,
    String? location,
    String tier = 'VIP Private Client',
  }) async {
    final email = _lastEmail ?? _storageService.getSignupEmail();
    final verificationToken =
        _signupVerificationToken ?? _storageService.getSignupVerificationToken();

    if (email == null ||
        verificationToken == null ||
        email.isEmpty ||
        verificationToken.isEmpty) {
      _errorMessage = 'Verification token missing. Please start again.';
      _status = AuthStatus.error;
      notifyListeners();
      return false;
    }

    final pass = password ?? _pendingPassword ?? 'Hakori@2026';
    final pPhone = phone ?? _pendingPhone;
    final fName = firstName ?? _pendingFirstName;
    final lName = lastName ?? _pendingLastName;
    final fFullName = fullName ??
        _pendingFullName ??
        ((fName != null || lName != null)
            ? '$fName $lName'.trim()
            : 'Patron');

    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _authService.signupComplete(
        verificationToken: verificationToken,
        email: email,
        password: pass,
        firstName: fName,
        lastName: lName,
        fullName: fFullName,
        phone: pPhone,
        city: city,
        country: country,
        address: address,
        location: location,
        tier: tier,
      );

      final token = data['token']?.toString() ?? '';
      final userMap = data['user'] as Map<String, dynamic>? ?? {};
      final user = User.fromJson(userMap);

      await _storageService.saveToken(token);
      await _storageService.saveUser(user);
      await _storageService.clearSignupFlow();
      _signupSessionToken = null;
      _signupVerificationToken = null;

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
    await _storageService.clearSignupFlow();
    _signupSessionToken = null;
    _signupVerificationToken = null;
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
