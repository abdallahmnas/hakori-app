import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/product.dart';
import '../services/wishlist_provider.dart';
import '../services/cart_provider.dart';
import 'badge_chip.dart';
import 'dual_price_text.dart';

/// Haute Joaillerie 2-Column Product Card
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;

  const ProductCard({super.key, required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFav = wishlistProvider.isFavorite(product.id);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.outlineLight, width: 1),
          boxShadow: const [AppColors.softCardShadow],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with Purity Badge & Wishlist Heart
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(11),
                  ),
                  child: AspectRatio(
                    aspectRatio: 1 / 0.75,
                    child: Container(
                      color: AppColors.surfaceContainerLow,
                      child: Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Icon(
                            Icons.diamond_outlined,
                            size: 32,
                            color: AppColors.primaryGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Purity Tag
                Positioned(
                  top: 6,
                  left: 6,
                  child: AppBadgeChip.purity(
                    label: product.purity.contains('24K')
                        ? '24K Gold'
                        : '18K Gold',
                  ),
                ),
                // Wishlist Heart Button
                Positioned(
                  top: 6,
                  right: 6,
                  child: Material(
                    color: Colors.white.withValues(alpha: 0.85),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () {
                        wishlistProvider.toggleFavorite(product.id, product: product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isFav
                                  ? 'Removed from Vault Wishlist'
                                  : 'Saved to Vault Wishlist',
                              style: AppTypography.bodySM(color: Colors.white),
                            ),
                            duration: const Duration(seconds: 1),
                            backgroundColor: AppColors.darkBase,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          size: 15,
                          color: isFav
                              ? AppColors.rubyRed
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Details Section
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Rating & Reviews
                  Row(
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${product.rating} (${product.reviewCount})',
                        style: AppTypography.bodyXS(
                          color: AppColors.textSecondary,
                        ).copyWith(fontSize: 10),
                      ),
                      const Spacer(),
                      if (product.isBestSeller)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.darkBase,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'VIP PICK',
                            style: AppTypography.labelSM(
                              color: AppColors.primaryGold,
                            ).copyWith(fontSize: 7),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  // Title
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.headlineSM(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 12, height: 1.25),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    product.archType,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.bodyXS(
                      color: AppColors.textMuted,
                    ).copyWith(fontSize: 9),
                  ),
                  const SizedBox(height: 4),
                  // Dual Price & Quick Cart Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: DualPriceText(
                          priceUsd: product.priceUsd,
                          priceNgn: product.priceNgn,
                          isVertical: true,
                          showSecondary: false,
                          primaryStyle: AppTypography.priceDisplay().copyWith(
                            fontSize: 15,
                          ),
                          secondaryStyle: AppTypography.priceSecondary()
                              .copyWith(fontSize: 10),
                        ),
                      ),
                      Material(
                        color: AppColors.surfaceContainer,
                        borderRadius: BorderRadius.circular(8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(8),
                          onTap: () {
                            cartProvider.addToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "${product.name}" to Cart',
                                  style: AppTypography.bodySM(
                                    color: Colors.white,
                                  ),
                                ),
                                duration: const Duration(seconds: 1),
                                backgroundColor: AppColors.darkBase,
                              ),
                            );
                          },
                          child: const Padding(
                            padding: EdgeInsets.all(6),
                            child: Icon(
                              Icons.shopping_cart_outlined,
                              size: 15,
                              color: AppColors.primaryGold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
