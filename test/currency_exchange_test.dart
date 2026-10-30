import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hakori_almadinah/core/models/currency.dart';
import 'package:hakori_almadinah/core/models/product.dart';
import 'package:hakori_almadinah/core/services/currency_provider.dart';
import 'package:hakori_almadinah/core/services/cart_provider.dart';
import 'package:hakori_almadinah/core/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final sampleExchangeJson = {
    "success": true,
    "data": {
      "baseCurrency": "USD",
      "rates": [
        {
          "id": "EXC-USD",
          "code": "USD",
          "name": "US Dollar",
          "symbol": "\$",
          "price": 1,
          "isBase": true,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        },
        {
          "id": "EXC-AED",
          "code": "AED",
          "name": "UAE Dirham",
          "symbol": "د.إ",
          "price": 3.6725,
          "isBase": false,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        },
        {
          "id": "EXC-CAD",
          "code": "CAD",
          "name": "Canadian Dollar",
          "symbol": "CA\$",
          "price": 1.382,
          "isBase": false,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        },
        {
          "id": "EXC-EUR",
          "code": "EUR",
          "name": "Euro",
          "symbol": "€",
          "price": 0.9215,
          "isBase": false,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        },
        {
          "id": "EXC-GBP",
          "code": "GBP",
          "name": "British Pound",
          "symbol": "£",
          "price": 0.7842,
          "isBase": false,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        },
        {
          "id": "EXC-NGN",
          "code": "NGN",
          "name": "Nigerian Naira",
          "symbol": "₦",
          "price": 1600,
          "isBase": false,
          "isActive": true,
          "createdAt": "2026-10-29T21:53:45.159Z",
          "updatedAt": "2026-10-29T21:53:45.159Z"
        }
      ],
      "lastUpdated": "2026-10-29T21:56:22.180Z"
    }
  };

  group('CurrencyInfo and ExchangeData Model Tests', () {
    test('parses ExchangeData from sample API response', () {
      final exchangeData = ExchangeData.fromJson(
        sampleExchangeJson['data'] as Map<String, dynamic>,
      );

      expect(exchangeData.baseCurrency, 'USD');
      expect(exchangeData.lastUpdated, '2026-10-29T21:56:22.180Z');
      expect(exchangeData.rates.length, 6);

      final aed = exchangeData.rates.firstWhere((r) => r.code == 'AED');
      expect(aed.code, 'AED');
      expect(aed.name, 'UAE Dirham');
      expect(aed.symbol, 'د.إ');
      expect(aed.price, 3.6725);
      expect(aed.flagEmoji, '🇦🇪');

      final ngn = exchangeData.rates.firstWhere((r) => r.code == 'NGN');
      expect(ngn.code, 'NGN');
      expect(ngn.price, 1600.0);
      expect(ngn.flagEmoji, '🇳🇬');
    });
  });

  group('CurrencyProvider & LocalStorage Caching', () {
    late StorageService storageService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetInstanceForTesting();
      storageService = await StorageService.getInstance();
    });

    test('caches exchange rates and persists selected currency', () async {
      // Save exchange rates to storage
      await storageService.saveExchangeData(
        sampleExchangeJson['data'] as Map<String, dynamic>,
      );

      // Restore provider from storage
      final restoredProvider = CurrencyProvider(null, storageService);
      expect(restoredProvider.currencies.length, 6);

      // Switch currency to AED
      final aed = restoredProvider.currencies.firstWhere((c) => c.code == 'AED');
      await restoredProvider.setCurrency(aed);

      expect(restoredProvider.selectedCurrency.code, 'AED');
      expect(storageService.getSelectedCurrencyCode(), 'AED');

      // Re-create provider: automatically loads AED as active currency
      final newlyLoadedProvider = CurrencyProvider(null, storageService);
      expect(newlyLoadedProvider.selectedCurrency.code, 'AED');
    });

    test('auto calculates product price based on active currency', () async {
      await storageService.saveExchangeData(
        sampleExchangeJson['data'] as Map<String, dynamic>,
      );

      final restoredProvider = CurrencyProvider(null, storageService);
      const productPriceUsd = 500.0; // from testing product

      // Default USD
      expect(restoredProvider.convertPrice(productPriceUsd), 500.0);
      expect(restoredProvider.formatPrice(productPriceUsd), '\$500.00');

      // Switch to AED (rate: 3.6725) -> 500 * 3.6725 = 1836.25
      final aed = restoredProvider.currencies.firstWhere((c) => c.code == 'AED');
      await restoredProvider.setCurrency(aed);
      expect(restoredProvider.convertPrice(productPriceUsd), 1836.25);
      expect(restoredProvider.formatPrice(productPriceUsd), 'د.إ 1,836.25');

      // Switch to NGN (rate: 1600) -> 500 * 1600 = 800,000
      final ngn = restoredProvider.currencies.firstWhere((c) => c.code == 'NGN');
      await restoredProvider.setCurrency(ngn);
      expect(restoredProvider.convertPrice(productPriceUsd), 800000.0);
      expect(restoredProvider.formatPrice(productPriceUsd), '₦800,000');
    });

    test('cart and checkout maintain actual product price regardless of display currency', () async {
      final currencyProvider = CurrencyProvider(null, storageService);
      final aed = CurrencyInfo(
        code: 'AED',
        name: 'UAE Dirham',
        symbol: 'د.إ',
        rateToUsd: 3.6725,
      );
      await currencyProvider.setCurrency(aed);

      final product = Product.fromJson({
        "id": "prod-actual",
        "name": "Fine Piece",
        "category": "necklace",
        "price": 500,
        "description": "Test",
      });

      final cartProvider = CartProvider();
      cartProvider.addToCart(product);

      // Cart Item unit and total price remains the actual product price (USD 500)
      final cartItem = cartProvider.items.first;
      expect(cartItem.product.price, 500.0);
      expect(cartItem.totalPriceUsd, 500.0);
      expect(cartProvider.subtotalUsd, 500.0);
      expect(cartProvider.totalUsd, 500.0);

      // Checkout payload uses actual price
      final orderItem = {
        'productId': cartItem.product.id,
        'title': cartItem.product.title,
        'unitPrice': cartItem.product.priceUsd,
        'quantity': cartItem.quantity,
      };
      expect(orderItem['unitPrice'], 500.0);
    });
  });
}
