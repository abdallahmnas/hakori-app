import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/order_provider.dart';
import '../../core/widgets/app_button.dart';

/// Screen 15: order_confirmation_screen
/// Clean order confirmation screen with luxury illustration and Return to Home action
class OrderConfirmationScreen extends StatefulWidget {
  final CommissionOrder? order;

  const OrderConfirmationScreen({super.key, this.order});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Clear cart once order is confirmed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).clearCart();
    });
  }

  Widget _buildIllustration() {
    return SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow ring
          Container(
            width: 210,
            height: 210,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.18),
                  AppColors.primaryGold.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Secondary concentric circular frame
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: const [AppColors.goldGlow],
            ),
          ),
          // Central luxury gold & dark icon shield
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBase,
                  AppColors.darkCard,
                ],
              ),
              border: Border.all(color: AppColors.primaryGold, width: 2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.25),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 52,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          // Success check badge
          Positioned(
            bottom: 40,
            right: 40,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryGold,
                border: Border.all(color: AppColors.background, width: 3),
                boxShadow: const [AppColors.softCardShadow],
              ),
              child: const Icon(
                Icons.check,
                size: 22,
                color: AppColors.textOnGold,
              ),
            ),
          ),
          // Floating luxury accents
          const Positioned(
            top: 24,
            left: 40,
            child: Icon(
              Icons.auto_awesome,
              size: 22,
              color: AppColors.primaryGold,
            ),
          ),
          Positioned(
            bottom: 30,
            left: 36,
            child: Icon(
              Icons.diamond_outlined,
              size: 20,
              color: AppColors.primaryGold.withValues(alpha: 0.75),
            ),
          ),
          Positioned(
            top: 36,
            right: 32,
            child: Icon(
              Icons.auto_awesome,
              size: 16,
              color: AppColors.primaryGold.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrder = widget.order ??
        orderProvider.lastCreatedOrder ??
        (orderProvider.orders.isNotEmpty ? orderProvider.orders.first : null);

    final orderNumber = activeOrder?.commissionNumber ?? '#HK-${DateTime.now().year}-0001';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'ORDER CONFIRMATION',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Illustration
                _buildIllustration(),
                const SizedBox(height: 28),

                // Order Confirmed Title
                Text(
                  'Order Confirmed',
                  style: AppTypography.headlineXL(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Order Number
                Text(
                  'Order $orderNumber',
                  style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Order message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Thank you for your order. We have received your purchase and are preparing your fine jewelry for delivery.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 48),

                // Return to Home button
                AppButton.primary(
                  text: 'RETURN TO HOME',
                  height: 52,
                  onPressed: () => context.go('/home'),
                  prefixIcon: const Icon(Icons.home_outlined, size: 20, color: AppColors.textOnGold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
