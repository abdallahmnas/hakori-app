import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/currency_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/dual_price_text.dart';
import 'empty_bag_screen.dart';

import '../../core/services/auth_provider.dart';
import '../../core/services/order_provider.dart';

/// Screen 13: cart_multi_currency_checkout
/// Simplified Cart & Checkout screen with clean items, currency indicator, and direct checkout trigger
class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final TextEditingController _promoController = TextEditingController();
  bool _isCheckingOut = false;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo(CartProvider cart) {
    if (_promoController.text.trim().isNotEmpty) {
      final success = cart.applyPromoCode(_promoController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'VIP Code Applied: 10% Privilege' : 'Invalid Code. Try "HAKORI2026"',
          ),
          backgroundColor: success ? AppColors.darkBase : AppColors.error,
        ),
      );
    }
  }

  Future<void> _handleCheckout() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final clientUser = auth.currentUser;
    final client = {
      'name': clientUser?.fullName.isNotEmpty == true ? clientUser!.fullName : 'Lord Alexander Wright',
      'email': clientUser?.email.isNotEmpty == true ? clientUser!.email : 'patron@aurumatelier.com',
      'phone': clientUser?.phone?.isNotEmpty == true ? clientUser!.phone : '+234 801 234 5678',
    };

    final firstItem = cart.items.first;
    final specimen = {
      'title': firstItem.product.name,
      'specDetails': '${firstItem.selectedMetal} • ${firstItem.selectedStone}',
      'caratOrPurity': firstItem.selectedMetal,
      'subType': firstItem.selectedArch,
      'qty': cart.itemCount,
    };

    setState(() => _isCheckingOut = true);

    final order = await orderProvider.placeOrder(
      client: client,
      specimen: specimen,
      total: cart.totalUsd,
      currency: 'USD',
      shippingAddress: clientUser?.location ?? 'Victoria Island Penthouse 4B, Lagos, Nigeria',
    );

    if (!mounted) return;
    setState(() => _isCheckingOut = false);

    if (order != null) {
      cart.clearCart();
      context.push('/order-confirmation', extra: order);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(orderProvider.errorMessage ?? 'Checkout failed. Please try again.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    if (cart.items.isEmpty) {
      return const EmptyBagScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: 'CART (${cart.itemCount})',
        showBack: false,
        showCart: false,
      ),
      body: CustomScrollView(
        slivers: [
          // Currency Indicator Bar
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.goldContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.outlineGold),
              ),
              child: Row(
                children: [
                  Text(
                    currencyProvider.selectedCurrency.flagEmoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Currency: ${currencyProvider.selectedCurrency.code} (${currencyProvider.selectedCurrency.name})',
                      style: AppTypography.labelSM(color: AppColors.onGoldContainer).copyWith(fontSize: 11),
                    ),
                  ),
                  InkWell(
                    onTap: () => context.push('/fx-ledger'),
                    child: Text(
                      'CHANGE',
                      style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                        fontSize: 11,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Cart Items List
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = cart.items[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.outlineLight),
                      boxShadow: const [AppColors.softCardShadow],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thumbnail
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                item.product.imageUrl,
                                width: 64,
                                height: 64,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 64,
                                  height: 64,
                                  color: AppColors.surfaceContainerLow,
                                  child: const Icon(Icons.diamond, color: AppColors.primaryGold, size: 24),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Title & Specs
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(fontSize: 14),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${item.selectedMetal} • ${item.selectedStone}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyXS(color: AppColors.textSecondary),
                                  ),
                                  const SizedBox(height: 4),
                                  DualPriceText(
                                    priceUsd: item.totalPriceUsd,
                                    priceNgn: item.totalPriceNgn,
                                    primaryStyle: AppTypography.priceDisplay().copyWith(fontSize: 15),
                                    secondaryStyle: AppTypography.priceSecondary().copyWith(fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            // Remove Button
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                              icon: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
                              onPressed: () => cart.removeItem(item.id),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        // Impression Kit Checkbox & Quantity Stepper
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: InkWell(
                                onTap: () => cart.toggleImpressionKit(item.id),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: Checkbox(
                                        value: item.impressionKitIncluded,
                                        activeColor: AppColors.primaryGold,
                                        checkColor: AppColors.textOnGold,
                                        onChanged: (val) => cart.toggleImpressionKit(item.id),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        'Impression Kit (FREE)',
                                        style: AppTypography.bodyXS(color: AppColors.textPrimary).copyWith(fontSize: 11),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Quantity Stepper
                            Container(
                              height: 30,
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLow,
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(color: AppColors.outlineLight),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, -1),
                                    borderRadius: BorderRadius.circular(15),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.remove, size: 12),
                                    ),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(fontSize: 12),
                                  ),
                                  InkWell(
                                    onTap: () => cart.updateQuantity(item.id, 1),
                                    borderRadius: BorderRadius.circular(15),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 8),
                                      child: Icon(Icons.add, size: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
                childCount: cart.items.length,
              ),
            ),
          ),

          // Vault Courier Insurance Toggle
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: AppColors.primaryGold, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Armored Vault Insurance (\$150.00)',
                          style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(fontSize: 12),
                        ),
                        Text(
                          '100% loss/damage guarantee during transit',
                          style: AppTypography.bodyXS(color: AppColors.textSecondary).copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: cart.vaultInsurance,
                    activeColor: AppColors.primaryGold,
                    onChanged: (val) => cart.toggleVaultInsurance(val),
                  ),
                ],
              ),
            ),
          ),

          // Promo Code Row
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        controller: _promoController,
                        style: AppTypography.bodySM(),
                        decoration: InputDecoration(
                          hintText: 'Promo Code (HAKORI2026)',
                          hintStyle: AppTypography.bodyXS(color: AppColors.textMuted),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppButton.dark(
                    text: 'APPLY',
                    width: 75,
                    height: 40,
                    borderRadius: 10,
                    onPressed: () => _applyPromo(cart),
                  ),
                ],
              ),
            ),
          ),

          // Order Summary
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 110),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                children: [
                  _buildSummaryRow('Subtotal', currencyProvider.formatPrice(cart.subtotalUsd)),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Jewelry Sizing Kit', 'FREE'),
                  const SizedBox(height: 6),
                  _buildSummaryRow('Vault Insurance', cart.vaultInsurance ? currencyProvider.formatPrice(cart.insuranceCostUsd) : 'Waived'),
                  if (cart.discountPercentage > 0) ...[
                    const SizedBox(height: 6),
                    _buildSummaryRow(
                      'VIP Privilege (10%)',
                      '- ${currencyProvider.formatPrice(cart.subtotalUsd * cart.discountPercentage)}',
                      isHighlight: true,
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total',
                        style: AppTypography.headlineSM(color: AppColors.textPrimary),
                      ),
                      Text(
                        currencyProvider.formatPrice(cart.totalUsd),
                        style: AppTypography.headlineMD(color: AppColors.primaryGold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Simplified Bottom Checkout Button
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.outlineLight)),
          boxShadow: [
            BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: AppButton.primary(
            text: _isCheckingOut ? 'SECURING ESCROW...' : 'CHECKOUT',
            height: 50,
            onPressed: _isCheckingOut ? null : _handleCheckout,
            suffixIcon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.textOnGold),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyXS(color: isHighlight ? AppColors.emeraldGreen : AppColors.textSecondary),
        ),
        Text(
          value,
          style: AppTypography.labelSM(color: isHighlight ? AppColors.emeraldGreen : AppColors.textPrimary),
        ),
      ],
    );
  }
}
