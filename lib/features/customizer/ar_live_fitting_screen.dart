import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/services/cart_provider.dart';
import '../../core/widgets/app_button.dart';

/// Screen 12: ar_live_smile_camera_fitting
/// AR Live Camera Smile Tracking & Grillz Virtual Try-On Studio
class ArLiveFittingScreen extends StatefulWidget {
  const ArLiveFittingScreen({super.key});

  @override
  State<ArLiveFittingScreen> createState() => _ArLiveFittingScreenState();
}

class _ArLiveFittingScreenState extends State<ArLiveFittingScreen> {
  int _selectedProductIndex = 0;
  String _lightingMode = 'Studio Spot';
  bool _splitViewEnabled = false;

  final List<String> _lightingModes = ['Studio Spot', 'Natural Daylight', 'Night Glow'];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final activeProduct = MockDataService.products[_selectedProductIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Live Camera Stream Mock (High fashion portrait with dental focus)
          Positioned.fill(
            child: Image.network(
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=1200&auto=format&fit=crop',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(color: AppColors.darkBase),
            ),
          ),

          // AR Smile Tracking Mesh Overlay (Visual simulation of facial landmark tracking)
          Positioned.fill(
            child: CustomPaint(
              painter: _SmileMeshPainter(splitView: _splitViewEnabled),
            ),
          ),

          // Top Header Controls
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryGold, width: 1),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.emeraldGreen,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'SMILE TRACKED (60 FPS)',
                          style: AppTypography.labelSM(color: AppColors.primaryGold),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _splitViewEnabled ? Icons.splitscreen : Icons.view_sidebar_outlined,
                      color: _splitViewEnabled ? AppColors.primaryGold : Colors.white,
                    ),
                    onPressed: () => setState(() => _splitViewEnabled = !_splitViewEnabled),
                  ),
                ],
              ),
            ),
          ),

          // Lighting Mode Selector
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.65),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                children: _lightingModes.map((mode) {
                  final isSelected = mode == _lightingMode;
                  return InkWell(
                    onTap: () => setState(() => _lightingMode = mode),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryGold : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        mode,
                        style: AppTypography.labelSM(
                          color: isSelected ? AppColors.textOnGold : Colors.white70,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Bottom Tray: Product Carousel & Shutter / Add to Bag
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.85),
                    Colors.black,
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product Selection Carousel
                    SizedBox(
                      height: 74,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: MockDataService.products.length,
                        itemBuilder: (context, index) {
                          final prod = MockDataService.products[index];
                          final isSelected = index == _selectedProductIndex;

                          return InkWell(
                            onTap: () => setState(() => _selectedProductIndex = index),
                            child: Container(
                              margin: const EdgeInsets.only(right: 10),
                              padding: const EdgeInsets.all(6),
                              width: 170,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.darkCard : Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected ? AppColors.primaryGold : AppColors.darkBorder,
                                  width: isSelected ? 1.5 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      prod.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          prod.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.labelSM(color: Colors.white),
                                        ),
                                        Text(
                                          '\$${prod.priceUsd.toInt()}',
                                          style: AppTypography.labelMD(color: AppColors.primaryGold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Action Buttons Row: Shutter & Add Look to Bag
                    Row(
                      children: [
                        // Shutter Snapshot Button
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('AR Fitting snapshot saved to Gallery')),
                            );
                          },
                          child: Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primaryGold,
                                ),
                                child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        // Add to Cart Button
                        Expanded(
                          child: AppButton.primary(
                            text: 'ADD CURRENT LOOK TO CART',
                            onPressed: () {
                              cartProvider.addToCart(activeProduct);
                              context.push('/cart');
                            },
                          ),
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
    );
  }
}

class _SmileMeshPainter extends CustomPainter {
  final bool splitView;
  _SmileMeshPainter({required this.splitView});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryGold.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final glowPaint = Paint()
      ..color = AppColors.primaryGold.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // Center smile tracking oval simulation
    final center = Offset(size.width / 2, size.height * 0.48);
    final rect = Rect.fromCenter(center: center, width: 140, height: 50);

    canvas.drawOval(rect, paint);
    canvas.drawOval(rect, glowPaint);

    if (splitView) {
      final linePaint = Paint()
        ..color = Colors.white70
        ..strokeWidth = 1.5;
      canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _SmileMeshPainter oldDelegate) => oldDelegate.splitView != splitView;
}
