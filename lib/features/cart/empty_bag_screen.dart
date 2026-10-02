import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/product_card.dart';

/// Screen 14: empty_bag_vault_states
/// Elegant empty cart state with luxury call-to-action and recently viewed pieces
class EmptyBagScreen extends StatelessWidget {
  const EmptyBagScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              // Gold Vault Lock Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(
                  Icons.shopping_cart_outlined,
                  size: 34,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Your Cart is Empty',
                style: AppTypography.headlineLG(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Explore our Place Vendôme fine jewelry commissions or design your custom tooth-by-tooth 3D arch.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodySM(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppButton.primary(
                    text: 'EXPLORE COLLECTIONS',
                    width: 190,
                    height: 46,
                    onPressed: () => context.go('/home'),
                  ),
                ],
              ),
              const SizedBox(height: 36),
              // Section Header
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Recommended For You',
                  style: AppTypography.headlineMD(color: AppColors.textPrimary).copyWith(fontSize: 16),
                ),
              ),
              const SizedBox(height: 12),
              // Horizontal Preview Grid (280 height to give ample room for cards)
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: MockDataService.products.length,
                  itemBuilder: (context, index) {
                    final product = MockDataService.products[index];
                    return Container(
                      width: 155,
                      margin: const EdgeInsets.only(right: 12),
                      child: ProductCard(
                        product: product,
                        onTap: () => context.push('/product/${product.id}'),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
