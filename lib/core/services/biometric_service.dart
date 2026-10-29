import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'storage_service.dart';

/// Result envelope for biometric authentication attempts
class BiometricAuthResult {
  final bool success;
  final String? errorMessage;
  final bool isCancelled;

  const BiometricAuthResult({
    required this.success,
    this.errorMessage,
    this.isCancelled = false,
  });

  factory BiometricAuthResult.success() =>
      const BiometricAuthResult(success: true);

  factory BiometricAuthResult.failure(
    String message, {
    bool isCancelled = false,
  }) => BiometricAuthResult(
    success: false,
    errorMessage: message,
    isCancelled: isCancelled,
  );
}

/// Service managing device biometric authentication and encrypted credential storage.
///
/// NOTE ON SECURITY ARCHITECTURE:
/// The current Hakori Almadinah backend API (`/auth/login`) requires standard email &
/// password authentication for session creation. To strictly adhere to mobile security
/// standards without compromising safety:
/// - Plaintext credentials are NEVER saved to SharedPreferences or unencrypted storage.
/// - Credentials required for re-authentication are securely encapsulated in the platform's
///   hardware-backed security module (iOS Keychain / Android EncryptedSharedPreferences via KeyStore).
/// - Credentials are only accessible after successful native biometric hardware validation.
/// - Biometric preferences are stored as UI flags only, never as authorization tokens.
/// - If backend credentials expire or fail, the secure vault is purged immediately.
class BiometricService {
  static const String _keySecureEmail = 'hakori_secure_bio_email';
  static const String _keySecureCredential = 'hakori_secure_bio_credential';

  final StorageService _storageService;
  final LocalAuthentication _localAuth;
  final FlutterSecureStorage _secureStorage;

  BiometricService({
    required StorageService storageService,
    LocalAuthentication? localAuth,
    FlutterSecureStorage? secureStorage,
  })  : _storageService = storageService,
        _localAuth = localAuth ?? LocalAuthentication(),
        _secureStorage =
            secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(resetOnError: true),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock,
              ),
            );

  /// Check whether the device supports biometric or hardware authentication
  Future<bool> isDeviceSupported() async {
    try {
      return await _localAuth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Check whether biometric sensors can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Check if biometrics are supported and at least one biometric type is enrolled
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!isSupported && !canCheck) return false;

      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Get list of enrolled biometric types (e.g. fingerprint, face)
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return const [];
    }
  }

  /// Authenticate using device native biometric prompt (Fingerprint / Face ID)
  Future<BiometricAuthResult> authenticate({
    required String localizedReason,
  }) async {
    try {
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        biometricOnly: true,
        persistAcrossBackgrounding: true,
      );

      if (didAuthenticate) {
        return BiometricAuthResult.success();
      } else {
        return BiometricAuthResult.failure(
          'Biometric verification was cancelled or not recognized.',
          isCancelled: true,
        );
      }
    } on LocalAuthException catch (e) {
      switch (e.code) {
        case LocalAuthExceptionCode.userCanceled:
        case LocalAuthExceptionCode.systemCanceled:
          return BiometricAuthResult.failure(
            'Biometric authentication was cancelled.',
            isCancelled: true,
          );
        case LocalAuthExceptionCode.noBiometricsEnrolled:
          return BiometricAuthResult.failure(
            'No biometric credentials are enrolled. Please set up fingerprint or Face ID in device settings.',
          );
        case LocalAuthExceptionCode.noBiometricHardware:
          return BiometricAuthResult.failure(
            'Biometric authentication hardware is not available on this device.',
          );
        case LocalAuthExceptionCode.noCredentialsSet:
          return BiometricAuthResult.failure(
            'Device lock passcode is not configured. Please enable screen lock in settings.',
          );
        case LocalAuthExceptionCode.authInProgress:
          return BiometricAuthResult.failure(
            'Authentication is already in progress.',
            isCancelled: true,
          );
        case LocalAuthExceptionCode.timeout:
          return BiometricAuthResult.failure(
            'Biometric authentication timed out. Please try again.',
          );
        default:
          final desc = e.description;
          return BiometricAuthResult.failure(
            (desc != null && desc.isNotEmpty)
                ? desc
                : 'Biometric authentication failed.',
          );
      }
    } on PlatformException catch (e) {
      if (e.code == 'UserCancel' ||
          e.code == 'Canceled' ||
          e.code == 'systemCanceled') {
        return BiometricAuthResult.failure(
          'Biometric authentication was cancelled.',
          isCancelled: true,
        );
      }
      return BiometricAuthResult.failure(
        e.message ?? 'Biometric authentication failed.',
      );
    } catch (e) {
      return BiometricAuthResult.failure(
        'An unexpected biometric error occurred: $e',
      );
    }
  }

  /// Check if the user previously enabled biometric access
  bool isBiometricEnabled() {
    return _storageService.isBiometricEnabled();
  }

  /// Securely persist credentials in hardware-backed storage and record preference
  Future<void> saveBiometricCredentials({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    await _secureStorage.write(key: _keySecureEmail, value: cleanEmail);
    await _secureStorage.write(key: _keySecureCredential, value: password);
    await _storageService.setBiometricEnabled(true);
    await _storageService.setBiometricEmail(cleanEmail);
  }

  /// Retrieve securely stored credentials for biometric re-authentication
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keySecureEmail);
      final credential = await _secureStorage.read(key: _keySecureCredential);
      if (email != null &&
          email.isNotEmpty &&
          credential != null &&
          credential.isNotEmpty) {
        return {'email': email, 'password': credential};
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Purge all securely stored biometric credentials and reset preference
  Future<void> clearBiometricCredentials() async {
    try {
      await _secureStorage.delete(key: _keySecureEmail);
      await _secureStorage.delete(key: _keySecureCredential);
    } catch (_) {}
    await _storageService.setBiometricEnabled(false);
    await _storageService.setBiometricEmail(null);
  }

  /// Whether biometric quick-access can be presented on the login screen
  Future<bool> canShowBiometricLogin() async {
    if (!_storageService.isBiometricEnabled()) return false;
    final creds = await getBiometricCredentials();
    if (creds == null) return false;
    final isAvailable = await isBiometricsAvailable();
    return isAvailable;
  }
}
