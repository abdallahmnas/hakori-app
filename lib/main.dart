import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/services/image_picker_service.dart';
import 'core/services/currency_provider.dart';
import 'core/services/cart_provider.dart';
import 'core/services/wishlist_provider.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<CurrencyProvider>(
          create: (_) => CurrencyProvider(),
        ),
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<WishlistProvider>(
          create: (_) => WishlistProvider(),
        ),
        Provider<ImagePickerService>(create: (_) => ImagePickerService()),
      ],
      child: const HakoriAlmadinahApp(),
    ),
  );
}
