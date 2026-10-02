import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/currency_provider.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 8: categories_collections_directory
/// High-fashion category browsing directory with curated piece counts and starting prices
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(
        title: 'COLLECTIONS',
        showBack: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Header description
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Haute Joaillerie Directories',
                    style: AppTypography.headlineLG(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Curated Place Vendôme dental jewelry disciplines. From mirror polish gold to handset Colombian emeralds.',
                    style: AppTypography.bodySM(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),

          // Category Cards List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final cat = MockDataService.categories[index];
                  final formattedStartPrice = currencyProvider.formatPrice(cat.startingPriceUsd);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [AppColors.softCardShadow],
                      image: DecorationImage(
                        image: NetworkImage(cat.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context.push('/home'),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 170),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.65),
                                AppColors.darkBase.withOpacity(0.92),
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
                                    label: '${cat.pieceCount} PIECES',
                                    variant: BadgeChipVariant.goldPurity,
                                  ),
                                  const Spacer(),
                                  Text(
                                    'FROM $formattedStartPrice',
                                    style: AppTypography.labelMD(color: AppColors.goldAccent),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(
                                cat.title,
                                style: AppTypography.headlineMD(color: AppColors.textOnDark).copyWith(fontSize: 18),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      cat.subtitle,
                                      style: AppTypography.bodyXS(color: AppColors.surfaceContainerHigh),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                    color: AppColors.primaryGold,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
                childCount: MockDataService.categories.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 28)),
        ],
      ),
    );
  }
}
