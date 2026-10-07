import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/services/wishlist_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/product_card.dart';

/// Screen 18: wishlist_saved_vault
/// Saved Favorites Pieces connected to real products & local storage
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
      if (productProvider.allProducts.isNotEmpty) {
        wishlistProvider.syncProducts(productProvider.allProducts);
      }
    });
  }

  Widget _buildEmptyIllustration() {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer ambient glow ring
          Container(
            width: 190,
            height: 190,
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
          // Concentric circular border
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: const [AppColors.goldGlow],
            ),
          ),
          // Dark luxury center circle
          Container(
            width: 100,
            height: 100,
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
                  color: AppColors.primaryGold.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.favorite_border,
                size: 46,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          // Floating luxury jewelry accents
          const Positioned(
            top: 20,
            right: 36,
            child: Icon(
              Icons.auto_awesome,
              size: 18,
              color: AppColors.primaryGold,
            ),
          ),
          Positioned(
            bottom: 24,
            left: 32,
            child: Icon(
              Icons.diamond_outlined,
              size: 20,
              color: AppColors.primaryGold.withValues(alpha: 0.75),
            ),
          ),
          Positioned(
            top: 36,
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
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final savedProducts = wishlistProvider.wishlistProducts;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: savedProducts.isEmpty ? 'FAVOURITES' : 'FAVOURITES (${savedProducts.length})',
        showWishlist: false,
      ),
      body: savedProducts.isEmpty
          ? Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildEmptyIllustration(),
                    const SizedBox(height: 24),
                    Text(
                      'No Favourites Saved',
                      style: AppTypography.headlineXL(color: AppColors.textPrimary),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Save your favourite fine jewelry pieces to view them here and easily add them to your cart.',
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppButton.primary(
                      text: 'EXPLORE COLLECTIONS',
                      width: 220,
                      height: 50,
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
            )
          : CustomScrollView(
              slivers: [
                // Gold Price Lock / Vault Notice
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.goldContainer.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineGold),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_clock_outlined, color: AppColors.primaryGold, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Gold Spot Rate Locked: Guaranteed for saved bespoke pieces',
                            style: AppTypography.labelSM(color: AppColors.onGoldContainer).copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Saved Real Products Grid
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
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
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                    child: AppButton.primary(
                      text: 'MOVE ALL TO CART',
                      height: 50,
                      prefixIcon: const Icon(Icons.shopping_bag_outlined, size: 18, color: AppColors.textOnGold),
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
