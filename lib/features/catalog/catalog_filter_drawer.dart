import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/product_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 9: catalog_advanced_filter_drawer
/// Clean Filter Bottom Sheet Modal matching backend API capabilities:
/// - Category (from API categories/pills)
/// - In-Stock availability toggle
class CatalogFilterDrawer extends StatefulWidget {
  const CatalogFilterDrawer({super.key});

  @override
  State<CatalogFilterDrawer> createState() => _CatalogFilterDrawerState();
}

class _CatalogFilterDrawerState extends State<CatalogFilterDrawer> {
  late String _selectedCategory;
  late bool _inStockOnly;

  @override
  void initState() {
    super.initState();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    _selectedCategory = productProvider.selectedCategory;
    _inStockOnly = productProvider.inStockOnly;
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final categoryFilters = productProvider.categoryFilters;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Grab Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Catalog',
                    style: AppTypography.headlineMD(color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'ALL';
                        _inStockOnly = false;
                      });
                    },
                    child: Text(
                      'RESET',
                      style: AppTypography.labelSM(color: AppColors.rubyRed),
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Categories Selector from API
              _buildSectionTitle('Category'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categoryFilters.map((category) {
                  final isSelected = category.toLowerCase() == _selectedCategory.toLowerCase();
                  return AppBadgeChip(
                    label: category,
                    variant: BadgeChipVariant.outline,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedCategory = category),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // In Stock Availability
              _buildSectionTitle('Availability'),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'In Stock Only',
                          style: AppTypography.labelMD(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Only display items ready for immediate dispatch',
                          style: AppTypography.bodyXS(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    Switch(
                      value: _inStockOnly,
                      activeColor: AppColors.primaryGold,
                      onChanged: (val) => setState(() => _inStockOnly = val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Apply CTA
              AppButton.primary(
                text: 'APPLY FILTERS',
                onPressed: () {
                  productProvider.setSelectedCategory(_selectedCategory);
                  productProvider.setInStockOnly(_inStockOnly);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTypography.labelMD(color: AppColors.textPrimary),
      ),
    );
  }
}
