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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedMetal': selectedMetal,
      'selectedStone': selectedStone,
      'selectedArch': selectedArch,
      'quantity': quantity,
      'impressionKitIncluded': impressionKitIncluded,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      selectedMetal: json['selectedMetal']?.toString() ?? '18K Yellow Gold',
      selectedStone: json['selectedStone']?.toString() ?? 'VVS1 Natural Diamonds',
      selectedArch: json['selectedArch']?.toString() ?? 'Top 6 Arch',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      impressionKitIncluded: json['impressionKitIncluded'] as bool? ?? true,
    );
  }
}
