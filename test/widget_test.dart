import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:hakori_almadinah/app.dart';
import 'package:hakori_almadinah/core/services/storage_service.dart';
import 'package:hakori_almadinah/core/services/api_client.dart';
import 'package:hakori_almadinah/core/services/auth_service.dart';
import 'package:hakori_almadinah/core/services/product_service.dart';
import 'package:hakori_almadinah/core/services/order_service.dart';
import 'package:hakori_almadinah/core/services/consultation_service.dart';
import 'package:hakori_almadinah/core/services/ticket_service.dart';
import 'package:hakori_almadinah/core/services/notification_service.dart';
import 'package:hakori_almadinah/core/services/image_picker_service.dart';
import 'package:hakori_almadinah/core/services/currency_provider.dart';
import 'package:hakori_almadinah/core/services/cart_provider.dart';
import 'package:hakori_almadinah/core/services/wishlist_provider.dart';
import 'package:hakori_almadinah/core/services/auth_provider.dart';
import 'package:hakori_almadinah/core/services/product_provider.dart';
import 'package:hakori_almadinah/core/services/order_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders splash screen and brand name',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storageService = await StorageService.getInstance();
    final apiClient = ApiClient.getInstance(storageService);
    final authService = AuthService(apiClient);
    final productService = ProductService(apiClient);
    final orderService = OrderService(apiClient);
    final consultationService = ConsultationService(apiClient);
    final ticketService = TicketService(apiClient);
    final notificationService = NotificationService(apiClient);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<StorageService>.value(value: storageService),
          Provider<ApiClient>.value(value: apiClient),
          Provider<AuthService>.value(value: authService),
          Provider<ProductService>.value(value: productService),
          Provider<OrderService>.value(value: orderService),
          Provider<ConsultationService>.value(value: consultationService),
          Provider<TicketService>.value(value: ticketService),
          Provider<NotificationService>.value(value: notificationService),
          Provider<ImagePickerService>(
            create: (_) => ImagePickerService(),
          ),
          ChangeNotifierProvider<AuthProvider>(
            create: (_) => AuthProvider(authService, storageService),
          ),
          ChangeNotifierProvider<ProductProvider>(
            create: (_) => ProductProvider(productService),
          ),
          ChangeNotifierProvider<OrderProvider>(
            create: (_) => OrderProvider(orderService),
          ),
          ChangeNotifierProvider<CurrencyProvider>(
            create: (_) => CurrencyProvider(),
          ),
          ChangeNotifierProvider<CartProvider>(
            create: (_) => CartProvider(storageService),
          ),
          ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider(),
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
