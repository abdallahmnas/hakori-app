import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/product.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/wishlist_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/services/product_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen 10: ProductDetailScreen
/// Luxury Product Detail Screen reflecting exact API attributes:
/// name, sku, category, price, costPrice, castingPrice, stock, inventory,
/// description, images, material, placement, rating, inStock, lowStock, status
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
  String? _selectedMetal;
  String? _selectedStone;
  String? _selectedArch;
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
          _selectedMetal = existing.metalOptions.isNotEmpty ? existing.metalOptions.first : existing.material;
          _selectedStone = existing.stoneOptions.isNotEmpty ? existing.stoneOptions.first : 'Bespoke Finishing';
          _selectedArch = existing.placement;
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
          _selectedMetal = fetched.metalOptions.isNotEmpty ? fetched.metalOptions.first : fetched.material;
          _selectedStone = fetched.stoneOptions.isNotEmpty ? fetched.stoneOptions.first : 'Bespoke Finishing';
          _selectedArch = fetched.placement;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load product details.'), backgroundColor: AppColors.error),
        );
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
                      if (images.length > 1)
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
                                  color: isActive ? AppColors.primaryGold : Colors.white.withValues(alpha: 0.6),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                      // Live Try-on Tag
                      Positioned(
                        bottom: 14,
                        right: 16,
                        child: InkWell(
                          onTap: () => context.push('/ar-fitting'),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.darkBase.withValues(alpha: 0.85),
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
                                  'LIVE TRY-ON',
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
                      // Material Badge, Category & Rating Row
                      Row(
                        children: [
                          if (product.material.isNotEmpty) ...[
                            AppBadgeChip.purity(label: product.material),
                            const SizedBox(width: 8),
                          ],
                          AppBadgeChip(
                            label: product.category.toUpperCase(),
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

                      // Product Specifications Grid
                      Text(
                        'Piece Specifications',
                        style: AppTypography.labelLG(color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.outlineLight),
                        ),
                        child: Column(
                          children: [
                            if (product.sku.isNotEmpty) ...[
                              _buildSpecRow('SKU', product.sku),
                              const Divider(height: 18),
                            ],
                            _buildSpecRow('Category', product.category),
                            const Divider(height: 18),
                            _buildSpecRow('Material / Purity', product.material),
                            const Divider(height: 18),
                            _buildSpecRow('Placement / Type', product.placement),
                            const Divider(height: 18),
                            _buildSpecRow(
                              'Availability',
                              product.inStock
                                  ? (product.lowStock
                                      ? 'Low Stock (${product.stock} available)'
                                      : 'In Stock (${product.stock} available)')
                                  : 'Out of Stock',
                              valueColor: product.inStock
                                  ? (product.lowStock ? AppColors.rubyRed : AppColors.success)
                                  : AppColors.textMuted,
                            ),
                            if (product.status.isNotEmpty) ...[
                              const Divider(height: 18),
                              _buildSpecRow('Status', product.status),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Precious Metal Selector (only if options provided by API)
                      if (product.metalOptions.isNotEmpty) ...[
                        Text(
                          'Precious Metal Option',
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
                        const SizedBox(height: 24),
                      ],

                      // Stone Options (only if options provided by API)
                      if (product.stoneOptions.isNotEmpty) ...[
                        Text(
                          'Gemstone & Setting Options',
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
                        const SizedBox(height: 24),
                      ],

                      // Sizing Kit Option
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.goldContainer.withValues(alpha: 0.4),
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
                                    'Free Luxury Sizing Kit Included',
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
                              activeThumbColor: AppColors.primaryGold,
                              onChanged: (val) => setState(() => _includeImpressionKit = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      if (product.description.isNotEmpty) ...[
                        Text(
                          'Atelier Craftsmanship Notes',
                          style: AppTypography.headlineMD(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          product.description,
                          style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 24),
                      ],

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
                        text: product.inStock ? 'ADD TO CART' : 'OUT OF STOCK',
                        onPressed: product.inStock
                            ? () {
                                cartProvider.addToCart(
                                  product,
                                  metal: _selectedMetal ?? product.material,
                                  stone: _selectedStone ?? 'Standard Setting',
                                  arch: _selectedArch ?? product.placement,
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
                              }
                            : null,
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

  Widget _buildSpecRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodySM(color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.labelMD(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
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
