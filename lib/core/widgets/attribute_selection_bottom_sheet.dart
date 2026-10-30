import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../models/product.dart';
import '../services/cart_provider.dart';
import 'app_button.dart';
import 'dual_price_text.dart';

/// Modal bottom sheet allowing patrons to select product attributes (e.g. upper, lower, size)
/// before adding bespoke items to the cart.
class AttributeSelectionBottomSheet extends StatefulWidget {
  final Product product;
  final Map<String, dynamic>? initialAttributes;

  const AttributeSelectionBottomSheet({
    super.key,
    required this.product,
    this.initialAttributes,
  });

  /// Convenient helper to display the bottom sheet modal
  static Future<bool?> show(
    BuildContext context,
    Product product, {
    Map<String, dynamic>? initialAttributes,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (ctx) => AttributeSelectionBottomSheet(
        product: product,
        initialAttributes: initialAttributes,
      ),
    );
  }

  @override
  State<AttributeSelectionBottomSheet> createState() =>
      _AttributeSelectionBottomSheetState();
}

class _AttributeSelectionBottomSheetState
    extends State<AttributeSelectionBottomSheet> {
  late final Map<String, dynamic> _selectedAttributes;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedAttributes = {};

    // Initialize with provided initialAttributes or default to the first option of each attribute
    if (widget.initialAttributes != null &&
        widget.initialAttributes!.isNotEmpty) {
      _selectedAttributes.addAll(widget.initialAttributes!);
    } else {
      for (final attr in widget.product.effectiveAttributes) {
        if (attr.values.isNotEmpty) {
          _selectedAttributes[attr.label] = attr.values.first;
        }
      }
    }
  }

  void _selectAttributeOption(String label, String value) {
    setState(() {
      _selectedAttributes[label] = value;
    });
  }

  void _onAddToCart() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    for (int i = 0; i < _quantity; i++) {
      cart.addToCart(
        widget.product,
        selectedAttributes: Map<String, dynamic>.from(_selectedAttributes),
      );
    }

    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added "${widget.product.name}" to Cart',
          style: AppTypography.bodySM(color: Colors.white),
        ),
        action: SnackBarAction(
          label: 'VIEW CART',
          textColor: AppColors.primaryGold,
          onPressed: () => context.push('/cart'),
        ),
        duration: const Duration(seconds: 3),
        backgroundColor: AppColors.darkBase,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final attributes = product.effectiveAttributes;
    final totalPriceUsd = product.priceUsd * _quantity;
    final totalPriceNgn = product.priceNgn * _quantity;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.outlineGold.withValues(alpha: 0.6),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Notch Handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header Section: Image, Title, Price, Close
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 12, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Thumbnail
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.outlineGold.withValues(alpha: 0.5),
                      ),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(
                          Icons.diamond,
                          color: AppColors.primaryGold,
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Title, Category & Price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSM(
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          product.categoryName.toUpperCase(),
                          style: AppTypography.labelSM(
                            color: AppColors.primaryGold,
                          ).copyWith(fontSize: 10, letterSpacing: 1.2),
                        ),
                        const SizedBox(height: 4),
                        DualPriceText(
                          priceUsd: totalPriceUsd,
                          priceNgn: totalPriceNgn,
                          isVertical: false,
                          primaryStyle: AppTypography.priceDisplay().copyWith(
                            fontSize: 16,
                          ),
                          secondaryStyle: AppTypography.priceSecondary().copyWith(
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Close button
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textMuted, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.outlineLight, height: 1),

            // Attributes & Quantity Scrollable Body
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Render each Attribute Group
                    for (int i = 0; i < attributes.length; i++) ...[
                      _buildAttributeSection(attributes[i]),
                      if (i < attributes.length - 1)
                        const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 24),
                    const Divider(color: AppColors.outlineLight, height: 1),
                    const SizedBox(height: 16),

                    // Quantity Selection Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'QUANTITY',
                          style: AppTypography.labelLG(
                            color: AppColors.textPrimary,
                          ).copyWith(letterSpacing: 1.0, fontSize: 13),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outlineLight),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 16),
                                color: _quantity > 1
                                    ? AppColors.textPrimary
                                    : AppColors.textMuted,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                onPressed: _quantity > 1
                                    ? () => setState(() => _quantity--)
                                    : null,
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '$_quantity',
                                  style: AppTypography.labelMD(
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 16),
                                color: AppColors.textPrimary,
                                constraints: const BoxConstraints(
                                  minWidth: 36,
                                  minHeight: 36,
                                ),
                                onPressed: () =>
                                    setState(() => _quantity++),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Add to Cart Button Bar
            Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                border: Border(
                  top: BorderSide(color: AppColors.outlineLight, width: 1),
                ),
              ),
              child: AppButton.primary(
                text: 'ADD TO BAG',
                suffixIcon: const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: AppColors.textOnGold,
                ),
                onPressed: _onAddToCart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttributeSection(ProductAttribute attr) {
    final selectedVal = _selectedAttributes[attr.label];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              attr.label.toUpperCase(),
              style: AppTypography.labelMD(
                color: AppColors.textPrimary,
              ).copyWith(letterSpacing: 1.1, fontWeight: FontWeight.w600),
            ),
            if (selectedVal != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.4),
                    width: 0.8,
                  ),
                ),
                child: Text(
                  selectedVal.toString(),
                  style: AppTypography.labelSM(
                    color: AppColors.primaryGold,
                  ).copyWith(fontSize: 11),
                ),
              ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: attr.values.map((val) {
            final isSelected = selectedVal == val;
            return InkWell(
              onTap: () => _selectAttributeOption(attr.label, val),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold.withValues(alpha: 0.18)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.outlineLight,
                    width: isSelected ? 1.5 : 0.8,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isSelected) ...[
                      const Icon(
                        Icons.check,
                        size: 14,
                        color: AppColors.primaryGold,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      val,
                      style: AppTypography.labelMD(
                        color: isSelected
                            ? AppColors.primaryGold
                            : AppColors.textPrimary,
                      ).copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
