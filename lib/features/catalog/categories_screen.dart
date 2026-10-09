import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/currency_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 8: categories_collections_directory
/// High-fashion category browsing directory with curated piece counts and starting prices from ProductProvider
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(
        context,
        listen: false,
      );
      if (productProvider.categories.isEmpty) {
        productProvider.fetchCatalog();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final categories = productProvider.categories;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(title: 'Categories', showBack: false),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: () => productProvider.fetchCatalog(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header description
            // SliverToBoxAdapter(
            //   child: Padding(
            //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            //     child: Column(
            //       crossAxisAlignment: CrossAxisAlignment.start,
            //       children: [
            //         Text(
            //           'Haute Joaillerie Directories',
            //           style: AppTypography.headlineLG(color: AppColors.textPrimary),
            //         ),
            //         const SizedBox(height: 4),
            //         Text(
            //           'Curated Place Vendôme fine jewelry disciplines. From mirror polish gold to handset certified gemstones.',
            //           style: AppTypography.bodySM(color: AppColors.textSecondary),
            //         ),
            //       ],
            //     ),
            //   ),
            // ),

            // Loading / Empty / Category Cards List
            if (productProvider.isLoading && categories.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 48),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppColors.primaryGold,
                      ),
                    ),
                  ),
                ),
              )
            else if (categories.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 48,
                    horizontal: 24,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(
                          Icons.category_outlined,
                          size: 48,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No Collections Found',
                          style: AppTypography.headlineSM(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Collections will appear once loaded from the server.',
                          style: AppTypography.bodyXS(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final cat = categories[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [AppColors.softCardShadow],
                        image: DecorationImage(
                          image: NetworkImage(
                            cat.imageUrl.isNotEmpty
                                ? cat.imageUrl
                                : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            context.push('/category-info', extra: cat);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 170),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.black.withValues(alpha: 0.65),
                                  AppColors.darkBase.withValues(alpha: 0.92),
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SizedBox(height: 40),
                                Row(
                                  children: [
                                    AppBadgeChip(
                                      label:
                                          '${cat.pieceCount > 0 ? cat.pieceCount : 0} PIECES',
                                      variant: BadgeChipVariant.goldPurity,
                                    ),
                                    const Spacer(),
                                    if (cat.startingPriceUsd > 0)
                                      Text(
                                        'FROM ${currencyProvider.formatPrice(cat.startingPriceUsd)}',
                                        style: AppTypography.labelMD(
                                          color: AppColors.goldAccent,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat.title,
                                  style: AppTypography.headlineMD(
                                    color: AppColors.textOnDark,
                                  ).copyWith(fontSize: 18),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  cat.subtitle,
                                  style: AppTypography.bodyXS(
                                    color: AppColors.surfaceContainerHigh,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }, childCount: categories.length),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
