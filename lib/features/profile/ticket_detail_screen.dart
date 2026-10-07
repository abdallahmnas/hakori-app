import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/support_ticket.dart';
import '../../core/services/ticket_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen: ticket_detail_screen
/// Displays support ticket details, conversation thread, and interactive reply input
class TicketDetailScreen extends StatefulWidget {
  final String ticketId;
  final SupportTicket? initialTicket;

  const TicketDetailScreen({
    super.key,
    required this.ticketId,
    this.initialTicket,
  });

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  SupportTicket? _ticket;
  bool _isLoading = true;
  bool _isSending = false;
  String? _errorMessage;

  final TextEditingController _replyController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _ticket = widget.initialTicket;
    _fetchTicketDetails();
  }

  @override
  void dispose() {
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _fetchTicketDetails() async {
    if (_ticket == null) {
      setState(() => _isLoading = true);
    }

    try {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final details = await ticketService.getTicketDetails(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = details;
          _isLoading = false;
          _errorMessage = null;
        });
        _scrollToBottom();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Could not load ticket details.';
          _isLoading = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendReply() async {
    final text = _replyController.text.trim();
    if (text.isEmpty || _ticket == null || _isSending) return;

    setState(() => _isSending = true);

    try {
      final ticketService = Provider.of<TicketService>(context, listen: false);
      final updatedTicket = await ticketService.replyToTicket(
        id: widget.ticketId,
        message: text,
      );

      _replyController.clear();
      if (mounted) {
        FocusScope.of(context).unfocus();
        setState(() {
          _ticket = updatedTicket;
          _isSending = false;
        });
        _scrollToBottom();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.darkBase,
            content: Text(
              'Your reply has been transmitted to the atelier.',
              style: TextStyle(color: AppColors.primaryGold),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.error,
            content: Text(
              'Failed to send reply. Please try again.',
              style: TextStyle(color: Colors.white),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _ticket;
    final isClosed = ticket != null &&
        (ticket.status.toLowerCase() == 'closed' || ticket.status.toLowerCase() == 'resolved');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: LuxuryAppBar(
        title: ticket != null ? ticket.ticketNumber : 'TICKET DETAIL',
        showBack: true,
        showCart: false,
        showWishlist: false,
      ),
      body: _isLoading && ticket == null
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
              ),
            )
          : _errorMessage != null && ticket == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 44, color: AppColors.error),
                        const SizedBox(height: 12),
                        Text(
                          _errorMessage!,
                          style: AppTypography.bodyMD(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchTicketDetails,
                          child: const Text('RETRY'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Ticket info & conversation stream
                    Expanded(
                      child: RefreshIndicator(
                        color: AppColors.primaryGold,
                        backgroundColor: AppColors.darkBase,
                        onRefresh: _fetchTicketDetails,
                        child: ListView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          children: [
                            // Header Card
                            _buildTicketHeaderCard(ticket!),
                            const SizedBox(height: 20),

                            // Original Inquiry Section
                            _buildOriginalMessageCard(ticket),
                            const SizedBox(height: 24),

                            // Replies Thread Header
                            Row(
                              children: [
                                const Icon(
                                  Icons.forum_outlined,
                                  size: 18,
                                  color: AppColors.primaryGold,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'CONVERSATION THREAD (${ticket.responses.length})',
                                  style: AppTypography.labelMD(color: AppColors.textSecondary).copyWith(
                                    letterSpacing: 1.2,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            if (ticket.responses.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.outlineLight),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.access_time_outlined,
                                      size: 28,
                                      color: AppColors.primaryGold,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Awaiting Concierge Reply',
                                      style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Our private atelier masters will respond to your inquiry shortly.',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.bodyXS(color: AppColors.textSecondary),
                                    ),
                                  ],
                                ),
                              )
                            else
                              ...ticket.responses.map((resp) => _buildResponseBubble(resp, ticket)),
                          ],
                        ),
                      ),
                    ),

                    // Reply Input Field at the bottom
                    if (!isClosed)
                      _buildReplyInputBar()
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          border: Border(top: BorderSide(color: AppColors.outlineLight)),
                        ),
                        child: Center(
                          child: Text(
                            'This ticket has been marked resolved.',
                            style: AppTypography.bodySM(color: AppColors.textMuted),
                          ),
                        ),
                      ),
                  ],
                ),
    );
  }

  Widget _buildTicketHeaderCard(SupportTicket ticket) {
    final isClosed = ticket.status.toLowerCase() == 'closed' ||
        ticket.status.toLowerCase() == 'resolved';

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
                ticket.ticketNumber,
                style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              AppBadgeChip(
                label: ticket.status.toUpperCase(),
                variant: isClosed ? BadgeChipVariant.statusSage : BadgeChipVariant.statusGold,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            ticket.subject,
            style: AppTypography.headlineMD(color: AppColors.textPrimary).copyWith(
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              AppBadgeChip(
                label: ticket.category.toUpperCase(),
                variant: BadgeChipVariant.darkTag,
              ),
              AppBadgeChip(
                label: 'PRIORITY: ${ticket.priority.toUpperCase()}',
                variant: ticket.priority.toUpperCase() == 'URGENT'
                    ? BadgeChipVariant.statusRuby
                    : BadgeChipVariant.darkTag,
              ),
              if (ticket.orderId != null && ticket.orderId!.isNotEmpty)
                AppBadgeChip(
                  label: 'ORDER: ${ticket.orderId}',
                  variant: BadgeChipVariant.goldPurity,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalMessageCard(SupportTicket ticket) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGold.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.primaryGold.withValues(alpha: 0.2),
                child: Text(
                  ticket.customerName.isNotEmpty
                      ? ticket.customerName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.customerName.isNotEmpty ? ticket.customerName : 'Patron Request',
                      style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Original Inquiry',
                      style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              if (ticket.createdAt != null)
                Text(
                  _formatDate(ticket.createdAt!),
                  style: AppTypography.labelSM(color: AppColors.textMuted).copyWith(
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            ticket.message,
            style: AppTypography.bodyMD(color: AppColors.textPrimary).copyWith(
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseBubble(TicketResponseItem resp, SupportTicket ticket) {
    final isStaff = resp.sender.toLowerCase() == 'staff' ||
        resp.sender.toLowerCase() == 'admin' ||
        resp.sender.toLowerCase() == 'concierge';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isStaff ? AppColors.darkBase : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isStaff
              ? AppColors.primaryGold.withValues(alpha: 0.4)
              : AppColors.outlineLight,
          width: isStaff ? 1.2 : 1,
        ),
        boxShadow: isStaff ? const [AppColors.goldGlow] : const [AppColors.softCardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isStaff) ...[
                const Icon(Icons.verified, size: 16, color: AppColors.primaryGold),
                const SizedBox(width: 6),
                Text(
                  resp.senderName?.isNotEmpty == true
                      ? resp.senderName!
                      : 'Hakori Atelier Concierge',
                  style: AppTypography.labelMD(color: AppColors.primaryGold).copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ] else ...[
                CircleAvatar(
                  radius: 12,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  child: Text(
                    ticket.customerName.isNotEmpty ? ticket.customerName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  resp.senderName?.isNotEmpty == true
                      ? resp.senderName!
                      : ticket.customerName,
                  style: AppTypography.labelMD(color: AppColors.textPrimary).copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const Spacer(),
              if (resp.createdAt.isNotEmpty)
                Text(
                  _formatDate(resp.createdAt),
                  style: AppTypography.labelSM(color: AppColors.textMuted).copyWith(
                    fontSize: 10,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            resp.message,
            style: AppTypography.bodySM(
              color: isStaff ? AppColors.textOnDark : AppColors.textPrimary,
            ).copyWith(height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        10,
        16,
        MediaQuery.of(context).viewInsets.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outlineLight)),
        boxShadow: const [AppColors.softCardShadow],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
                child: TextField(
                  controller: _replyController,
                  maxLines: 4,
                  minLines: 1,
                  style: AppTypography.bodySM(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Type your response to concierge...',
                    hintStyle: AppTypography.bodySM(color: AppColors.textMuted),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              height: 42,
              width: 42,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: AppColors.goldGradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [AppColors.goldGlow],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isSending ? null : _sendReply,
                  customBorder: const CircleBorder(),
                  child: Center(
                    child: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnGold),
                            ),
                          )
                        : const Icon(
                            Icons.send,
                            size: 18,
                            color: AppColors.textOnGold,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String isoString) {
    try {
      final dt = DateTime.parse(isoString);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return isoString;
    }
  }
}
