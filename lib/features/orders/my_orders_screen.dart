import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/order.dart';
import '../../core/services/order_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/badge_chip.dart';
import '../../core/widgets/dual_price_text.dart';

/// Screen 16: my_orders_commission_history
/// Orders & Commissions hub with active production status tabs and history cards connected to OrderProvider
class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<OrderProvider>(context, listen: false).fetchOrders();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final activeOrders = orderProvider.activeOrders;
    final completedOrders = orderProvider.completedOrders;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(title: 'ORDERS', showBack: false),
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
              tabs: [
                Tab(text: 'ACTIVE (${activeOrders.length})'),
                Tab(text: 'COMPLETED (${completedOrders.length})'),
              ],
            ),
          ),
          // Tab Views
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primaryGold,
              backgroundColor: AppColors.darkBase,
              onRefresh: () => orderProvider.fetchOrders(),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Active Orders Tab
                  _buildOrderList(
                    activeOrders,
                    'No active orders currently in production.',
                  ),
                  // Completed Orders Tab
                  _buildOrderList(
                    completedOrders,
                    'No completed or delivered orders yet.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(List<CommissionOrder> orders, String emptyMsg) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (orderProvider.isLoading && orders.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
        ),
      );
    }

    if (orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.inventory_2_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'No Orders Found',
                style: AppTypography.headlineSM(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        final firstItem = order.items.isNotEmpty ? order.items.first : null;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.outlineLight),
            boxShadow: const [AppColors.softCardShadow],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: () => context.push('/order-info/${order.id}', extra: order),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Bar: Order # and Status Pill
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(
                            order.commissionNumber,
                            style: AppTypography.labelMD(
                              color: AppColors.textPrimary,
                            ).copyWith(fontWeight: FontWeight.bold, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          flex: 6,
                          child: AppBadgeChip(
                            label: order.status.toUpperCase(),
                            variant:
                                order.status.toLowerCase().contains('delivered') ||
                                    order.status.toLowerCase().contains('settled')
                                ? BadgeChipVariant.statusSage
                                : BadgeChipVariant.statusGold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Placed on ${order.date}${order.jewelerName != null && order.jewelerName!.isNotEmpty ? ' • ${order.jewelerName}' : ''}',
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
                            order.specimenImage,
                            width: 58,
                            height: 58,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 58,
                              height: 58,
                              color: AppColors.surfaceContainerLow,
                              child: const Icon(
                                Icons.diamond,
                                color: AppColors.primaryGold,
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                order.specimenTitle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.headlineSM(
                                  color: AppColors.textPrimary,
                                ).copyWith(fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                firstItem?.purity ?? (order.specimen?['caratOrPurity']?.toString() ?? '18K Solid Gold'),
                                style: AppTypography.bodyXS(
                                  color: AppColors.textSecondary,
                                ).copyWith(fontSize: 11),
                              ),
                              const SizedBox(height: 4),
                              DualPriceText(
                                priceUsd: order.totalUsd,
                                priceNgn: order.totalNgn,
                                primaryStyle: AppTypography.priceDisplay().copyWith(
                                  fontSize: 14,
                                ),
                                secondaryStyle: AppTypography.priceSecondary()
                                    .copyWith(fontSize: 10),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    // Details Action Button
                    Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.receipt_long_outlined,
                                size: 16,
                                color: AppColors.primaryGold,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'VIEW ORDER DETAILS',
                                style: AppTypography.labelSM(
                                  color: AppColors.textPrimary,
                                ).copyWith(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 12,
                                color: AppColors.textMuted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
