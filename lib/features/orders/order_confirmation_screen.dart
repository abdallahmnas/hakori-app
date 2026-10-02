import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/cart_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 15: order_confirmation_tracking
/// Post-checkout confirmation screen with live timeline tracking and certificate download
class OrderConfirmationScreen extends StatefulWidget {
  const OrderConfirmationScreen({super.key});

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
                'Commission #HK-2026-8942 • Escrow Secured',
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
                      children: const [
                        Expanded(
                          child: Text(
                            'ATELIER PRODUCTION LOG',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(width: 8),
                        AppBadgeChip(
                          label: 'EST. ARRIVAL: OCT 02',
                          variant: BadgeChipVariant.goldPurity,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildTimelineItem(
                      title: '1. Vault Escrow & Order Authenticated',
                      subtitle: 'Payment verified with 256-bit encryption.',
                      time: 'Today, 10:45 AM',
                      isCompleted: true,
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      title: '2. 3D Dental Impression Kit Dispatched',
                      subtitle: 'Express DHL courier dispatched with prepaid return bag.',
                      time: 'In Transit • Est. Tomorrow',
                      isCompleted: true,
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      title: '3. 3D Intraoral Scan Verified by DDS',
                      subtitle: 'Dr. Adebayo verifies 0.05mm margin accuracy.',
                      time: 'Pending Impression Return',
                      isCompleted: false,
                      isCurrent: true,
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      title: '4. Molten 18K Cast & Diamond Setting',
                      subtitle: 'Master Jeweler hand-sets each VVS stone in Paris.',
                      time: 'Est. Sept 26',
                      isCompleted: false,
                      isLast: false,
                    ),
                    _buildTimelineItem(
                      title: '5. Armored Diplomatic Vault Delivery',
                      subtitle: 'Hand-delivered to your registered address in VIP case.',
                      time: 'Est. Oct 02',
                      isCompleted: false,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Action Buttons
              AppButton.primary(
                text: 'TRACK LIVE TRANSIT',
                onPressed: () => context.push('/commission-tracker/ord_1'),
                suffixIcon: const Icon(Icons.location_on_outlined, size: 18, color: AppColors.textOnGold),
              ),
              const SizedBox(height: 12),
              AppButton.outline(
                text: 'DOWNLOAD CERTIFICATE OF AUTHENTICITY (PDF)',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Downloading 18K Gold Certificate of Authenticity...')),
                  );
                },
                prefixIcon: const Icon(Icons.picture_as_pdf_outlined, size: 18, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 12),
              AppButton.ghost(
                text: 'RETURN TO ATELIER HOME',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String subtitle,
    required String time,
    required bool isCompleted,
    bool isCurrent = false,
    required bool isLast,
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
