import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 17: commission_details_live_transit_tracker
/// Live GPS & Stage-by-Stage Production Telemetry for bespoke high-jewelry commissions
class CommissionTrackerScreen extends StatelessWidget {
  final String orderId;

  const CommissionTrackerScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    final order = MockDataService.orders.firstWhere(
      (o) => o.id == orderId,
      orElse: () => MockDataService.orders[0],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          order.commissionNumber,
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Armored Live Courier Route Card
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: AppColors.darkBase,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.darkBorder),
                boxShadow: const [AppColors.goldGlow],
              ),
              child: Stack(
                children: [
                  // Map Grid Lines visual
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.2,
                      child: Image.network(
                        'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=600&auto=format&fit=crop',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Flexible(
                              child: AppBadgeChip(
                                label: 'ARMORED ESCROW TRANSIT',
                                variant: BadgeChipVariant.goldPurity,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                order.trackingNumber,
                                style: AppTypography.labelSM(color: AppColors.textMuted),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ORIGIN', style: AppTypography.labelSM(color: AppColors.textMuted)),
                                Text('Paris Vendôme', style: AppTypography.headlineSM(color: AppColors.textOnDark)),
                              ],
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(color: AppColors.primaryGold, thickness: 1.5),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('DESTINATION', style: AppTypography.labelSM(color: AppColors.textMuted)),
                                Text('Lagos Salon', style: AppTypography.headlineSM(color: AppColors.textOnDark)),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'Estimated Delivery: ${order.estimatedDelivery}',
                          style: AppTypography.bodyXS(color: AppColors.goldAccent),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Assigned Master Jeweler Card
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
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkCard,
                      border: Border.all(color: AppColors.primaryGold),
                    ),
                    child: const Icon(Icons.person_pin, color: AppColors.primaryGold, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Assigned Master Jeweler', style: AppTypography.bodyXS(color: AppColors.textSecondary)),
                        Text(order.jewelerName, style: AppTypography.headlineSM(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                  AppButton.outline(
                    text: 'CONCIERGE',
                    width: 100,
                    height: 36,
                    borderRadius: 18,
                    onPressed: () => context.push('/live-call'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step-by-Step Production Log
            Text(
              'Live Atelier Production Log',
              style: AppTypography.headlineMD(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 14),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Column(
                children: order.trackingSteps.asMap().entries.map((entry) {
                  final index = entry.key;
                  final step = entry.value;
                  final isLast = index == order.trackingSteps.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: step.isCompleted
                                  ? AppColors.primaryGold
                                  : (step.isCurrent ? AppColors.darkBase : AppColors.surfaceContainerHigh),
                              border: Border.all(
                                color: step.isCurrent || step.isCompleted
                                    ? AppColors.primaryGold
                                    : AppColors.outline,
                              ),
                            ),
                            child: step.isCompleted
                                ? const Icon(Icons.check, size: 12, color: Colors.black)
                                : (step.isCurrent
                                    ? const Center(
                                        child: Icon(Icons.circle, size: 6, color: AppColors.primaryGold))
                                    : null),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 48,
                              color: step.isCompleted ? AppColors.primaryGold : AppColors.outlineLight,
                            ),
                        ],
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.title,
                              style: AppTypography.labelMD(
                                color: step.isCurrent
                                    ? AppColors.primaryGold
                                    : (step.isCompleted ? AppColors.textPrimary : AppColors.textMuted),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.description,
                              style: AppTypography.bodyXS(color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              step.timestamp,
                              style: AppTypography.bodyXS(color: AppColors.textMuted).copyWith(fontSize: 10),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),

            // Delivery Address Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.outlineLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.home_work_outlined, color: AppColors.primaryGold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Armored Delivery Address', style: AppTypography.bodyXS(color: AppColors.textSecondary)),
                        const SizedBox(height: 2),
                        Text(order.deliveryAddress, style: AppTypography.labelMD(color: AppColors.textPrimary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
