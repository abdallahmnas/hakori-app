import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';
import '../../core/services/order_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen: order_info_screen
/// Displays real order details passed from the orders list, omitting placeholders with no info
class OrderInfoScreen extends StatefulWidget {
  final String orderId;
  final CommissionOrder? initialOrder;

  const OrderInfoScreen({
    super.key,
    required this.orderId,
    this.initialOrder,
  });

  @override
  State<OrderInfoScreen> createState() => _OrderInfoScreenState();
}

class _OrderInfoScreenState extends State<OrderInfoScreen> {
  CommissionOrder? _order;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _order = widget.initialOrder;
    if (_order != null) {
      _isLoading = false;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrder());
  }

  Future<void> _loadOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final order = await orderProvider.getOrderById(widget.orderId);
    if (mounted && order != null) {
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } else if (mounted && _order == null) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _order == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const LuxuryAppBar(
          title: 'ORDER DETAILS',
          showBack: true,
          showCart: false,
          showWishlist: false,
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
        appBar: const LuxuryAppBar(
          title: 'ORDER NOT FOUND',
          showBack: true,
          showCart: false,
          showWishlist: false,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off_outlined, size: 48, color: AppColors.textMuted),
                const SizedBox(height: 16),
                Text(
                  'Order Record Not Found',
                  style: AppTypography.headlineSM(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),
                Text(
                  'No order was located with this identification reference.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                AppButton.outline(
                  text: 'RETURN TO ORDERS',
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final order = _order!;
    final isPaid = order.paymentStatus?.toUpperCase() == 'PAID' ||
        order.paymentStatus?.toUpperCase() == 'SETTLED' ||
        order.paymentStatus?.toUpperCase() == 'SUCCESSFUL';
    final hasPaymentUrl = order.paymentUrl != null && order.paymentUrl!.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: order.commissionNumber,
        showBack: true,
        showCart: false,
        showWishlist: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: _loadOrder,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Order Status & Total Overview Card
              _buildOverviewCard(order),
              const SizedBox(height: 16),

              // 2. Pending Payment Action Card (Only if payment is pending and paymentUrl exists)
              if (!isPaid && hasPaymentUrl) ...[
                _buildPaymentActionCard(order),
                const SizedBox(height: 16),
              ],

              // 3. Specimen & Items Card
              _buildSpecimenCard(order),
              const SizedBox(height: 16),

              // 4. Client Details (Only if client info exists)
              if (_hasClientInfo(order.client)) ...[
                _buildClientCard(order.client!),
                const SizedBox(height: 16),
              ],

              // 5. Logistics / Delivery Card (Only if tracking or delivery address exists)
              if (_hasLogisticsInfo(order)) ...[
                _buildLogisticsCard(order),
                const SizedBox(height: 16),
              ],

              // 6. Assigned Master Jeweler (Only if jewelerName is present)
              if (order.jewelerName != null && order.jewelerName!.isNotEmpty) ...[
                _buildJewelerCard(order.jewelerName!),
                const SizedBox(height: 16),
              ],

              // 7. Production Tracking Steps (Only if real tracking steps exist)
              if (order.trackingSteps.isNotEmpty) ...[
                _buildTrackingStepsCard(order.trackingSteps),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCard(CommissionOrder order) {
    final isDelivered = order.status.toLowerCase().contains('delivered') ||
        order.status.toLowerCase().contains('settled');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
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
                order.commissionNumber,
                style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              AppBadgeChip(
                label: order.status.toUpperCase(),
                variant: isDelivered ? BadgeChipVariant.statusSage : BadgeChipVariant.statusGold,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Order Placed: ${order.date}',
            style: AppTypography.bodyXS(color: AppColors.textSecondary),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL AMOUNT',
                    style: AppTypography.labelSM(color: AppColors.textMuted).copyWith(
                      fontSize: 10,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DualPriceText(
                    priceUsd: order.totalUsd,
                    priceNgn: order.totalNgn,
                    primaryStyle: AppTypography.priceDisplay().copyWith(fontSize: 18),
                    secondaryStyle: AppTypography.priceSecondary().copyWith(fontSize: 11),
                  ),
                ],
              ),
              if (order.paymentStatus != null && order.paymentStatus!.isNotEmpty)
                AppBadgeChip(
                  label: 'PAYMENT: ${order.paymentStatus!.toUpperCase()}',
                  variant: order.paymentStatus!.toUpperCase() == 'PAID' ||
                          order.paymentStatus!.toUpperCase() == 'SETTLED'
                      ? BadgeChipVariant.statusSage
                      : BadgeChipVariant.statusGold,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentActionCard(CommissionOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBase,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primaryGold.withValues(alpha: 0.4)),
        boxShadow: const [AppColors.goldGlow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: AppColors.primaryGold, size: 20),
              const SizedBox(width: 8),
              Text(
                'Payment Pending',
                style: AppTypography.headlineSM(color: AppColors.textOnDark).copyWith(
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Complete your secure escrow payment via Flutterwave to initiate atelier casting.',
            style: AppTypography.bodyXS(color: AppColors.surfaceContainerHigh),
          ),
          const SizedBox(height: 12),
          AppButton.primary(
            text: 'PAY NOW WITH FLUTTERWAVE',
            height: 44,
            onPressed: () {
              context.push(
                '/payment-webview',
                extra: {
                  'url': order.paymentUrl,
                  'order': order,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpecimenCard(CommissionOrder order) {
    final spec = order.specimen;
    final specDetails = spec?['specDetails']?.toString();
    final caratOrPurity = spec?['caratOrPurity']?.toString();
    final subType = spec?['subType']?.toString();
    final qty = spec?['qty']?.toString();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: const [AppColors.softCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SPECIMEN & ITEMS',
            style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  order.specimenImage,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 80,
                    height: 80,
                    color: AppColors.surfaceContainerLow,
                    child: const Icon(Icons.diamond, color: AppColors.primaryGold, size: 30),
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
                      style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(
                        fontSize: 15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (specDetails != null && specDetails.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        specDetails,
                        style: AppTypography.bodyXS(color: AppColors.textSecondary),
                      ),
                    ],
                    if (caratOrPurity != null && caratOrPurity.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Purity: $caratOrPurity',
                        style: AppTypography.bodyXS(color: AppColors.textSecondary),
                      ),
                    ],
                    if (subType != null && subType.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Series: $subType',
                        style: AppTypography.bodyXS(color: AppColors.textMuted),
                      ),
                    ],
                    if (qty != null && qty.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Quantity: $qty',
                        style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasClientInfo(Map<String, dynamic>? client) {
    if (client == null) return false;
    final name = client['name']?.toString();
    final email = client['email']?.toString();
    final phone = client['phone']?.toString();
    return (name != null && name.isNotEmpty) ||
        (email != null && email.isNotEmpty) ||
        (phone != null && phone.isNotEmpty);
  }

  Widget _buildClientCard(Map<String, dynamic> client) {
    final name = client['name']?.toString() ?? 'Patron';
    final email = client['email']?.toString();
    final phone = client['phone']?.toString();
    final initials = client['avatarInitials']?.toString() ??
        (name.isNotEmpty ? name[0].toUpperCase() : 'P');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: const [AppColors.softCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PATRON INFORMATION',
            style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.15),
                child: Text(
                  initials,
                  style: const TextStyle(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (email != null && email.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        email,
                        style: AppTypography.bodyXS(color: AppColors.textSecondary),
                      ),
                    ],
                    if (phone != null && phone.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        phone,
                        style: AppTypography.bodyXS(color: AppColors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasLogisticsInfo(CommissionOrder order) {
    return (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ||
        (order.trackingNumber != null && order.trackingNumber!.isNotEmpty) ||
        (order.estimatedDelivery != null && order.estimatedDelivery!.isNotEmpty);
  }

  Widget _buildLogisticsCard(CommissionOrder order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: const [AppColors.softCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'DELIVERY & LOGISTICS',
            style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (order.trackingNumber != null && order.trackingNumber!.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.qr_code, size: 18, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Tracking Number', style: AppTypography.labelSM(color: AppColors.textMuted)),
                      Text(
                        order.trackingNumber!,
                        style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 16, color: AppColors.primaryGold),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: order.trackingNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Tracking number copied to clipboard'),
                        backgroundColor: AppColors.darkBase,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
            const Divider(height: 16),
          ],
          if (order.deliveryAddress != null && order.deliveryAddress!.isNotEmpty) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined, size: 18, color: AppColors.primaryGold),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Shipping Address', style: AppTypography.labelSM(color: AppColors.textMuted)),
                      const SizedBox(height: 2),
                      Text(
                        order.deliveryAddress!,
                        style: AppTypography.bodySM(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
          if (order.estimatedDelivery != null && order.estimatedDelivery!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.schedule, size: 16, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Text(
                  'Estimated Delivery: ${order.estimatedDelivery}',
                  style: AppTypography.bodyXS(color: AppColors.textMuted),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildJewelerCard(String jeweler) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.diamond_outlined, color: AppColors.primaryGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assigned Jeweler', style: AppTypography.labelSM(color: AppColors.textMuted)),
                Text(jeweler, style: AppTypography.labelLG(color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingStepsCard(List<TrackingStep> steps) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outlineLight),
        boxShadow: const [AppColors.softCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRODUCTION TIMELINE',
            style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 14),
          ...steps.asMap().entries.map((entry) {
            final index = entry.key;
            final step = entry.value;
            final isLast = index == steps.length - 1;

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 18,
                      height: 18,
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
                          ? const Icon(Icons.check, size: 10, color: Colors.black)
                          : (step.isCurrent
                              ? const Center(
                                  child: Icon(Icons.circle, size: 5, color: AppColors.primaryGold),
                                )
                              : null),
                    ),
                    if (!isLast)
                      Container(
                        width: 2,
                        height: 36,
                        color: step.isCompleted ? AppColors.primaryGold : AppColors.outlineLight,
                      ),
                  ],
                ),
                const SizedBox(width: 12),
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
                      if (step.description.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.description,
                          style: AppTypography.bodyXS(color: AppColors.textSecondary),
                        ),
                      ],
                      if (step.timestamp.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          step.timestamp,
                          style: AppTypography.bodyXS(color: AppColors.textMuted).copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}
