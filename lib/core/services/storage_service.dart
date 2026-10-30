import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../models/promo_banner.dart';

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

  @visibleForTesting
  static void resetInstanceForTesting() => _instance = null;

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

  // --- Wishlist / Favorites Persistence ---
  static const String _keyWishlistIds = 'saved_wishlist_ids';
  static const String _keyWishlistProducts = 'saved_wishlist_products';

  Set<String> getWishlistIds() {
    final list = _prefs.getStringList(_keyWishlistIds);
    return list?.toSet() ?? {};
  }

  Future<bool> saveWishlistIds(Set<String> ids) {
    return _prefs.setStringList(_keyWishlistIds, ids.toList());
  }

  List<Product> getWishlistProducts() {
    final raw = _prefs.getString(_keyWishlistProducts);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .map((item) => Product.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveWishlistProducts(List<Product> products) {
    final list = products.map((p) => p.toJson()).toList();
    return _prefs.setString(_keyWishlistProducts, jsonEncode(list));
  }

  Future<bool> clearWishlist() async {
    await _prefs.remove(_keyWishlistIds);
    await _prefs.remove(_keyWishlistProducts);
    return true;
  }

  // --- Hero Banners Persistence ---
  static const String _keyHeroBanners = 'cached_hero_banners';

  List<PromoBanner> getCachedBanners() {
    final raw = _prefs.getString(_keyHeroBanners);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw);
      if (list is List) {
        return list
            .map((item) => PromoBanner.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> saveCachedBanners(List<PromoBanner> banners) {
    final list = banners.map((b) => b.toJson()).toList();
    return _prefs.setString(_keyHeroBanners, jsonEncode(list));
  }

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

  // --- Biometric Authentication Preferences ---
  static const String _keyBiometricEnabled = 'biometric_enabled';
  static const String _keyBiometricEmail = 'biometric_email';

  bool isBiometricEnabled() {
    return _prefs.getBool(_keyBiometricEnabled) ?? false;
  }

  Future<bool> setBiometricEnabled(bool enabled) {
    return _prefs.setBool(_keyBiometricEnabled, enabled);
  }

  String? getBiometricEmail() {
    return _prefs.getString(_keyBiometricEmail);
  }

  Future<bool> setBiometricEmail(String? email) {
    if (email == null) {
      return _prefs.remove(_keyBiometricEmail);
    }
    return _prefs.setString(_keyBiometricEmail, email);
  }

  // --- Exchange Rates & Currency Persistence ---
  static const String _keyExchangeRates = 'cached_exchange_rates';
  static const String _keySelectedCurrencyCode = 'selected_currency_code';

  Map<String, dynamic>? getExchangeData() {
    final raw = _prefs.getString(_keyExchangeRates);
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveExchangeData(Map<String, dynamic> data) {
    return _prefs.setString(_keyExchangeRates, jsonEncode(data));
  }

  String? getSelectedCurrencyCode() {
    return _prefs.getString(_keySelectedCurrencyCode);
  }

  Future<bool> saveSelectedCurrencyCode(String code) {
    return _prefs.setString(_keySelectedCurrencyCode, code);
  }

  // Clear Entire Session
  Future<void> clearAuthSession() async {
    await clearToken();
    await clearUser();
  }
}
