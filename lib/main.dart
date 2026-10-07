import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/storage_service.dart';
import 'core/services/api_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/product_service.dart';
import 'core/services/order_service.dart';
import 'core/services/consultation_service.dart';
import 'core/services/ticket_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/banner_service.dart';
import 'core/services/banner_provider.dart';
import 'core/services/auth_provider.dart';
import 'core/services/cart_provider.dart';
import 'core/services/product_provider.dart';
import 'core/services/order_provider.dart';
import 'core/services/currency_provider.dart';
import 'core/services/wishlist_provider.dart';
import 'core/services/image_picker_service.dart';
import 'core/router/app_router.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Storage Service (SharedPreferences)
  final storageService = await StorageService.getInstance();

  // Initialize Api Client
  final apiClient = ApiClient.getInstance(storageService);

  // Initialize Services
  final authService = AuthService(apiClient);
  final productService = ProductService(apiClient);
  final orderService = OrderService(apiClient);
  final consultationService = ConsultationService(apiClient);
  final ticketService = TicketService(apiClient);
  final notificationService = NotificationService(apiClient);
  final bannerService = BannerService(apiClient);

  // Initialize Auth Provider
  final authProvider = AuthProvider(authService, storageService);

  // Wire 401 Unauthorized Central Redirection
  apiClient.onUnauthorized = () {
    authProvider.onSessionExpired();
    try {
      AppRouter.router.go('/login');
    } catch (_) {}
  };

  runApp(
    MultiProvider(
      providers: [
        // Services
        Provider<StorageService>.value(value: storageService),
        Provider<ApiClient>.value(value: apiClient),
        Provider<AuthService>.value(value: authService),
        Provider<ProductService>.value(value: productService),
        Provider<OrderService>.value(value: orderService),
        Provider<ConsultationService>.value(value: consultationService),
        Provider<TicketService>.value(value: ticketService),
        Provider<NotificationService>.value(value: notificationService),
        Provider<BannerService>.value(value: bannerService),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),

        // Providers
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProvider<BannerProvider>(
          create: (_) => BannerProvider(bannerService, storageService),
        ),
        ChangeNotifierProvider<CartProvider>(
          create: (_) => CartProvider(storageService),
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
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider(storageService),
        ),
      ],
      child: const HakoriAlmadinahApp(),
    ),
  );
}
