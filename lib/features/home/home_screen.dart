import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/product.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/badge_chip.dart';
import '../catalog/catalog_filter_drawer.dart';

/// Screen 7: home_luxury_grillz_discovery
/// Main discovery screen with editorial hero carousel, category pills, 2-column showcase, and bespoke banners
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'ALL';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _categoryFilters = [
    'ALL',
    'DIAMOND PAVÉ',
    'SOLID GOLD',
    'OPEN FACE',
    'FANGS & CAPS',
    'OPAL & GEMS',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CatalogFilterDrawer(),
    );
  }

  List<Product> get _filteredProducts {
    if (_selectedCategory == 'ALL') {
      return MockDataService.products;
    }
    return MockDataService.products.where((p) {
      if (_selectedCategory == 'DIAMOND PAVÉ')
        return p.category.contains('Diamond');
      if (_selectedCategory == 'SOLID GOLD')
        return p.category.contains('Solid Gold');
      if (_selectedCategory == 'OPEN FACE')
        return p.category.contains('Open Face');
      if (_selectedCategory == 'FANGS & CAPS')
        return p.category.contains('Fangs');
      if (_selectedCategory == 'OPAL & GEMS')
        return p.category.contains('Emerald');
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(),
      body: CustomScrollView(
        slivers: [
          // Search Bar & Filter Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outlineLight),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: AppTypography.bodyMD(),
                        decoration: InputDecoration(
                          hintText: 'Search 18K grillz, baguettes...',
                          hintStyle: AppTypography.bodySM(
                            color: AppColors.textMuted,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            size: 18,
                            color: AppColors.primaryGold,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _openFilterDrawer,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 44,
                      width: 44,
                      decoration: BoxDecoration(
                        color: AppColors.darkBase,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.darkBorder),
                      ),
                      child: const Icon(
                        Icons.tune,
                        color: AppColors.primaryGold,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Editorial Hero Carousel Banner (Responsive without fixed overflow height)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [AppColors.softCardShadow],
                  image: const DecorationImage(
                    image: NetworkImage(
                      'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop',
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.4),
                        Colors.black.withOpacity(0.92),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 24),
                      const AppBadgeChip(
                        label: 'AUTUMN ATELIER DROP',
                        variant: BadgeChipVariant.goldPurity,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '18K VVS1 Diamond Pavé Arch',
                        style: AppTypography.headlineMD(
                          color: AppColors.textOnDark,
                        ).copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Engineered with 3D intraoral dental accuracy.',
                        style: AppTypography.bodyXS(
                          color: AppColors.surfaceContainerHigh,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          AppButton.primary(
                            text: 'EXPLORE PIECE',
                            height: 36,
                            width: 136,
                            borderRadius: 18,
                            onPressed: () => context.push('/product/prod_1'),
                          ),
                          AppButton.outline(
                            text: '3D TRY ON',
                            height: 36,
                            width: 114,
                            borderRadius: 18,
                            onPressed: () => context.push('/ar-fitting'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Horizontal Category Filter Pills
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: SizedBox(
                height: 34,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: _categoryFilters.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final cat = _categoryFilters[index];
                    final isSelected = cat == _selectedCategory;
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.darkBase
                              : AppColors.surface,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryGold
                                : AppColors.outlineLight,
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            cat,
                            style: AppTypography.labelSM(
                              color: isSelected
                                  ? AppColors.primaryGold
                                  : AppColors.textSecondary,
                            ).copyWith(fontSize: 9),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // Section Header: Haute Joaillerie Showcase
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              child: SectionHeader(
                title: 'Atelier Vault Highlights',
                subtitle: 'Single-origin 18K solid gold & certified gemstones',
                actionText: 'ALL (38)',
                onActionTap: () => context.push('/categories'),
              ),
            ),
          ),

          // 2-Column Product Grid (ChildAspectRatio set to 0.52 for zero vertical overflow)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.52,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final product =
                    _filteredProducts[index % _filteredProducts.length];
                return ProductCard(
                  product: product,
                  onTap: () => context.push('/product/${product.id}'),
                );
              }, childCount: _filteredProducts.length),
            ),
          ),

          // Bespoke 3D Configurator Interactive Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.darkBase,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.darkBorder),
                  boxShadow: const [AppColors.goldGlow],
                ),
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: const [
                        AppBadgeChip(
                          label: '3D ARCH ARCHITECT',
                          variant: BadgeChipVariant.goldPurity,
                        ),
                        Spacer(),
                        Icon(
                          Icons.view_in_ar,
                          color: AppColors.primaryGold,
                          size: 22,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Bespoke Tooth-by-Tooth\n3D Configurator',
                      style: AppTypography.headlineMD(
                        color: AppColors.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sculpt your custom arch tooth by tooth. Select 18K yellow, white, rose gold, open face windows, and VVS diamond pavé in real-time CAD.',
                      style: AppTypography.bodyXS(
                        color: AppColors.textMuted,
                      ).copyWith(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    AppButton.primary(
                      text: 'LAUNCH 3D CONFIGURATOR',
                      height: 46,
                      onPressed: () => context.push('/configurator'),
                      prefixIcon: const Icon(
                        Icons.architecture,
                        color: AppColors.textOnGold,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // VIP Concierge Banner
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 28),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.goldContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.support_agent,
                        color: AppColors.primaryGold,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VIP Concierge & Gemologist',
                            style: AppTypography.headlineSM().copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Book a 1-on-1 private consultation session.',
                            style: AppTypography.bodyXS(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: AppColors.primaryGold,
                      ),
                      onPressed: () => context.push('/concierge-booking'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
