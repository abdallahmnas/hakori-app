import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'mock_data_service.dart';

class WishlistProvider extends ChangeNotifier {
  final Set<String> _wishlistIds = {'prod_1', 'prod_4'};

  List<Product> get wishlistProducts =>
      MockDataService.products.where((p) => _wishlistIds.contains(p.id)).toList();

  bool isFavorite(String productId) => _wishlistIds.contains(productId);

  void toggleFavorite(String productId) {
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
    notifyListeners();
  }

  void removeFromWishlist(String productId) {
    _wishlistIds.remove(productId);
    notifyListeners();
  }
}
