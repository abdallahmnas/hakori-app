import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/product.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/currency_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

enum ToothMaterial {
  yellowGold,
  whiteGold,
  roseGold,
  diamondPave,
  emeraldInlay,
  openFace,
  none,
}

class ToothConfig {
  final int number;
  ToothMaterial material;

  ToothConfig({required this.number, this.material = ToothMaterial.yellowGold});

  double get priceUsd {
    switch (material) {
      case ToothMaterial.yellowGold:
        return 450.0;
      case ToothMaterial.whiteGold:
        return 480.0;
      case ToothMaterial.roseGold:
        return 480.0;
      case ToothMaterial.diamondPave:
        return 950.0;
      case ToothMaterial.emeraldInlay:
        return 1200.0;
      case ToothMaterial.openFace:
        return 550.0;
      case ToothMaterial.none:
        return 0.0;
    }
  }

  String get materialName {
    switch (material) {
      case ToothMaterial.yellowGold:
        return '18K Yellow Gold';
      case ToothMaterial.whiteGold:
        return '18K White Gold';
      case ToothMaterial.roseGold:
        return '18K Rose Gold';
      case ToothMaterial.diamondPave:
        return 'VVS Diamond Pavé';
      case ToothMaterial.emeraldInlay:
        return 'Colombian Emerald';
      case ToothMaterial.openFace:
        return 'Open Face Window';
      case ToothMaterial.none:
        return 'Natural (Uncapped)';
    }
  }

  Color get displayColor {
    switch (material) {
      case ToothMaterial.yellowGold:
        return AppColors.primaryGold;
      case ToothMaterial.whiteGold:
        return const Color(0xFFE2E8F0);
      case ToothMaterial.roseGold:
        return const Color(0xFFFDA4AF);
      case ToothMaterial.diamondPave:
        return const Color(0xFF93C5FD);
      case ToothMaterial.emeraldInlay:
        return AppColors.emeraldGreen;
      case ToothMaterial.openFace:
        return const Color(0xFFD97706);
      case ToothMaterial.none:
        return AppColors.darkBorder;
    }
  }
}

/// Screen 11: custom_bespoke_3d_configurator
/// Real-time CAD Tooth-by-tooth 3D Arch Customizer with dynamic metallurgy pricing
class BespokeConfiguratorScreen extends StatefulWidget {
  const BespokeConfiguratorScreen({super.key});

  @override
  State<BespokeConfiguratorScreen> createState() => _BespokeConfiguratorScreenState();
}

class _BespokeConfiguratorScreenState extends State<BespokeConfiguratorScreen> {
  bool _isUpperArch = true;
  int _selectedToothIndex = 0; // 0 to 7 (Teeth 1-8)

  late List<ToothConfig> _upperTeeth;
  late List<ToothConfig> _lowerTeeth;

  @override
  void initState() {
    super.initState();
    _upperTeeth = List.generate(8, (index) {
      if (index == 2 || index == 3 || index == 4 || index == 5) {
        return ToothConfig(number: index + 1, material: ToothMaterial.diamondPave);
      }
      return ToothConfig(number: index + 1, material: ToothMaterial.yellowGold);
    });

    _lowerTeeth = List.generate(8, (index) => ToothConfig(number: index + 1, material: ToothMaterial.yellowGold));
  }

  List<ToothConfig> get _activeTeeth => _isUpperArch ? _upperTeeth : _lowerTeeth;

  double get _totalConfigPriceUsd {
    return _activeTeeth.fold(0.0, (sum, t) => sum + t.priceUsd);
  }

  void _applyMaterial(ToothMaterial material) {
    setState(() {
      _activeTeeth[_selectedToothIndex].material = material;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currentTooth = _activeTeeth[_selectedToothIndex];

    return Scaffold(
      backgroundColor: AppColors.darkBase,
      appBar: AppBar(
        backgroundColor: AppColors.darkBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primaryGold),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          '3D ARCH ARCHITECT',
          style: AppTypography.labelLG(color: AppColors.textOnDark).copyWith(letterSpacing: 2),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGold),
            onPressed: () {
              setState(() {
                for (var t in _upperTeeth) {
                  t.material = ToothMaterial.yellowGold;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.view_in_ar, color: AppColors.primaryGold),
            onPressed: () => context.push('/ar-fitting'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Arch Switcher (Upper Arch / Lower Arch)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.darkCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isUpperArch = true),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: _isUpperArch ? AppColors.primaryGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'UPPER MAXILLARY ARCH',
                            style: AppTypography.labelSM(
                              color: _isUpperArch ? AppColors.textOnGold : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () => setState(() => _isUpperArch = false),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !_isUpperArch ? AppColors.primaryGold : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            'LOWER MANDIBULAR ARCH',
                            style: AppTypography.labelSM(
                              color: !_isUpperArch ? AppColors.textOnGold : AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3D CAD Arch Visualizer Canvas
            Expanded(
              flex: 4,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.darkBorder),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: Stack(
                  children: [
                    // Grid lines pattern
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=600&auto=format&fit=crop',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    // CAD Arch Diagram & Tooth Selection Boxes
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              AppBadgeChip(
                                label: 'CAD SUB-MM PRECISION',
                                variant: BadgeChipVariant.goldPurity,
                              ),
                              AppBadgeChip(
                                label: '360° LIVE ORBIT',
                                variant: BadgeChipVariant.darkTag,
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Curved Tooth Selector Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(8, (index) {
                              final tooth = _activeTeeth[index];
                              final isSelected = index == _selectedToothIndex;

                              return InkWell(
                                onTap: () => setState(() => _selectedToothIndex = index),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: 32,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: tooth.displayColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected ? Colors.white : AppColors.darkBorder,
                                      width: isSelected ? 2.5 : 1,
                                    ),
                                    boxShadow: isSelected ? [AppColors.goldGlow] : [],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          'T${tooth.number}',
                                          style: AppTypography.labelSM(
                                            color: tooth.material == ToothMaterial.none
                                                ? AppColors.textMuted
                                                : Colors.black,
                                          ).copyWith(fontSize: 9),
                                        ),
                                      ),
                                      if (tooth.material == ToothMaterial.diamondPave)
                                        const Icon(Icons.auto_awesome, size: 10, color: Colors.black),
                                      if (tooth.material == ToothMaterial.openFace)
                                        const Icon(Icons.crop_square, size: 10, color: Colors.black),
                                      const SizedBox(height: 2),
                                    ],
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Tap any tooth (T1-T8) above to customize material',
                            style: AppTypography.bodyXS(color: AppColors.textMuted),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Material & Inlay Applicator Toolbar
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: const BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  border: Border(top: BorderSide(color: AppColors.darkBorder)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Selected Tooth Summary
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Tooth #${currentTooth.number}: ${currentTooth.materialName}',
                            style: AppTypography.headlineMD(color: AppColors.textOnDark),
                          ),
                          Text(
                            currencyProvider.formatPrice(currentTooth.priceUsd),
                            style: AppTypography.priceDisplay(color: AppColors.primaryGold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Material Pill Buttons
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildMaterialBtn('18K Yellow Gold', ToothMaterial.yellowGold, currentTooth.material),
                          _buildMaterialBtn('18K White Gold', ToothMaterial.whiteGold, currentTooth.material),
                          _buildMaterialBtn('18K Rose Gold', ToothMaterial.roseGold, currentTooth.material),
                          _buildMaterialBtn('VVS Diamond Pavé', ToothMaterial.diamondPave, currentTooth.material),
                          _buildMaterialBtn('Emerald Inlay', ToothMaterial.emeraldInlay, currentTooth.material),
                          _buildMaterialBtn('Open Face Window', ToothMaterial.openFace, currentTooth.material),
                          _buildMaterialBtn('Uncapped (None)', ToothMaterial.none, currentTooth.material),
                        ],
                      ),
                      const SizedBox(height: 18),
                      // Total & Commission CTA
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('ESTIMATED COMMISSION', style: AppTypography.labelSM(color: AppColors.textMuted)),
                              DualPriceText(
                                priceUsd: _totalConfigPriceUsd,
                                primaryStyle: AppTypography.headlineLG(color: AppColors.primaryGold),
                              ),
                            ],
                          ),
                          AppButton.primary(
                            text: 'ADD TO CART',
                            width: 150,
                            height: 48,
                            onPressed: () {
                              final customProduct = Product(
                                id: 'bespoke_custom_${DateTime.now().millisecondsSinceEpoch}',
                                name: '1-of-1 Bespoke ${_isUpperArch ? 'Upper' : 'Lower'} Arch',
                                category: 'Bespoke Atelier Commission',
                                priceUsd: _totalConfigPriceUsd,
                                priceNgn: _totalConfigPriceUsd * 1550,
                                imageUrl:
                                    'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=800&auto=format&fit=crop',
                                description: 'Custom designed in 3D CAD with tooth-by-tooth metallurgy.',
                              );
                              cartProvider.addToCart(customProduct);
                              context.push('/cart');
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialBtn(String title, ToothMaterial material, ToothMaterial activeMaterial) {
    final isSelected = material == activeMaterial;
    return InkWell(
      onTap: () => _applyMaterial(material),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGold : AppColors.darkCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
          ),
        ),
        child: Text(
          title,
          style: AppTypography.labelSM(
            color: isSelected ? AppColors.textOnGold : AppColors.textOnDark,
          ),
        ),
      ),
    );
  }
}
