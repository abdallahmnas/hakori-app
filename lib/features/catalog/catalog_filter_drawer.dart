import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 9: catalog_advanced_filter_drawer
/// Advanced Filter Bottom Sheet Modal with metal, gemstone, arch, price, and setting selectors
class CatalogFilterDrawer extends StatefulWidget {
  const CatalogFilterDrawer({super.key});

  @override
  State<CatalogFilterDrawer> createState() => _CatalogFilterDrawerState();
}

class _CatalogFilterDrawerState extends State<CatalogFilterDrawer> {
  String _selectedMetal = '18K Yellow Gold';
  String _selectedGem = 'VVS Natural Diamonds';
  String _selectedArch = 'Top Arch (6-8)';
  String _selectedSetting = 'Micro-Pavé';
  RangeValues _priceRange = const RangeValues(1000, 15000);

  final List<String> _metals = [
    '18K Yellow Gold',
    '18K White Gold',
    '18K Rose Gold',
    '24K Pure Gold',
    '950 Platinum',
  ];

  final List<String> _gemstones = [
    'VVS Natural Diamonds',
    'Flawless Moissanite',
    'Colombian Emerald',
    'Australian Opal',
    'Deep Mirror Gold (No Gem)',
  ];

  final List<String> _arches = [
    'Top Arch (6-8)',
    'Bottom Arch (6-8)',
    'Full 16 Master Arch',
    'Single Canine Cap',
    'Dual Fangs',
  ];

  final List<String> _settings = [
    'Micro-Pavé',
    'Channel Setting',
    'Honeycomb Diamond',
    'Architectural Open Face',
    'Diamond Dust Stipple',
  ];

  @override
  Widget build(BuildContext context) {
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
                    'Filter Atelier Catalog',
                    style: AppTypography.headlineMD(color: AppColors.textPrimary),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedMetal = '18K Yellow Gold';
                        _selectedGem = 'VVS Natural Diamonds';
                        _selectedArch = 'Top Arch (6-8)';
                        _selectedSetting = 'Micro-Pavé';
                        _priceRange = const RangeValues(1000, 15000);
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

              // Metal Purity Selector
              _buildSectionTitle('Precious Metal & Purity'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _metals.map((metal) {
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

              // Gemstone Quality
              _buildSectionTitle('Gemstone & Inlay Quality'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _gemstones.map((gem) {
                  final isSelected = gem == _selectedGem;
                  return AppBadgeChip(
                    label: gem,
                    variant: BadgeChipVariant.outline,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedGem = gem),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Arch Position
              _buildSectionTitle('Arch & Tooth Position'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _arches.map((arch) {
                  final isSelected = arch == _selectedArch;
                  return AppBadgeChip(
                    label: arch,
                    variant: BadgeChipVariant.outline,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedArch = arch),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Price Range Slider
              _buildSectionTitle('Price Range (USD)'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '\$${_priceRange.start.toInt()}',
                    style: AppTypography.labelMD(color: AppColors.primaryGold),
                  ),
                  Text(
                    '\$${_priceRange.end.toInt()}+',
                    style: AppTypography.labelMD(color: AppColors.primaryGold),
                  ),
                ],
              ),
              RangeSlider(
                values: _priceRange,
                min: 500,
                max: 25000,
                divisions: 49,
                activeColor: AppColors.primaryGold,
                inactiveColor: AppColors.outlineLight,
                onChanged: (RangeValues values) {
                  setState(() => _priceRange = values);
                },
              ),
              const SizedBox(height: 16),

              // Setting Style
              _buildSectionTitle('Jewelry Setting Discipline'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _settings.map((setting) {
                  final isSelected = setting == _selectedSetting;
                  return AppBadgeChip(
                    label: setting,
                    variant: BadgeChipVariant.outline,
                    isSelected: isSelected,
                    onTap: () => setState(() => _selectedSetting = setting),
                  );
                }).toList(),
              ),
              const SizedBox(height: 28),

              // Apply CTA
              AppButton.primary(
                text: 'APPLY FILTERS (38 PIECES)',
                onPressed: () => Navigator.pop(context),
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
