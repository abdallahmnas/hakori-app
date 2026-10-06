import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'storage_service.dart';

/// Local Storage-Backed Cart Provider matching requirements 12 & 13
class CartProvider extends ChangeNotifier {
  final StorageService? _storageService;
  final List<CartItem> _items = [];

  String _promoCode = '';
  double _discountPercentage = 0.0;
  bool _vaultInsurance = false;

  CartProvider([this._storageService]) {
    _restoreFromStorage();
  }

  void _restoreFromStorage() {
    final storage = _storageService;
    if (storage != null) {
      try {
        final saved = storage.getCart();
        if (saved.isNotEmpty) {
          _items.addAll(saved);
        }
      } catch (e) {
        _items.clear();
        storage.clearCart();
      }
    }
  }

  Future<void> _persistCart() async {
    final storage = _storageService;
    if (storage != null) {
      await storage.saveCart(_items);
    }
  }

  List<CartItem> get items => List.unmodifiable(_items);
  String get promoCode => _promoCode;
  double get discountPercentage => _discountPercentage;
  bool get vaultInsurance => _vaultInsurance;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalUsd =>
      _items.fold(0.0, (sum, item) => sum + item.totalPriceUsd);
  double get subtotalNgn =>
      _items.fold(0.0, (sum, item) => sum + item.totalPriceNgn);
  double get insuranceCostUsd => _vaultInsurance ? 150.0 : 0.0;
  double get insuranceCostNgn => _vaultInsurance ? 232500.0 : 0.0;
  double get totalUsd =>
      (subtotalUsd * (1 - _discountPercentage)) + insuranceCostUsd;
  double get totalNgn =>
      (subtotalNgn * (1 - _discountPercentage)) + insuranceCostNgn;

  void addToCart(
    Product product, {
    String metal = '18K Yellow Gold',
    String stone = 'VVS1 Natural Diamonds',
    String arch = 'Top 6 Arch',
  }) {
    final existingIndex = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.selectedMetal == metal &&
          item.selectedArch == arch,
    );

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(
        CartItem(
          id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
          product: product,
          selectedMetal: metal,
          selectedStone: stone,
          selectedArch: arch,
          quantity: 1,
        ),
      );
    }
    _persistCart();
    notifyListeners();
  }

  void updateQuantity(String itemId, int delta) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final newQty = _items[index].quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = newQty;
      }
      _persistCart();
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _persistCart();
    notifyListeners();
  }

  void toggleImpressionKit(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].impressionKitIncluded =
          !_items[index].impressionKitIncluded;
      _persistCart();
      notifyListeners();
    }
  }

  void toggleVaultInsurance(bool val) {
    _vaultInsurance = val;
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    if (code.toUpperCase() == 'HAKORI2026' ||
        code.toUpperCase() == 'VIPVAULT') {
      _promoCode = code.toUpperCase();
      _discountPercentage = 0.10; // 10% VIP Discount
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearCart() {
    _items.clear();
    _persistCart();
    notifyListeners();
  }
}
