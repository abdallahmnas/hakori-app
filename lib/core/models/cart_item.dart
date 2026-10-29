import 'product.dart';

class CartItem {
  final String id;
  final Product product;
  final String selectedMetal;
  final String selectedStone;
  final String selectedArch;
  final Map<String, dynamic> selectedAttributes;
  int quantity;
  bool impressionKitIncluded;

  CartItem({
    required this.id,
    required this.product,
    required this.selectedMetal,
    required this.selectedStone,
    required this.selectedArch,
    this.selectedAttributes = const {},
    this.quantity = 1,
    this.impressionKitIncluded = true,
  });

  double get totalPriceUsd => product.priceUsd * quantity;
  double get totalPriceNgn => product.priceNgn * quantity;

  /// Returns selected attributes formatted for backend payload as a List of {"label": ..., "value": ...}
  List<Map<String, dynamic>> get selectedAttributesPayload {
    if (selectedAttributes.isEmpty) return const [];
    return selectedAttributes.entries.map((entry) {
      return {
        'label': entry.key,
        'value': entry.value,
      };
    }).toList();
  }

  /// Human-readable summary for order & cart UI (e.g. 'upper: small • lower: lower')
  String get attributesSummary {
    if (selectedAttributes.isEmpty) return '';
    return selectedAttributes.entries.map((e) {
      final val = e.value is List
          ? (e.value as List).join(', ')
          : e.value.toString();
      return '${e.key}: $val';
    }).join(' • ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': product.toJson(),
      'selectedMetal': selectedMetal,
      'selectedStone': selectedStone,
      'selectedArch': selectedArch,
      'selectedAttributes': selectedAttributes,
      'attributes': selectedAttributesPayload,
      'quantity': quantity,
      'impressionKitIncluded': impressionKitIncluded,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> parsedAttributes = {};
    if (json['selectedAttributes'] is Map) {
      parsedAttributes =
          Map<String, dynamic>.from(json['selectedAttributes'] as Map);
    } else if (json['attributes'] is List) {
      for (final a in json['attributes'] as List) {
        if (a is Map && a['label'] != null) {
          parsedAttributes[a['label'].toString()] = a['value'];
        }
      }
    }

    return CartItem(
      id: json['id']?.toString() ?? '',
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      selectedMetal: json['selectedMetal']?.toString() ?? '18K Yellow Gold',
      selectedStone:
          json['selectedStone']?.toString() ?? 'VVS1 Natural Diamonds',
      selectedArch: json['selectedArch']?.toString() ?? 'Top 6 Arch',
      selectedAttributes: parsedAttributes,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      impressionKitIncluded: json['impressionKitIncluded'] as bool? ?? true,
    );
  }
}
