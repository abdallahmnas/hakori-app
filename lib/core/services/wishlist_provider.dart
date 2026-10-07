import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'storage_service.dart';

/// Persistent Wishlist / Favorites Provider using real products & SharedPreferences
class WishlistProvider extends ChangeNotifier {
  final StorageService? _storageService;

  final Set<String> _wishlistIds = {};
  final Map<String, Product> _productsMap = {};

  WishlistProvider([this._storageService]) {
    _restoreFromStorage();
  }

  void _restoreFromStorage() {
    final storage = _storageService;
    if (storage != null) {
      try {
        final savedIds = storage.getWishlistIds();
        _wishlistIds.addAll(savedIds);

        final savedProducts = storage.getWishlistProducts();
        for (final product in savedProducts) {
          if (_wishlistIds.contains(product.id)) {
            _productsMap[product.id] = product;
          }
        }
      } catch (e) {
        _wishlistIds.clear();
        _productsMap.clear();
      }
    }
  }

  Future<void> _persistWishlist() async {
    final storage = _storageService;
    if (storage != null) {
      await storage.saveWishlistIds(_wishlistIds);
      await storage.saveWishlistProducts(_productsMap.values.toList());
    }
  }

  /// List of real favorited products
  List<Product> get wishlistProducts =>
      _wishlistIds.map((id) => _productsMap[id]).whereType<Product>().toList();

  /// Total count of favorited pieces
  int get itemCount => _wishlistIds.length;

  /// Check whether a product is currently favorited
  bool isFavorite(String productId) => _wishlistIds.contains(productId);

  /// Toggle favorite state for a product
  void toggleFavorite(String productId, {Product? product}) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
      _productsMap.remove(productId);
    } else {
      _wishlistIds.add(productId);
      if (product != null) {
        _productsMap[productId] = product;
      }
    }
    _persistWishlist();
    notifyListeners();
  }

  /// Add a real product to wishlist
  void addToWishlist(Product product) {
    _wishlistIds.add(product.id);
    _productsMap[product.id] = product;
    _persistWishlist();
    notifyListeners();
  }

  /// Remove a product from wishlist
  void removeFromWishlist(String productId) {
    _wishlistIds.remove(productId);
    _productsMap.remove(productId);
    _persistWishlist();
    notifyListeners();
  }

  /// Sync product references from active catalog
  void syncProducts(List<Product> catalogProducts) {
    bool hasChanges = false;
    for (final prod in catalogProducts) {
      if (_wishlistIds.contains(prod.id)) {
        _productsMap[prod.id] = prod;
        hasChanges = true;
      }
    }
    if (hasChanges) {
      _persistWishlist();
      notifyListeners();
    }
  }

  /// Clear all saved favorites
  Future<void> clearWishlist() async {
    _wishlistIds.clear();
    _productsMap.clear();
    final storage = _storageService;
    if (storage != null) {
      await storage.clearWishlist();
    }
    notifyListeners();
  }
}
