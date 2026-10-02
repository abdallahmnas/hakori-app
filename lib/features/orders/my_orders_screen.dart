import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/mock_data_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen 16: my_orders_commission_history
/// Orders & Commissions hub with active production status tabs and history cards
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(
        title: 'COMMISSIONS',
        showBack: false,
      ),
      body: Column(
        children: [
          // Tab Bar
          Container(
            color: AppColors.surface,
            child: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primaryGold,
              indicatorWeight: 2.5,
              labelColor: AppColors.primaryGold,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.labelSM(),
              tabs: const [
                Tab(text: 'ACTIVE (1)'),
                Tab(text: 'COMPLETED (1)'),
                Tab(text: 'SAVED QUOTES (2)'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Active Orders Tab
                _buildOrderList([MockDataService.orders[0]]),
                // Completed Orders Tab
                _buildOrderList([MockDataService.orders[1]]),
                // Saved Quotes Tab
                _buildQuotesList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List orders) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final firstItem = order.items.first;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineLight),
            boxShadow: const [AppColors.softCardShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Bar: Commission # and Status Pill (Flexible & responsive to prevent overflow)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 5,
                    child: Text(
                      order.commissionNumber,
                      style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    flex: 6,
                    child: AppBadgeChip(
                      label: order.status.toUpperCase(),
                      variant: order.status.contains('Delivered')
                          ? BadgeChipVariant.statusSage
                          : BadgeChipVariant.statusGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'Placed on ${order.date} • ${order.jewelerName}',
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const Divider(height: 18),
              // Item Row
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      firstItem.imageUrl,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 58,
                        height: 58,
                        color: AppColors.surfaceContainerLow,
                        child: const Icon(Icons.diamond, color: AppColors.primaryGold, size: 22),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          firstItem.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(fontSize: 13),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          firstItem.purity,
                          style: AppTypography.bodyXS(color: AppColors.textSecondary).copyWith(fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        DualPriceText(
                          priceUsd: order.totalUsd,
                          priceNgn: order.totalNgn,
                          primaryStyle: AppTypography.priceDisplay().copyWith(fontSize: 14),
                          secondaryStyle: AppTypography.priceSecondary().copyWith(fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Track Button
              InkWell(
                onTap: () => context.push('/commission-tracker/${order.id}'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.radar, size: 15, color: AppColors.primaryGold),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'VIEW LIVE TRANSIT & PRODUCTION TRACKER',
                              style: AppTypography.labelSM(color: AppColors.textPrimary).copyWith(fontSize: 9),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuotesList() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.bookmark_border, size: 44, color: AppColors.primaryGold),
            const SizedBox(height: 10),
            Text(
              '2 Saved Bespoke CAD Quotes',
              style: AppTypography.headlineMD(color: AppColors.textPrimary).copyWith(fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Quotes remain locked against gold spot volatility for 72 hours.',
              textAlign: TextAlign.center,
              style: AppTypography.bodySM(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
