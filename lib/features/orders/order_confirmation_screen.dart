import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';
import '../../core/services/cart_provider.dart';
import '../../core/services/order_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 15: order_confirmation_tracking
/// Post-checkout confirmation screen with live timeline tracking and certificate download
class OrderConfirmationScreen extends StatefulWidget {
  final CommissionOrder? order;

  const OrderConfirmationScreen({super.key, this.order});

  @override
  State<OrderConfirmationScreen> createState() => _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Clear cart once order is confirmed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).clearCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrder = widget.order ??
        orderProvider.lastCreatedOrder ??
        (orderProvider.orders.isNotEmpty ? orderProvider.orders.first : null);

    final commissionNumber = activeOrder?.commissionNumber ?? '#HK-2026-8942';
    final estDelivery = activeOrder?.estimatedDelivery ?? 'OCT 12, 2026';
    final deliveryAddress = activeOrder?.deliveryAddress ?? 'Victoria Island Penthouse 4B, Lagos, Nigeria';
    final steps = activeOrder?.trackingSteps ?? const [];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          'COMMISSION CONFIRMATION',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Gold Crest Success Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(Icons.check, color: AppColors.primaryGold, size: 40),
              ),
              const SizedBox(height: 18),
              Text(
                'Commission Confirmed',
                style: AppTypography.headlineXL(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                'Commission $commissionNumber • Escrow Secured',
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 24),

              // Production & Transit Timeline Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                  boxShadow: const [AppColors.softCardShadow],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          child: Text(
                            'ATELIER PRODUCTION LOG',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        AppBadgeChip(
                          label: 'EST. ARRIVAL: $estDelivery',
                          variant: BadgeChipVariant.goldPurity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    if (steps.isNotEmpty)
                      ...List.generate(steps.length, (index) {
                        final step = steps[index];
                        return _buildTimelineStep(
                          title: step.title,
                          subtitle: step.description,
                          time: step.timestamp,
                          isCompleted: step.isCompleted,
                          isCurrent: step.isCurrent,
                          isLast: index == steps.length - 1,
                        );
                      })
                    else ...[
                      _buildTimelineStep(
                        title: 'Escrow Secured & CAD Verified',
                        subtitle: 'Payment confirmed via Flutterwave escrow. Jewelry specifications verified by master jeweler.',
                        time: 'Confirmed',
                        isCompleted: true,
                        isCurrent: false,
                      ),
                      _buildTimelineStep(
                        title: 'Precision Lost-Wax Investment Casting',
                        subtitle: 'Hand-poured 18K solid royal gold ingot casting in progress.',
                        time: 'In Progress',
                        isCompleted: false,
                        isCurrent: true,
                      ),
                      _buildTimelineStep(
                        title: 'Microscopic Pavé Diamond Setting',
                        subtitle: 'Hand-setting VVS1 colorless melee diamonds under 40x Leica microscope.',
                        time: 'Upcoming',
                        isCompleted: false,
                        isCurrent: false,
                        isLast: true,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Armored Delivery Location Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outlineLight),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.goldContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.location_on, color: AppColors.primaryGold, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Armored Delivery Destination', style: AppTypography.labelMD(color: AppColors.textPrimary)),
                          const SizedBox(height: 2),
                          Text(
                            deliveryAddress,
                            style: AppTypography.bodyXS(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Actions: Track in Detail & Return Home
              AppButton.primary(
                text: 'VIEW LIVE TELEMETRY',
                height: 50,
                onPressed: () {
                  final id = activeOrder?.id.isNotEmpty == true ? activeOrder!.id : 'ord_1';
                  context.push('/commission-tracker/$id');
                },
                prefixIcon: const Icon(Icons.gps_fixed, size: 18, color: AppColors.textOnGold),
              ),
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'RETURN TO ATELIER DISCOVERY',
                height: 50,
                onPressed: () => context.go('/home'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineStep({
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    required bool isCurrent,
    bool isLast = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.primaryGold
                    : (isCurrent ? AppColors.darkBase : AppColors.surfaceContainerHigh),
                border: Border.all(
                  color: isCurrent ? AppColors.primaryGold : (isCompleted ? AppColors.primaryGold : AppColors.outline),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: Colors.black)
                  : (isCurrent ? const Center(child: Icon(Icons.circle, size: 8, color: AppColors.primaryGold)) : null),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 48,
                color: isCompleted ? AppColors.primaryGold : AppColors.outlineLight,
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.labelMD(
                  color: isCurrent ? AppColors.primaryGold : (isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: AppTypography.bodyXS(color: AppColors.textMuted).copyWith(fontSize: 10),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
