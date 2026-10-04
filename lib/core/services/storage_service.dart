import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/cart_item.dart';

/// Central Persistent Local Storage Service using SharedPreferences
class StorageService {
  static const String _keyToken = 'auth_token';
  static const String _keyUser = 'auth_user';
  static const String _keyCart = 'saved_cart';
  static const String _keySavedEmail = 'saved_email';
  static const String _keyOnboardingCompleted = 'onboarding_completed';

  static StorageService? _instance;
  final SharedPreferences _prefs;

  StorageService._(this._prefs);

  static Future<StorageService> getInstance() async {
    if (_instance == null) {
      final prefs = await SharedPreferences.getInstance();
      _instance = StorageService._(prefs);
    }
    return _instance!;
  }

  // --- Auth Token ---
  String? getToken() {
    return _prefs.getString(_keyToken);
  }

  Future<bool> saveToken(String token) {
    return _prefs.setString(_keyToken, token);
  }

  Future<bool> clearToken() {
    return _prefs.remove(_keyToken);
  }

  // --- User Profile ---
  User? getUser() {
    final raw = _prefs.getString(_keyUser);
    if (raw == null || raw.isEmpty) return null;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return User.fromJson(map);
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveUser(User user) {
    return _prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<bool> clearUser() {
    return _prefs.remove(_keyUser);
  }

  // --- Cart Persistence ---
  List<CartItem> getCart() {
    final raw = _prefs.getString(_keyCart);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      clearCart();
      return [];
    }
  }

  Future<bool> saveCart(List<CartItem> items) {
    final list = items.map((e) => e.toJson()).toList();
    return _prefs.setString(_keyCart, jsonEncode(list));
  }

  Future<bool> clearCart() {
    return _prefs.remove(_keyCart);
  }

  // --- Remembered Credentials ---
  String? getSavedEmail() {
    return _prefs.getString(_keySavedEmail);
  }

  Future<bool> saveSavedEmail(String email) {
    return _prefs.setString(_keySavedEmail, email);
  }

  // --- Onboarding Status ---
  bool isOnboardingCompleted() {
    return _prefs.getBool(_keyOnboardingCompleted) ?? false;
  }

  Future<bool> setOnboardingCompleted([bool completed = true]) {
    return _prefs.setBool(_keyOnboardingCompleted, completed);
  }

  // --- Signup Flow Persistence ---
  static const String _keySignupEmail = 'signup_flow_email';
  static const String _keySignupSessionToken = 'signup_session_token';
  static const String _keySignupVerificationToken = 'signup_verification_token';

  Future<void> saveSignupSession({required String email, required String sessionToken}) async {
    await _prefs.setString(_keySignupEmail, email);
    await _prefs.setString(_keySignupSessionToken, sessionToken);
  }

  String? getSignupEmail() => _prefs.getString(_keySignupEmail);
  String? getSignupSessionToken() => _prefs.getString(_keySignupSessionToken);

  Future<void> saveSignupVerificationToken(String token) async {
    await _prefs.setString(_keySignupVerificationToken, token);
  }

  String? getSignupVerificationToken() => _prefs.getString(_keySignupVerificationToken);

  Future<void> clearSignupFlow() async {
    await _prefs.remove(_keySignupEmail);
    await _prefs.remove(_keySignupSessionToken);
    await _prefs.remove(_keySignupVerificationToken);
  }

  // Clear Entire Session
  Future<void> clearAuthSession() async {
    await clearToken();
    await clearUser();
  }
}
