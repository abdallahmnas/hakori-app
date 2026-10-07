import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/category.dart';
import '../../core/models/product.dart';
import '../../core/services/product_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/product_skeleton.dart';

/// Screen: category_info_screen
/// Lists atelier products by category with hero header and grid
class CategoryInfoScreen extends StatefulWidget {
  final String categoryName;
  final Category? category;

  const CategoryInfoScreen({
    super.key,
    required this.categoryName,
    this.category,
  });

  @override
  State<CategoryInfoScreen> createState() => _CategoryInfoScreenState();
}

class _CategoryInfoScreenState extends State<CategoryInfoScreen> {
  List<Product> _products = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchCategoryProducts();
  }

  Future<void> _fetchCategoryProducts() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final fetched = await productService.getProducts(
        page: 0,
        pageSize: 50,
        category: widget.categoryName.toUpperCase() == 'ALL' ? null : widget.categoryName,
      );

      if (mounted) {
        setState(() {
          _products = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load products for this category.';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.category?.title.isNotEmpty == true
        ? widget.category!.title
        : widget.categoryName.toUpperCase();
    final description = widget.category?.subtitle.isNotEmpty == true
        ? widget.category!.subtitle
        : 'Explore our curated ${widget.categoryName} collection handcrafted in pure 18K/24K solid gold and fine gemstones.';
    final heroImage = widget.category?.imageUrl.isNotEmpty == true
        ? widget.category!.imageUrl
        : (_products.isNotEmpty ? _products.first.imageUrl : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: title,
        showBack: true,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: _fetchCategoryProducts,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Category Info Hero Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [AppColors.softCardShadow],
                  image: DecorationImage(
                    image: NetworkImage(heroImage),
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
                        Colors.black.withValues(alpha: 0.25),
                        Colors.black.withValues(alpha: 0.65),
                        AppColors.darkBase.withValues(alpha: 0.94),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 32),
                      Row(
                        children: [
                          AppBadgeChip(
                            label: '${_products.length} ATELIER PIECES',
                            variant: BadgeChipVariant.goldPurity,
                          ),
                          const Spacer(),
                          const AppBadgeChip(
                            label: 'SOLID GOLD & VVS',
                            variant: BadgeChipVariant.darkTag,
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        title,
                        style: AppTypography.headlineLG(color: AppColors.textOnDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: AppTypography.bodyXS(color: AppColors.surfaceContainerHigh).copyWith(
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Products Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Collection Pieces',
                      style: AppTypography.headlineMD(color: AppColors.textPrimary).copyWith(fontSize: 16),
                    ),
                    Text(
                      '${_products.length} Results',
                      style: AppTypography.labelSM(color: AppColors.primaryGold),
                    ),
                  ],
                ),
              ),
            ),

            // Loading / Error / Empty / Grid
            if (_isLoading)
              const SliverProductGridSkeleton(itemCount: 6)
            else if (_errorMessage != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.error_outline, size: 44, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMD(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        AppButton.outline(
                          text: 'RETRY',
                          width: 120,
                          onPressed: _fetchCategoryProducts,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else if (_products.isEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.diamond_outlined, size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No Pieces in this Category',
                          style: AppTypography.headlineSM(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'We are currently preparing new bespoke pieces for this collection.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyXS(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        AppButton.outline(
                          text: 'BACK TO CATEGORIES',
                          width: 190,
                          onPressed: () => Navigator.of(context).maybePop(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _products[index];
                      return ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                      );
                    },
                    childCount: _products.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
