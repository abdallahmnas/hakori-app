import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/wishlist_provider.dart';
import '../../core/services/cart_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/product_card.dart';

/// Screen 18: wishlist_saved_vault
/// Saved Vault Pieces with live gold price lock counter and bulk cart move
class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final savedProducts = wishlistProvider.wishlistProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(
        title: 'SAVED VAULT',
        showWishlist: false,
      ),
      body: savedProducts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.favorite_border, size: 54, color: AppColors.primaryGold),
                  const SizedBox(height: 16),
                  Text(
                    'No Vault Pieces Saved',
                    style: AppTypography.headlineMD(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Bookmark your favorite 18K pieces to lock live gold spot rates.',
                    style: AppTypography.bodySM(color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    text: 'EXPLORE COLLECTIONS',
                    width: 220,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                // Gold Price Lock Notice
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.goldContainer.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineGold),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock_outlined, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gold Spot Rate Locked: Guaranteed for next 47h 12m',
                            style: AppTypography.labelSM(color: AppColors.onGoldContainer).copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Saved Grid (0.52 aspect ratio)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.52,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = savedProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => context.push('/product/${product.id}'),
                        );
                      },
                      childCount: savedProducts.length,
                    ),
                  ),
                ),

                // Move all to cart CTA
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
                    child: AppButton.primary(
                      text: 'MOVE ALL TO CART',
                      onPressed: () {
                        for (var p in savedProducts) {
                          cartProvider.addToCart(p);
                        }
                        context.push('/cart');
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
