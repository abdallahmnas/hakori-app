import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';

/// Screen 14: empty_bag_screen
/// Clean empty cart screen with luxury illustration and explore action (no recommended items)
class EmptyBagScreen extends StatelessWidget {
  const EmptyBagScreen({super.key});

  Widget _buildIllustration() {
    return SizedBox(
      width: 210,
      height: 210,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ambient gold radial glow
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.16),
                  AppColors.primaryGold.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          // Subtle concentric circular border
          Container(
            width: 148,
            height: 148,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.32),
                width: 1.5,
              ),
              boxShadow: const [AppColors.goldGlow],
            ),
          ),
          // Dark luxury centerpiece circle
          Container(
            width: 106,
            height: 106,
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
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withValues(alpha: 0.22),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          // Floating luxury accents
          const Positioned(
            top: 22,
            right: 36,
            child: Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.primaryGold,
            ),
          ),
          Positioned(
            bottom: 26,
            left: 32,
            child: Icon(
              Icons.diamond_outlined,
              size: 22,
              color: AppColors.primaryGold.withValues(alpha: 0.75),
            ),
          ),
          Positioned(
            top: 38,
            left: 28,
            child: Icon(
              Icons.auto_awesome,
              size: 14,
              color: AppColors.primaryGold.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(
        title: 'CART (0)',
        showBack: false,
        showCart: false,
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

                // Title
                Text(
                  'Your Cart is Empty',
                  style: AppTypography.headlineXL(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Description message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'You have no items in your cart. Explore our fine jewelry collections handcrafted in solid gold, diamonds, and sterling silver.',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Action button
                AppButton.primary(
                  text: 'EXPLORE COLLECTIONS',
                  height: 50,
                  width: 220,
                  onPressed: () => context.go('/home'),
                  prefixIcon: const Icon(
                    Icons.explore_outlined,
                    size: 18,
                    color: AppColors.textOnGold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
