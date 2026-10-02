import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hakori_almadinah/app.dart';
import 'package:hakori_almadinah/core/services/image_picker_service.dart';
import 'package:hakori_almadinah/core/services/currency_provider.dart';
import 'package:hakori_almadinah/core/services/cart_provider.dart';
import 'package:hakori_almadinah/core/services/wishlist_provider.dart';

void main() {
  testWidgets('App renders splash screen and brand name',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CurrencyProvider>(
            create: (_) => CurrencyProvider(),
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(),
          ),
          ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider(),
          ),
          Provider<ImagePickerService>(
            create: (_) => ImagePickerService(),
          ),
        ],
        child: const HakoriAlmadinahApp(),
      ),
    );

    expect(find.text('HAKORI AL MADINAH'), findsWidgets);

    // Pump past the splash timer
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pumpAndSettle();
  });
}
