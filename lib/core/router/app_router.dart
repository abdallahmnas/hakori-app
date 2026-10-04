import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/splash/splash_screen.dart';
import '../../features/auth/welcome_screen.dart';
import '../../features/auth/sign_up_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/otp_verification_screen.dart';
import '../../features/auth/password_recovery_screen.dart';
import '../../features/auth/password_reset_success_screen.dart';
import '../../features/auth/complete_profile_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/catalog/categories_screen.dart';
import '../../features/catalog/product_detail_screen.dart';
import '../../features/customizer/bespoke_configurator_screen.dart';
import '../../features/customizer/ar_live_fitting_screen.dart';
import '../../features/cart/cart_screen.dart';
import '../../features/cart/empty_bag_screen.dart';
import '../../features/orders/order_confirmation_screen.dart';
import '../../features/orders/my_orders_screen.dart';
import '../../features/orders/commission_tracker_screen.dart';
import '../../features/wishlist/wishlist_screen.dart';
import '../models/order.dart';
import '../../features/profile/vip_profile_screen.dart';
import '../../features/profile/fx_ledger_screen.dart';
import '../../features/profile/dental_vault_scans_screen.dart';
import '../../features/concierge/concierge_booking_screen.dart';
import '../../features/concierge/live_video_call_screen.dart';
import '../widgets/bottom_nav_shell.dart';

class AppRouter {
  AppRouter._();

  static const String homeName = 'home';
  static const String profileName = 'profile';
  static const String catalogName = 'catalog';
  static const String bagName = 'cart';
  static const String ordersName = 'orders';

  static final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _homeNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _catalogNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _ordersNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _profileNavigatorKey = GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Screen
      GoRoute(
        path: '/',
        name: 'splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // Auth Flow
      GoRoute(
        path: '/welcome',
        name: 'welcome',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/signup',
        name: 'signup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/otp',
        name: 'otp',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: '/complete-profile',
        name: 'complete-profile',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: '/recovery',
        name: 'recovery',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PasswordRecoveryScreen(),
      ),
      GoRoute(
        path: '/password-success',
        name: 'password-success',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PasswordResetSuccessScreen(),
      ),

      // 4-Branch Bottom Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => BottomNavShell(
          navigationShell: navigationShell,
        ),
        branches: [
          // Branch 1: Home
          StatefulShellBranch(
            navigatorKey: _homeNavigatorKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 2: Catalog
          StatefulShellBranch(
            navigatorKey: _catalogNavigatorKey,
            routes: [
              GoRoute(
                path: '/catalog',
                name: 'catalog',
                builder: (context, state) => const CategoriesScreen(),
              ),
            ],
          ),
          // Branch 3: Orders
          StatefulShellBranch(
            navigatorKey: _ordersNavigatorKey,
            routes: [
              GoRoute(
                path: '/orders',
                name: 'orders',
                builder: (context, state) => const MyOrdersScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const VipProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // Cart Route (Accessible from AppBars and CTAs)
      GoRoute(
        path: '/cart',
        name: 'cart',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CartScreen(),
      ),

      // Standalone / Detail Modal Routes
      GoRoute(
        path: '/product/:id',
        name: 'product-detail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? 'prod_1';
          return ProductDetailScreen(productId: productId);
        },
      ),
      GoRoute(
        path: '/categories',
        name: 'categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: '/configurator',
        name: 'configurator',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const BespokeConfiguratorScreen(),
      ),
      GoRoute(
        path: '/ar-fitting',
        name: 'ar-fitting',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ArLiveFittingScreen(),
      ),
      GoRoute(
        path: '/empty-bag',
        name: 'empty-bag',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const EmptyBagScreen(),
      ),
      GoRoute(
        path: '/order-confirmation',
        name: 'order-confirmation',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final order = state.extra as CommissionOrder?;
          return OrderConfirmationScreen(order: order);
        },
      ),
      GoRoute(
        path: '/commission-tracker/:id',
        name: 'commission-tracker',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final orderId = state.pathParameters['id'] ?? 'ord_1';
          return CommissionTrackerScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/wishlist',
        name: 'wishlist',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WishlistScreen(),
      ),
      GoRoute(
        path: '/fx-ledger',
        name: 'fx-ledger',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FxLedgerScreen(),
      ),
      GoRoute(
        path: '/dental-scans',
        name: 'dental-scans',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DentalVaultScansScreen(),
      ),
      GoRoute(
        path: '/concierge-booking',
        name: 'concierge-booking',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ConciergeBookingScreen(),
      ),
      GoRoute(
        path: '/live-call',
        name: 'live-call',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const LiveVideoCallScreen(),
      ),
    ],
  );
}
