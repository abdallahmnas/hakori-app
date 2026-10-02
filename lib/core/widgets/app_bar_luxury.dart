import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../constants/app_typography.dart';
import '../services/currency_provider.dart';
import '../services/wishlist_provider.dart';
import '../services/cart_provider.dart';

/// Haute Joaillerie Luxury App Bar with brand logo, currency selector, and badge actions
class LuxuryAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogo;
  final bool showCurrencyPicker;
  final bool showWishlist;
  final bool showCart;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget>? extraActions;
  final bool isDark;

  const LuxuryAppBar({
    super.key,
    this.title,
    this.showLogo = true,
    this.showCurrencyPicker = true,
    this.showWishlist = true,
    this.showCart = true,
    this.showBack = false,
    this.onBack,
    this.extraActions,
    this.isDark = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    final bgColor = isDark ? AppColors.darkBase : AppColors.surface;
    final textColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;
    final iconColor = isDark ? AppColors.primaryGold : AppColors.textPrimary;

    return AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleSpacing: showBack ? 0 : 16,
      leading: showBack
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new, size: 18, color: iconColor),
              onPressed: onBack ?? () => Navigator.of(context).maybePop(),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.headlineMD(color: textColor),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  AppConstants.logoLocalPath,
                  width: 22,
                  height: 22,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.diamond,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'HAKORI',
                  style: AppTypography.labelLG(color: textColor).copyWith(
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
      actions: [
        if (showCurrencyPicker)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: InkWell(
              onTap: () => context.push('/fx-ledger'),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.outlineLight),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      currencyProvider.selectedCurrency.flagEmoji,
                      style: const TextStyle(fontSize: 11),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      currencyProvider.selectedCurrency.code,
                      style: AppTypography.labelSM(
                        color: isDark ? AppColors.goldAccent : AppColors.textPrimary,
                      ).copyWith(fontSize: 10),
                    ),
                    const Icon(Icons.arrow_drop_down, size: 12, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        if (showWishlist)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(Icons.favorite_border, size: 20, color: iconColor),
                onPressed: () => context.push('/wishlist'),
              ),
              if (wishlistProvider.wishlistProducts.isNotEmpty)
                Positioned(
                  top: 6,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '${wishlistProvider.wishlistProducts.length}',
                      style: AppTypography.labelSM(color: AppColors.textOnGold).copyWith(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        if (showCart)
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                padding: const EdgeInsets.all(8),
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                icon: Icon(Icons.shopping_cart_outlined, size: 20, color: iconColor),
                onPressed: () => context.push('/cart'),
              ),
              if (cartProvider.itemCount > 0)
                Positioned(
                  top: 6,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryGold,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: AppTypography.labelSM(color: AppColors.textOnGold).copyWith(fontSize: 8),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        if (extraActions != null) ...extraActions!,
        const SizedBox(width: 8),
      ],
    );
  }
}
