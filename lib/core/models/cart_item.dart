import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final String selectedMetal;
  final String selectedStone;
  final String selectedArch;
  int quantity;
  bool impressionKitIncluded;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedMetal,
    required this.selectedStone,
    required this.selectedArch,
    this.quantity = 1,
    this.impressionKitIncluded = true,
  });

  double get totalPriceUsd => product.priceUsd * quantity;
  double get totalPriceNgn => product.priceNgn * quantity;
}
