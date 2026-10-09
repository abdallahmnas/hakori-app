import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';
import '../../core/services/order_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen 17: commission_details_live_transit_tracker
/// Live GPS & Stage-by-Stage Production Telemetry for bespoke high-jewelry commissions
class CommissionTrackerScreen extends StatefulWidget {
  final String orderId;

  const CommissionTrackerScreen({super.key, required this.orderId});

  @override
  State<CommissionTrackerScreen> createState() =>
      _CommissionTrackerScreenState();
}

class _CommissionTrackerScreenState extends State<CommissionTrackerScreen> {
  CommissionOrder? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrder());
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final order = await orderProvider.getOrderById(widget.orderId);
    if (mounted) {
      setState(() {
        _order = order;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'COMMISSION TRACKER',
            style: AppTypography.labelLG(
              color: AppColors.textPrimary,
            ).copyWith(letterSpacing: 2),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
          ),
        ),
      );
    }

    if (_order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 18),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(
            'NOT FOUND',
            style: AppTypography.labelLG(
              color: AppColors.textPrimary,
            ).copyWith(letterSpacing: 2),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off_outlined,
                  size: 48,
                  color: AppColors.textMuted,
                ),
                const SizedBox(height: 16),
                Text(
                  'Commission Record Not Found',
                  style: AppTypography.headlineSM(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'No active atelier commission was located with this identification reference.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                AppButton.outline(
                  text: 'RETURN TO COMMISSIONS',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = _order!;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          order.commissionNumber,
          style: AppTypography.labelLG(
            color: AppColors.textPrimary,
          ).copyWith(letterSpacing: 2),
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
                                order.trackingNumber ?? "",
                                style: AppTypography.labelSM(
                                  color: AppColors.textMuted,
                                ),
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
                                Text(
                                  'ORIGIN',
                                  style: AppTypography.labelSM(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Paris Vendôme',
                                  style: AppTypography.headlineSM(
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ],
                            ),
                            const Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Divider(
                                  color: AppColors.primaryGold,
                                  thickness: 1.5,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'DESTINATION',
                                  style: AppTypography.labelSM(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Text(
                                  'Lagos Salon',
                                  style: AppTypography.headlineSM(
                                    color: AppColors.textOnDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Text(
                          'Estimated Delivery: ${order.estimatedDelivery}',
                          style: AppTypography.bodyXS(
                            color: AppColors.goldAccent,
                          ),
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
                    child: const Icon(
                      Icons.person_pin,
                      color: AppColors.primaryGold,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assigned Master Jeweler',
                          style: AppTypography.bodyXS(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          order.jewelerName ?? "",
                          style: AppTypography.headlineSM(
                            color: AppColors.textPrimary,
                          ),
                        ),
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

            // Commission Specimen Details Card
            Container(
              padding: const EdgeInsets.all(16),
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
                      Text(
                        'COMMISSION SPECIMEN',
                        style: AppTypography.labelSM(
                          color: AppColors.primaryGold,
                        ).copyWith(letterSpacing: 1.5),
                      ),
                      if (order.paymentStatus != null)
                        AppBadgeChip(
                          label: order.paymentStatus!.toUpperCase(),
                          variant:
                              order.paymentStatus!.toUpperCase() == 'PAID' ||
                                  order.paymentStatus!.toUpperCase() ==
                                      'SETTLED'
                              ? BadgeChipVariant.statusSage
                              : BadgeChipVariant.statusGold,
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          order.specimenImage,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                width: 72,
                                height: 72,
                                color: AppColors.surfaceContainerLow,
                                child: const Icon(
                                  Icons.diamond,
                                  color: AppColors.primaryGold,
                                  size: 28,
                                ),
                              ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.specimenTitle,
                              style: AppTypography.headlineSM(
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              order.specimen?['specDetails']?.toString() ??
                                  order.specimen?['caratOrPurity']
                                      ?.toString() ??
                                  (order.items.isNotEmpty
                                      ? order.items.first.material
                                      : '18K Solid Gold'),
                              style: AppTypography.bodyXS(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (order.specimen?['subType'] != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                'Discipline: ${order.specimen!['subType']}',
                                style: AppTypography.bodyXS(
                                  color: AppColors.textMuted,
                                ).copyWith(fontSize: 10),
                              ),
                            ],
                            const SizedBox(height: 6),
                            DualPriceText(
                              priceUsd: order.totalUsd,
                              priceNgn: order.totalNgn,
                              primaryStyle: AppTypography.priceDisplay()
                                  .copyWith(fontSize: 16),
                              secondaryStyle: AppTypography.priceSecondary()
                                  .copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Step-by-Step Production Log
            if (order.trackingSteps.isNotEmpty) ...[
              Text(
                'Live production Log',
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
                                    : (step.isCurrent
                                          ? AppColors.darkBase
                                          : AppColors.surfaceContainerHigh),
                                border: Border.all(
                                  color: step.isCurrent || step.isCompleted
                                      ? AppColors.primaryGold
                                      : AppColors.outline,
                                ),
                              ),
                              child: step.isCompleted
                                  ? const Icon(
                                      Icons.check,
                                      size: 12,
                                      color: Colors.black,
                                    )
                                  : (step.isCurrent
                                        ? const Center(
                                            child: Icon(
                                              Icons.circle,
                                              size: 6,
                                              color: AppColors.primaryGold,
                                            ),
                                          )
                                        : null),
                            ),
                            if (!isLast)
                              Container(
                                width: 2,
                                height: 48,
                                color: step.isCompleted
                                    ? AppColors.primaryGold
                                    : AppColors.outlineLight,
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
                                      : (step.isCompleted
                                            ? AppColors.textPrimary
                                            : AppColors.textMuted),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.description,
                                style: AppTypography.bodyXS(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                step.timestamp,
                                style: AppTypography.bodyXS(
                                  color: AppColors.textMuted,
                                ).copyWith(fontSize: 10),
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
            ],

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
                  const Icon(
                    Icons.home_work_outlined,
                    color: AppColors.primaryGold,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Delivery Address',
                          style: AppTypography.bodyXS(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          order.deliveryAddress ?? "",
                          style: AppTypography.labelMD(
                            color: AppColors.textPrimary,
                          ),
                        ),
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
