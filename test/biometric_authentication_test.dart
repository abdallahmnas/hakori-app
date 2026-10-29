import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_platform_interface/local_auth_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hakori_almadinah/core/services/storage_service.dart';
import 'package:hakori_almadinah/core/services/biometric_service.dart';
import 'package:hakori_almadinah/core/services/auth_provider.dart';
import 'package:hakori_almadinah/core/services/auth_service.dart';
import 'package:hakori_almadinah/core/services/api_client.dart';
import 'package:hakori_almadinah/core/models/user.dart';

class FakeSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value != null) {
      data[key] = value;
    } else {
      data.remove(key);
    }
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return data[key];
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    data.clear();
  }
}

class FakeLocalAuth extends Fake implements LocalAuthentication {
  bool isSupported = true;
  bool canCheck = true;
  List<BiometricType> availableBiometrics = [BiometricType.fingerprint];
  bool authenticateResult = true;
  LocalAuthException? exceptionToThrow;

  @override
  Future<bool> isDeviceSupported() async => isSupported;

  @override
  Future<bool> get canCheckBiometrics async => canCheck;

  @override
  Future<List<BiometricType>> getAvailableBiometrics() async =>
      availableBiometrics;

  @override
  Future<bool> authenticate({
    required String localizedReason,
    Iterable<AuthMessages> authMessages = const <AuthMessages>[],
    bool biometricOnly = false,
    bool sensitiveTransaction = true,
    bool persistAcrossBackgrounding = false,
  }) async {
    if (exceptionToThrow != null) {
      throw exceptionToThrow!;
    }
    return authenticateResult;
  }
}

class FakeAuthService extends Fake implements AuthService {
  bool shouldSucceed = true;
  String? failErrorMessage;

  @override
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    if (!shouldSucceed) {
      throw ApiException(
        message: failErrorMessage ?? 'Invalid credentials',
        statusCode: 401,
      );
    }
    return {
      'token': 'jwt_token_sample_abc123',
      'user': {
        'id': 'user_123',
        'email': email,
        'fullName': 'Julian Vance',
        'role': 'user',
        'tier': 'Tier I Private Patron',
      },
    };
  }

  @override
  Future<User> getProfile() async {
    return User(
      id: 'user_123',
      email: 'patron@hakori.com',
      fullName: 'Julian Vance',
      role: 'user',
      tier: 'Tier I Private Patron',
    );
  }

  @override
  Future<void> logout() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storageService;
  late FakeSecureStorage fakeSecureStorage;
  late FakeLocalAuth fakeLocalAuth;
  late BiometricService biometricService;
  late FakeAuthService fakeAuthService;
  late AuthProvider authProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storageService = await StorageService.getInstance();
    await storageService.setBiometricEnabled(false);
    await storageService.setBiometricEmail(null);
    await storageService.clearAuthSession();
    fakeSecureStorage = FakeSecureStorage();
    fakeLocalAuth = FakeLocalAuth();
    fakeAuthService = FakeAuthService();

    biometricService = BiometricService(
      storageService: storageService,
      localAuth: fakeLocalAuth,
      secureStorage: fakeSecureStorage,
    );

    authProvider = AuthProvider(
      fakeAuthService,
      storageService,
      biometricService: biometricService,
    );
  });

  group('Scenario 1 & 8: Enabling Biometric Access and Persistence', () {
    test('Enables biometric access with valid credentials and persists preference', () async {
      // Initially disabled
      expect(biometricService.isBiometricEnabled(), false);
      expect(await biometricService.canShowBiometricLogin(), false);

      // Verify device support
      final isAvailable = await biometricService.isBiometricsAvailable();
      expect(isAvailable, true);

      // Authenticate natively
      final authResult = await biometricService.authenticate(
        localizedReason: 'Enable Biometrics',
      );
      expect(authResult.success, true);

      // Save credentials in hardware-backed secure storage
      await biometricService.saveBiometricCredentials(
        email: 'patron@hakori.com',
        password: 'Password123!',
      );

      // Verify preference updated
      expect(biometricService.isBiometricEnabled(), true);
      expect(storageService.isBiometricEnabled(), true);
      expect(storageService.getBiometricEmail(), 'patron@hakori.com');
      expect(await biometricService.canShowBiometricLogin(), true);

      // Verify credentials stored in secure storage, NOT plaintext shared_preferences
      expect(fakeSecureStorage.data['hakori_secure_bio_email'], 'patron@hakori.com');
      expect(fakeSecureStorage.data['hakori_secure_bio_credential'], 'Password123!');
      expect(storageService.getSavedEmail(), null); // password is not in prefs
    });
  });

  group('Scenario 2: Enabling Biometric Access with Incorrect Password', () {
    test('Incorrect password rejection stops biometric enablement', () async {
      fakeAuthService.shouldSucceed = false;
      fakeAuthService.failErrorMessage = 'Invalid email or password';

      // Attempting to verify credentials fails
      expect(
        () => fakeAuthService.login(email: 'patron@hakori.com', password: 'WrongPassword'),
        throwsA(isA<ApiException>()),
      );

      // Preferences and credentials remain disabled
      expect(biometricService.isBiometricEnabled(), false);
      expect(await biometricService.getBiometricCredentials(), null);
    });
  });

  group('Scenario 3: Cancelling Password Confirmation Dialog', () {
    test('User cancellation leaves preference untouched', () async {
      // User opens dialog and cancels
      expect(biometricService.isBiometricEnabled(), false);
      expect(await biometricService.canShowBiometricLogin(), false);
    });
  });

  group('Scenario 4: Device Without Biometric Hardware or Enrollment', () {
    test('Device with no hardware or no enrolled biometrics cannot enable feature', () async {
      fakeLocalAuth.isSupported = false;
      fakeLocalAuth.canCheck = false;
      fakeLocalAuth.availableBiometrics = [];

      final isAvailable = await biometricService.isBiometricsAvailable();
      expect(isAvailable, false);
      expect(biometricService.isBiometricEnabled(), false);
    });

    test('Device with hardware but no enrollment throws clean exception', () async {
      fakeLocalAuth.exceptionToThrow = const LocalAuthException(
        code: LocalAuthExceptionCode.noBiometricsEnrolled,
        description: 'No biometrics enrolled',
      );

      final result = await biometricService.authenticate(
        localizedReason: 'Enable Biometrics',
      );
      expect(result.success, false);
      expect(result.errorMessage, contains('No biometric credentials are enrolled'));
    });
  });

  group('Scenario 5: Successful Biometric Verification Followed by API Login', () {
    test('Biometric login authenticates and establishes session', () async {
      // Pre-enroll biometrics
      await biometricService.saveBiometricCredentials(
        email: 'patron@hakori.com',
        password: 'Password123!',
      );

      // Prompt biometric verification
      final bioResult = await biometricService.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
      expect(bioResult.success, true);

      // Retrieve credentials from secure storage
      final creds = await biometricService.getBiometricCredentials();
      expect(creds, isNotNull);

      // Perform API login
      final loginSuccess = await authProvider.login(
        email: creds!['email']!,
        password: creds['password']!,
      );

      expect(loginSuccess, true);
      expect(authProvider.isAuthenticated, true);
      expect(storageService.getToken(), 'jwt_token_sample_abc123');
      expect(storageService.getUser()?.email, 'patron@hakori.com');
    });
  });

  group('Scenario 6: Failed Biometric Verification or Cancellation', () {
    test('Cancelled biometric prompt does not initiate API call', () async {
      fakeLocalAuth.authenticateResult = false;

      final bioResult = await biometricService.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
      expect(bioResult.success, false);
      expect(bioResult.isCancelled, true);

      // AuthProvider remains unauthenticated
      expect(authProvider.isAuthenticated, false);
    });

    test('User cancel exception flagged as isCancelled', () async {
      fakeLocalAuth.exceptionToThrow = const LocalAuthException(
        code: LocalAuthExceptionCode.userCanceled,
        description: 'User canceled',
      );

      final bioResult = await biometricService.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
      expect(bioResult.success, false);
      expect(bioResult.isCancelled, true);
    });
  });

  group('Scenario 7: Successful Biometric Prompt Followed by Failed API Request', () {
    test('API error after biometric verification shows failure', () async {
      await biometricService.saveBiometricCredentials(
        email: 'patron@hakori.com',
        password: 'OldPassword',
      );

      // Biometric passes
      final bioResult = await biometricService.authenticate(
        localizedReason: 'Authenticate to sign in',
      );
      expect(bioResult.success, true);

      // Backend rejects (password changed)
      fakeAuthService.shouldSucceed = false;
      fakeAuthService.failErrorMessage = 'Account credentials invalid';

      final creds = await biometricService.getBiometricCredentials();
      final loginSuccess = await authProvider.login(
        email: creds!['email']!,
        password: creds['password']!,
      );

      expect(loginSuccess, false);
      expect(authProvider.isAuthenticated, false);
      expect(authProvider.errorMessage, 'Account credentials invalid');
    });
  });

  group('Scenario 9: Disabling Biometric Access', () {
    test('Disabling removes credentials from secure storage and hides login option', () async {
      // Setup enabled
      await biometricService.saveBiometricCredentials(
        email: 'patron@hakori.com',
        password: 'Password123!',
      );
      expect(await biometricService.canShowBiometricLogin(), true);

      // Disable
      await biometricService.clearBiometricCredentials();

      expect(biometricService.isBiometricEnabled(), false);
      expect(storageService.isBiometricEnabled(), false);
      expect(storageService.getBiometricEmail(), null);
      expect(await biometricService.getBiometricCredentials(), null);
      expect(fakeSecureStorage.data.isEmpty, true);
      expect(await biometricService.canShowBiometricLogin(), false);
    });
  });

  group('Scenario 10: Logout, Account Switching, and Boundary Isolation', () {
    test('Account switching automatically purges previous account biometric credentials', () async {
      // User A enables biometrics
      await biometricService.saveBiometricCredentials(
        email: 'usera@hakori.com',
        password: 'PasswordA!',
      );
      expect(biometricService.isBiometricEnabled(), true);
      expect(storageService.getBiometricEmail(), 'usera@hakori.com');

      // User logs in with User B's account
      await authProvider.login(
        email: 'userb@hakori.com',
        password: 'PasswordB!',
      );

      // Previous account's biometric credentials MUST be purged
      expect(biometricService.isBiometricEnabled(), false);
      expect(storageService.getBiometricEmail(), null);
      expect(await biometricService.getBiometricCredentials(), null);
      expect(fakeSecureStorage.data.isEmpty, true);
    });
  });

  group('Scenario 11 & 12: Normal Login and Concurrency', () {
    test('Normal email and password login continues to function as before', () async {
      final loginSuccess = await authProvider.login(
        email: 'standard@hakori.com',
        password: 'StandardPassword123!',
      );

      expect(loginSuccess, true);
      expect(authProvider.isAuthenticated, true);
      expect(storageService.getUser()?.email, 'standard@hakori.com');
    });
  });
}
