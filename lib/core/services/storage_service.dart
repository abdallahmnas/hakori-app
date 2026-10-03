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

  // Clear Entire Session
  Future<void> clearAuthSession() async {
    await clearToken();
    await clearUser();
  }
}
