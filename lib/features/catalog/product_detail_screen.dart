import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/product.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/wishlist_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/services/product_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen 10: product_detail_diamond_cut_grill
/// Luxury Product Detail Screen with gallery carousel, bespoke selector matrix, and AR try-on trigger
class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _currentImageIndex = 0;
  String _selectedMetal = '18K Yellow Gold';
  String _selectedStone = 'VVS1 Natural Diamonds';
  String _selectedArch = 'Top 6 Arch';
  bool _includeImpressionKit = true;

  Product? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadProduct());
  }

  Future<void> _loadProduct() async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final existing = productProvider.findProductById(widget.productId);
    if (existing != null) {
      if (mounted) {
        setState(() {
          _product = existing;
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final productService = Provider.of<ProductService>(context, listen: false);
      final fetched = await productService.getProductById(widget.productId);
      if (mounted) {
        setState(() {
          _product = fetched;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _product = MockDataService.products.firstWhere(
            (p) => p.id == widget.productId,
            orElse: () => MockDataService.products[0],
          );
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _product == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
        ),
      );
    }

    final product = _product!;
    final wishlistProvider = Provider.of<WishlistProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final isFav = wishlistProvider.isFavorite(product.id);
    final images = product.galleryImages.isNotEmpty ? product.galleryImages : [product.imageUrl];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              // Custom Image App Bar
              SliverAppBar(
                expandedHeight: 380,
                pinned: true,
                backgroundColor: AppColors.surface,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? AppColors.rubyRed : AppColors.textPrimary,
                    ),
                    onPressed: () => wishlistProvider.toggleFavorite(product.id),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share_outlined),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Bespoke vault link copied to clipboard')),
                      );
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        itemCount: images.length,
                        onPageChanged: (index) => setState(() => _currentImageIndex = index),
                        itemBuilder: (context, index) {
                          return Image.network(
                            images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: AppColors.surfaceContainerLow,
                              child: const Icon(Icons.diamond, size: 64, color: AppColors.primaryGold),
                            ),
                          );
                        },
                      ),
                      // Carousel Indicator Dots
                      Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(images.length, (index) {
                            final isActive = index == _currentImageIndex;
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 3),
                              width: isActive ? 20 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isActive ? AppColors.primaryGold : Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ),
                      // Floating 3D/AR Try On Chip
                      Positioned(
                        bottom: 14,
                        right: 16,
                        child: InkWell(
                          onTap: () => context.push('/ar-fitting'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.darkBase.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.primaryGold, width: 1),
                              boxShadow: const [AppColors.goldGlow],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.view_in_ar, size: 14, color: AppColors.primaryGold),
                                const SizedBox(width: 6),
                                Text(
                                  '3D LIVE TRY-ON',
                                  style: AppTypography.labelSM(color: AppColors.primaryGold),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product Info & Configuration Body
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Purity & Rating Row
                      Row(
                        children: [
                          AppBadgeChip.purity(label: product.purity),
                          const SizedBox(width: 8),
                          AppBadgeChip(
                            label: product.diamondClarity,
                            variant: BadgeChipVariant.darkTag,
                          ),
                          const Spacer(),
                          const Icon(Icons.star, size: 15, color: AppColors.primaryGold),
                          const SizedBox(width: 4),
                          Text(
                            '${product.rating} (${product.reviewCount} verified)',
                            style: AppTypography.labelSM(color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        product.name,
                        style: AppTypography.headlineXL(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),

                      // Dual Price Display
                      DualPriceText(
                        priceUsd: product.priceUsd,
                        priceNgn: product.priceNgn,
                      ),
                      const SizedBox(height: 18),
                      const Divider(),
                      const SizedBox(height: 18),

                      // Precious Metal Selector
                      Text(
                        '1. Select Precious Metal',
                        style: AppTypography.labelLG(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.metalOptions.map((metal) {
                          final isSelected = metal == _selectedMetal;
                          return AppBadgeChip(
                            label: metal,
                            variant: BadgeChipVariant.outline,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedMetal = metal),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Gemstone & Clarity Selector
                      Text(
                        '2. Gemstone Setting & Clarity',
                        style: AppTypography.labelLG(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: product.stoneOptions.map((stone) {
                          final isSelected = stone == _selectedStone;
                          return AppBadgeChip(
                            label: stone,
                            variant: BadgeChipVariant.outline,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedStone = stone),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Arch Positioning
                      Text(
                        '3. Arch & Tooth Placement',
                        style: AppTypography.labelLG(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ['Top 6 Arch', 'Bottom 6 Arch', 'Full 16 Master Arch', 'Canine Duo'].map((arch) {
                          final isSelected = arch == _selectedArch;
                          return AppBadgeChip(
                            label: arch,
                            variant: BadgeChipVariant.outline,
                            isSelected: isSelected,
                            onTap: () => setState(() => _selectedArch = arch),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 24),

                      // Complimentary 3D Impression Kit Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.goldContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineGold),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined, color: AppColors.primaryGold, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Free 3D Dental Impression Kit Included',
                                    style: AppTypography.labelMD(color: AppColors.onGoldContainer),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Dispatched within 24 hours with return courier bag.',
                                    style: AppTypography.bodyXS(color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _includeImpressionKit,
                              activeColor: AppColors.primaryGold,
                              onChanged: (val) => setState(() => _includeImpressionKit = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      Text(
                        'Atelier Craftsmanship Notes',
                        style: AppTypography.headlineMD(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(height: 1.6),
                      ),
                      const SizedBox(height: 20),

                      // Security Badges
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: Column(
                          children: [
                            _buildFeatureRow(Icons.verified, 'French Assay Office Hallmarked 18K/24K'),
                            const Divider(height: 16),
                            _buildFeatureRow(Icons.lock, 'Vault Escrow & Diplomatic Armored Courier'),
                            const Divider(height: 16),
                            _buildFeatureRow(Icons.architecture, 'Lifetime Precision Fit Guarantee'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Sticky Bottom Checkout Bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.outlineLight, width: 1)),
                boxShadow: [
                  BoxShadow(color: Color(0x14000000), blurRadius: 20, offset: Offset(0, -4)),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // AR Try-On Button
                    InkWell(
                      onTap: () => context.push('/ar-fitting'),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 52,
                        width: 52,
                        decoration: BoxDecoration(
                          color: AppColors.darkBase,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: const Icon(Icons.camera_alt_outlined, color: AppColors.primaryGold, size: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Add to Cart Button
                    Expanded(
                      child: AppButton.primary(
                        text: 'ADD TO CART',
                        onPressed: () {
                          cartProvider.addToCart(
                            product,
                            metal: _selectedMetal,
                            stone: _selectedStone,
                            arch: _selectedArch,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added ${product.name} to Cart'),
                              action: SnackBarAction(
                                label: 'VIEW CART',
                                textColor: AppColors.primaryGold,
                                onPressed: () => context.push('/cart'),
                              ),
                              backgroundColor: AppColors.darkBase,
                            ),
                          );
                        },
                        suffixIcon: const Icon(Icons.shopping_cart_outlined, color: AppColors.textOnGold, size: 18),
                      ),
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

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryGold),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySM(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
