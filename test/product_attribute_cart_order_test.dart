import 'package:flutter_test/flutter_test.dart';
import 'package:hakori_almadinah/core/models/cart_item.dart';
import 'package:hakori_almadinah/core/models/product.dart';
import 'package:hakori_almadinah/core/services/cart_provider.dart';

void main() {
  group('Product Model Attribute Parsing', () {
    final sampleJson = {
      "id": "1038a76a-a5b3-435c-8cdf-1e1b1a6059ea",
      "name": "Testing 2",
      "sku": "Ghh",
      "category": "attribute test",
      "price": 500,
      "costPrice": 340,
      "castingPrice": 500,
      "stock": 6,
      "description": "",
      "imageUrl":
          "https://res.cloudinary.com/idnv3blu/image/upload/v1792096975/hakori_products/axxnwr3f8jb2syogebc5.jpg",
      "images": [
        "https://res.cloudinary.com/idnv3blu/image/upload/v1792096975/hakori_products/axxnwr3f8jb2syogebc5.jpg"
      ],
      "material": "Flour",
      "placement": "Fine Product",
      "rating": 5,
      "inStock": true,
      "status": "Active",
      "createdAt": "2026-10-15T20:43:17.940Z",
      "updatedAt": "2026-10-29T09:27:33.949Z",
      "inventory": 6,
      "image":
          "https://res.cloudinary.com/idnv3blu/image/upload/v1792096975/hakori_products/axxnwr3f8jb2syogebc5.jpg",
      "lowStock": false,
      "categoryAttributes": [
        {
          "label": "upper",
          "value": ["small", "big", "medium"]
        },
        {
          "label": "lower",
          "value": ["lower"]
        }
      ],
      "categoryDetails": {
        "id": "CAT-1793266009475",
        "name": "attribute test",
        "slug": "attribute-test",
        "attributes": [
          {
            "label": "upper",
            "value": ["small", "big", "medium"]
          },
          {
            "label": "lower",
            "value": ["lower"]
          }
        ]
      }
    };

    test('parses categoryAttributes and categoryDetails correctly', () {
      final product = Product.fromJson(sampleJson);

      expect(product.id, '1038a76a-a5b3-435c-8cdf-1e1b1a6059ea');
      expect(product.name, 'Testing 2');
      expect(product.hasAttributes, isTrue);
      expect(product.categoryAttributes.length, 2);
      expect(product.categoryAttributes[0].label, 'upper');
      expect(product.categoryAttributes[0].values, ['small', 'big', 'medium']);
      expect(product.categoryAttributes[1].label, 'lower');
      expect(product.categoryAttributes[1].values, ['lower']);

      expect(product.categoryDetails, isNotNull);
      expect(product.categoryDetails!.id, 'CAT-1793266009475');
      expect(product.categoryDetails!.name, 'attribute test');
      expect(product.categoryDetails!.attributes.length, 2);
    });

    test('product without attributes returns hasAttributes == false', () {
      final simpleJson = {
        "id": "simple-1",
        "name": "Classic Ring",
        "category": "ring",
        "price": 200,
        "description": "Simple Ring",
      };

      final product = Product.fromJson(simpleJson);
      expect(product.hasAttributes, isFalse);
      expect(product.effectiveAttributes, isEmpty);
    });

    test('toJson serializes categoryAttributes and categoryDetails', () {
      final product = Product.fromJson(sampleJson);
      final json = product.toJson();

      expect(json['categoryAttributes'], isA<List>());
      expect((json['categoryAttributes'] as List).length, 2);
      expect(json['categoryDetails'], isA<Map>());
      expect((json['categoryDetails'] as Map)['id'], 'CAT-1793266009475');
    });
  });

  group('CartItem and CartProvider with Attributes', () {
    final product = Product.fromJson({
      "id": "test-prod-1",
      "name": "Bespoke Ring",
      "category": "ring",
      "price": 1000,
      "description": "Desc",
      "categoryAttributes": [
        {
          "label": "upper",
          "value": ["small", "big"]
        }
      ]
    });

    test('CartItem stores selectedAttributes and generates backend payload', () {
      final cartItem = CartItem(
        id: 'cart-1',
        product: product,
        selectedMetal: '18K Yellow Gold',
        selectedStone: 'VVS1',
        selectedArch: 'Top Arch',
        selectedAttributes: {'upper': 'small', 'lower': 'standard'},
      );

      expect(cartItem.selectedAttributes['upper'], 'small');
      expect(cartItem.selectedAttributes['lower'], 'standard');

      final payload = cartItem.selectedAttributesPayload;
      expect(payload.length, 2);
      expect(payload[0], {'label': 'upper', 'value': 'small'});
      expect(payload[1], {'label': 'lower', 'value': 'standard'});

      expect(cartItem.attributesSummary, 'upper: small • lower: standard');
    });

    test('CartItem toJson and fromJson preserve selectedAttributes', () {
      final cartItem = CartItem(
        id: 'cart-2',
        product: product,
        selectedMetal: '18K Yellow Gold',
        selectedStone: 'VVS1',
        selectedArch: 'Top Arch',
        selectedAttributes: {'upper': 'big'},
      );

      final json = cartItem.toJson();
      final restored = CartItem.fromJson(json);

      expect(restored.selectedAttributes, {'upper': 'big'});
      expect(restored.selectedAttributesPayload, [
        {'label': 'upper', 'value': 'big'}
      ]);
    });

    test('CartProvider differentiates items with different attributes', () {
      final cartProvider = CartProvider();

      // Add item with 'upper': 'small'
      cartProvider.addToCart(
        product,
        selectedAttributes: {'upper': 'small'},
      );
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[0].quantity, 1);

      // Add exact same item -> increments quantity
      cartProvider.addToCart(
        product,
        selectedAttributes: {'upper': 'small'},
      );
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items[0].quantity, 2);

      // Add same product with 'upper': 'big' -> creates separate cart line item
      cartProvider.addToCart(
        product,
        selectedAttributes: {'upper': 'big'},
      );
      expect(cartProvider.items.length, 2);
      expect(cartProvider.items[1].selectedAttributes['upper'], 'big');
      expect(cartProvider.items[1].quantity, 1);
    });
  });
}
