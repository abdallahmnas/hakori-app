import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import 'mock_data_service.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [
    CartItem(
      id: 'cart_1',
      product: MockDataService.products[0],
      selectedMetal: '18K Yellow Gold',
      selectedStone: 'VVS1 Natural Diamonds',
      selectedArch: 'Top 6 Arch',
      quantity: 1,
      impressionKitIncluded: true,
    ),
    CartItem(
      id: 'cart_2',
      product: MockDataService.products[2],
      selectedMetal: '18K White Gold',
      selectedStone: 'VS1 Pave Border',
      selectedArch: 'Dual Canine Caps',
      quantity: 1,
      impressionKitIncluded: false,
    ),
  ];

  String _promoCode = '';
  double _discountPercentage = 0.0;
  bool _vaultInsurance = true;

  List<CartItem> get items => List.unmodifiable(_items);
  String get promoCode => _promoCode;
  double get discountPercentage => _discountPercentage;
  bool get vaultInsurance => _vaultInsurance;
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotalUsd => _items.fold(0.0, (sum, item) => sum + item.totalPriceUsd);
  double get subtotalNgn => _items.fold(0.0, (sum, item) => sum + item.totalPriceNgn);
  double get insuranceCostUsd => _vaultInsurance ? 150.0 : 0.0;
  double get insuranceCostNgn => _vaultInsurance ? 232500.0 : 0.0;
  double get totalUsd => (subtotalUsd * (1 - _discountPercentage)) + insuranceCostUsd;
  double get totalNgn => (subtotalNgn * (1 - _discountPercentage)) + insuranceCostNgn;

  void addToCart(Product product, {String metal = '18K Yellow Gold', String stone = 'VVS1 Natural Diamonds', String arch = 'Top 6 Arch'}) {
    final existingIndex = _items.indexWhere((item) => item.product.id == product.id && item.selectedMetal == metal && item.selectedArch == arch);
    if (existingIndex >= 0) {
      _items[existingIndex].quantity += 1;
    } else {
      _items.add(CartItem(
        id: 'cart_${DateTime.now().millisecondsSinceEpoch}',
        product: product,
        selectedMetal: metal,
        selectedStone: stone,
        selectedArch: arch,
        quantity: 1,
      ));
    }
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
      notifyListeners();
    }
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => item.id == itemId);
    notifyListeners();
  }

  void toggleImpressionKit(String itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].impressionKitIncluded = !_items[index].impressionKitIncluded;
      notifyListeners();
    }
  }

  void toggleVaultInsurance(bool val) {
    _vaultInsurance = val;
    notifyListeners();
  }

  bool applyPromoCode(String code) {
    if (code.toUpperCase() == 'HAKORI2026' || code.toUpperCase() == 'VIPVAULT') {
      _promoCode = code.toUpperCase();
      _discountPercentage = 0.10; // 10% VIP Discount
      notifyListeners();
      return true;
    }
    return false;
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
