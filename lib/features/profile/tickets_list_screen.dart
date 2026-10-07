import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/support_ticket.dart';
import '../../core/services/ticket_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen: tickets_list_screen
/// Lists patron support tickets with live status and detail navigation
class TicketsListScreen extends StatefulWidget {
  const TicketsListScreen({super.key});

  @override
  State<TicketsListScreen> createState() => _TicketsListScreenState();
}

class _TicketsListScreenState extends State<TicketsListScreen> {
  List<SupportTicket> _tickets = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchTickets();
  }

  Future<void> _fetchTickets() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final tickets = await ticketService.getMyTickets();
      if (mounted) {
        setState(() {
          _tickets = tickets;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not retrieve support tickets.';
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildEmptyIllustration() {
    return SizedBox(
      width: 180,
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGold.withValues(alpha: 0.16),
                  AppColors.primaryGold.withValues(alpha: 0.04),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surface,
              border: Border.all(
                color: AppColors.primaryGold.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: const [AppColors.goldGlow],
            ),
          ),
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.darkBase,
                  AppColors.darkCard,
                ],
              ),
              border: Border.all(color: AppColors.primaryGold, width: 1.5),
            ),
            child: const Center(
              child: Icon(
                Icons.support_agent_outlined,
                size: 40,
                color: AppColors.primaryGold,
              ),
            ),
          ),
          const Positioned(
            top: 20,
            right: 30,
            child: Icon(Icons.auto_awesome, size: 16, color: AppColors.primaryGold),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: 'SUPPORT TICKETS',
        showBack: true,
        showCart: false,
        showWishlist: false,
      ),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: _fetchTickets,
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                ),
              )
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 44, color: AppColors.error),
                          const SizedBox(height: 12),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: AppTypography.bodyMD(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 16),
                          AppButton.outline(
                            text: 'RETRY',
                            width: 120,
                            onPressed: _fetchTickets,
                          ),
                        ],
                      ),
                    ),
                  )
                : _tickets.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildEmptyIllustration(),
                              const SizedBox(height: 24),
                              Text(
                                'No Support Tickets Found',
                                style: AppTypography.headlineXL(color: AppColors.textPrimary),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'You have not opened any inquiries with the atelier concierge yet.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMD(color: AppColors.textSecondary).copyWith(
                                    height: 1.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 28),
                              AppButton.primary(
                                text: 'RETURN TO PROFILE',
                                width: 200,
                                height: 48,
                                onPressed: () => Navigator.of(context).maybePop(),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        itemCount: _tickets.length,
                        itemBuilder: (context, index) {
                          final ticket = _tickets[index];
                          final isClosed = ticket.status.toLowerCase() == 'closed' ||
                              ticket.status.toLowerCase() == 'resolved';

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
                                onTap: () async {
                                  await context.push(
                                    '/ticket-detail/${ticket.id}',
                                    extra: ticket,
                                  );
                                  _fetchTickets();
                                },
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header: Ticket Number & Status Pill
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            ticket.ticketNumber,
                                            style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                          AppBadgeChip(
                                            label: ticket.status.toUpperCase(),
                                            variant: isClosed
                                                ? BadgeChipVariant.statusSage
                                                : BadgeChipVariant.statusGold,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Subject
                                      Text(
                                        ticket.subject,
                                        style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(
                                          fontSize: 15,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 6),

                                      // Message Preview
                                      Text(
                                        ticket.message,
                                        style: AppTypography.bodyXS(color: AppColors.textSecondary),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 12),
                                      const Divider(height: 1),
                                      const SizedBox(height: 10),

                                      // Bottom Info: Category, Order ID & Replies Count
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppColors.surfaceContainerLow,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              ticket.category,
                                              style: AppTypography.labelSM(color: AppColors.textSecondary).copyWith(
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          if (ticket.orderId != null && ticket.orderId!.isNotEmpty) ...[
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppColors.goldContainer.withValues(alpha: 0.3),
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                'Order: ${ticket.orderId}',
                                                style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ),
                                          ],
                                          const Spacer(),
                                          Row(
                                            children: [
                                              const Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.primaryGold),
                                              const SizedBox(width: 4),
                                              Text(
                                                '${ticket.responses.length} replies',
                                                style: AppTypography.labelSM(color: AppColors.textPrimary).copyWith(
                                                  fontSize: 11,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.textMuted),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}
