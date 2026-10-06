import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/models/support_ticket.dart';
import '../../core/models/user.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/ticket_service.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/badge_chip.dart';

/// Patron Profile Screen
/// Connected directly to AuthProvider with Login required enforcement
/// and backend API-driven Support Tickets (replacing reference & digital assets).
class VipProfileScreen extends StatefulWidget {
  const VipProfileScreen({super.key});

  @override
  State<VipProfileScreen> createState() => _VipProfileScreenState();
}

class _VipProfileScreenState extends State<VipProfileScreen> {
  // Notification Preferences State
  bool _orderUpdates = true;
  bool _dropAlerts = true;
  bool _priceAlerts = false;
  bool _conciergeReminders = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      if (auth.isAuthenticated) {
        auth.refreshProfile();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    // If not logged in, enforce login to continue
    if (!auth.isAuthenticated || user == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const LuxuryAppBar(title: 'PROFILE', showBack: false),
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.outlineLight),
                boxShadow: const [AppColors.softCardShadow],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkBase,
                      border: Border.all(
                        color: AppColors.primaryGold,
                        width: 2,
                      ),
                      boxShadow: const [AppColors.goldGlow],
                    ),
                    child: const Icon(
                      Icons.lock_person_outlined,
                      size: 36,
                      color: AppColors.primaryGold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Login to Continue',
                    style: AppTypography.headlineMD(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please log in or create an account to view your private profile, manage delivery addresses, and submit customer support tickets.',
                    style: AppTypography.bodySM(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  AppButton.primary(
                    text: 'LOG IN',
                    onPressed: () => context.push('/login'),
                  ),
                  const SizedBox(height: 12),
                  AppButton.outline(
                    text: 'CREATE ACCOUNT',
                    onPressed: () => context.push('/signup'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final displayName = user.fullName.isNotEmpty
        ? user.fullName
        : ([user.firstName, user.lastName].where((s) => s != null && s.isNotEmpty).join(' ').isNotEmpty
            ? [user.firstName, user.lastName].where((s) => s != null && s.isNotEmpty).join(' ')
            : 'Valued Patron');
    final displayEmail = user.email;
    final displayPhone = user.phone?.isNotEmpty == true
        ? user.phone!
        : 'No phone registered';
    final displayAddress = user.displayAddress.isNotEmpty
        ? user.displayAddress
        : 'No delivery address saved';
    final displayTier =
        (user.tier?.isNotEmpty == true ? user.tier! : 'VIP MEMBER')
            .toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(title: 'PROFILE', showBack: false),
      body: RefreshIndicator(
        color: AppColors.primaryGold,
        backgroundColor: AppColors.darkBase,
        onRefresh: () async {
          await auth.refreshProfile();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // User Profile Header Card from AuthProvider data
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.outlineLight),
                  boxShadow: const [AppColors.softCardShadow],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 68,
                              height: 68,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.darkBase,
                                border: Border.all(
                                  color: AppColors.primaryGold,
                                  width: 2,
                                ),
                                boxShadow: const [AppColors.goldGlow],
                              ),
                              child: ClipOval(
                                child: (user.avatarUrl != null && user.avatarUrl!.isNotEmpty)
                                    ? Image.network(
                                        user.avatarUrl!,
                                        width: 68,
                                        height: 68,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) => Center(
                                          child: Text(
                                            _getInitials(displayName),
                                            style: AppTypography.headlineMD(
                                              color: AppColors.primaryGold,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          _getInitials(displayName),
                                          style: AppTypography.headlineMD(
                                            color: AppColors.primaryGold,
                                          ),
                                        ),
                                      ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: () => _showEditProfileSheet(user, auth),
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGold,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.edit,
                                    size: 13,
                                    color: AppColors.textOnGold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppBadgeChip(
                                label: displayTier,
                                variant: BadgeChipVariant.goldPurity,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                displayName,
                                style: AppTypography.headlineMD(
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                displayEmail,
                                style: AppTypography.bodyXS(
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.phone_outlined,
                          size: 15,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayPhone,
                            style: AppTypography.bodyXS(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: AppColors.primaryGold,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            displayAddress,
                            style: AppTypography.bodyXS(
                              color: AppColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Account & Security Section
              _buildMenuSection('ACCOUNT & SECURITY', [
                _buildMenuItem(
                  icon: Icons.person_outline,
                  title: 'Profile Information',
                  subtitle:
                      'Update your name, contact phone, and delivery address',
                  onTap: () => _showEditProfileSheet(user, auth),
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  icon: Icons.lock_outline,
                  title: 'Change Password',
                  subtitle: 'Update account password and security credentials',
                  onTap: _showChangePasswordSheet,
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  icon: Icons.notifications_none_outlined,
                  title: 'Notifications',
                  subtitle: 'Order status, transit updates, and drop alerts',
                  onTap: _showNotificationsSheet,
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  icon: Icons.fingerprint,
                  title: 'Biometric Access',
                  subtitle: 'Coming Soon',
                  trailing: const AppBadgeChip(
                    label: 'COMING SOON',
                    variant: BadgeChipVariant.darkTag,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Fingerprint biometric login is coming soon.',
                        ),
                        backgroundColor: AppColors.darkBase,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ]),
              const SizedBox(height: 20),

              // Customer Support & Tickets Section (API Driven, replaces reference/digital assets)
              _buildMenuSection('CUSTOMER SUPPORT & TICKETS', [
                _buildMenuItem(
                  icon: Icons.confirmation_number_outlined,
                  title: 'Create Support Ticket',
                  subtitle:
                      'Inquire on orders, jewelry repairs, or custom commissions',
                  onTap: () => _showCreateTicketSheet(user),
                ),
                const Divider(height: 1, indent: 56),
                _buildMenuItem(
                  icon: Icons.support_agent_outlined,
                  title: 'Lookup Ticket & Reply',
                  subtitle:
                      'View ticket status, staff replies, and response thread',
                  onTap: _showTicketLookupSheet,
                ),
              ]),
              const SizedBox(height: 24),

              // Sign Out Button
              InkWell(
                onTap: _showSignOutDialog,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0x33EF4444)),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.logout,
                          size: 18,
                          color: AppColors.rubyRed,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'LOG OUT',
                          style: AppTypography.labelMD(
                            color: AppColors.rubyRed,
                          ).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'VP';
  }

  Widget _buildMenuSection(String sectionTitle, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            sectionTitle,
            style: AppTypography.labelSM(color: AppColors.textSecondary),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outlineLight),
            boxShadow: const [AppColors.softCardShadow],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: AppColors.primaryGold),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.headlineSM(
                      color: AppColors.textPrimary,
                    ).copyWith(fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTypography.bodyXS(color: AppColors.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.textMuted,
                ),
          ],
        ),
      ),
    );
  }

  // Edit Profile Bottom Sheet (Connected directly to AuthProvider.updateProfile)
  void _showEditProfileSheet(User user, AuthProvider auth) {
    final names = user.fullName.split(' ');
    final initialFirst = user.firstName ?? (names.isNotEmpty ? names.first : '');
    final initialLast = user.lastName ?? (names.length > 1 ? names.sublist(1).join(' ') : '');

    final firstCtrl = TextEditingController(text: initialFirst);
    final lastCtrl = TextEditingController(text: initialLast);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final addressCtrl = TextEditingController(text: user.address ?? user.location ?? '');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Profile Information',
                  style: AppTypography.headlineMD(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Update your personal details & shipping contact',
                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'FIRST NAME',
                        controller: firstCtrl,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppTextField(
                        label: 'LAST NAME',
                        controller: lastCtrl,
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          size: 20,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'EMAIL ADDRESS',
                  controller: TextEditingController(text: user.email),
                  enabled: false,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'PHONE NUMBER',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'PRIMARY DELIVERY ADDRESS',
                  controller: addressCtrl,
                  prefixIcon: const Icon(
                    Icons.location_on_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: isSaving ? 'SAVING...' : 'SAVE CHANGES',
                  onPressed: isSaving
                      ? null
                      : () async {
                          setSheetState(() => isSaving = true);
                          final ok = await auth.updateProfile(
                            firstName: firstCtrl.text.trim(),
                            lastName: lastCtrl.text.trim(),
                            phone: phoneCtrl.text.trim(),
                            address: addressCtrl.text.trim(),
                          );
                          if (sheetCtx.mounted) {
                            Navigator.pop(sheetCtx);
                          }

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  ok
                                      ? 'Profile updated successfully.'
                                      : (auth.errorMessage ??
                                            'Failed to update profile.'),
                                ),
                                backgroundColor: ok
                                    ? AppColors.darkBase
                                    : AppColors.error,
                              ),
                            );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Create Support Ticket Bottom Sheet (API-driven POST /tickets)
  void _showCreateTicketSheet(User user) {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    final nameCtrl = TextEditingController(text: user.fullName);
    final emailCtrl = TextEditingController(text: user.email);
    final phoneCtrl = TextEditingController(text: user.phone ?? '');
    final subjectCtrl = TextEditingController();
    final orderIdCtrl = TextEditingController();
    final messageCtrl = TextEditingController();
    String selectedCategory = 'Order Inquiry';
    String selectedPriority = 'NORMAL';
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Create Support Ticket',
                  style: AppTypography.headlineMD(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Direct communication with Hakori concierge & support team',
                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: 'CUSTOMER NAME',
                  hintText: 'Lord Sterling',
                  controller: nameCtrl,
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'CUSTOMER EMAIL',
                  hintText: 'sterling@mayfair.co.uk',
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(
                    Icons.email_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'CUSTOMER PHONE',
                  hintText: '+44 20 7946 0992',
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'SUBJECT',
                  hintText:
                      'e.g. Impression kit delivery tracking',
                  controller: subjectCtrl,
                  prefixIcon: const Icon(
                    Icons.title,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'CATEGORY',
                  style: AppTypography.labelSM(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineLight),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedCategory,
                      items: const [
                        DropdownMenuItem(
                          value: 'Order Inquiry',
                          child: Text('Order Inquiry'),
                        ),
                        DropdownMenuItem(
                          value: 'Bespoke Commission',
                          child: Text('Bespoke Commission'),
                        ),
                        DropdownMenuItem(
                          value: 'Fitting & Impression',
                          child: Text('Fitting & Impression'),
                        ),
                        DropdownMenuItem(
                          value: 'Payment & Bullion',
                          child: Text('Payment & Bullion'),
                        ),
                        DropdownMenuItem(
                          value: 'Vault Care',
                          child: Text('Vault Care'),
                        ),
                        DropdownMenuItem(
                          value: 'General',
                          child: Text('General'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setSheetState(() => selectedCategory = val);
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'PRIORITY',
                  style: AppTypography.labelSM(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['LOW', 'NORMAL', 'HIGH', 'URGENT'].map((p) {
                    final isSel = selectedPriority == p;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                          p,
                          style: AppTypography.labelSM(
                            color: isSel
                                ? AppColors.darkBase
                                : AppColors.textPrimary,
                          ),
                        ),
                        selected: isSel,
                        selectedColor: AppColors.primaryGold,
                        backgroundColor: AppColors.surface,
                        onSelected: (_) =>
                            setSheetState(() => selectedPriority = p),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'ORDER ID (OPTIONAL)',
                  hintText: 'e.g. AUR-98214',
                  controller: orderIdCtrl,
                  prefixIcon: const Icon(
                    Icons.receipt_outlined,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'MESSAGE / DETAILS',
                  hintText: 'When will the 3D impression kit arrive in Mayfair?',
                  controller: messageCtrl,
                  maxLines: 4,
                  prefixIcon: const Icon(
                    Icons.chat_bubble_outline,
                    size: 20,
                    color: AppColors.primaryGold,
                  ),
                ),
                const SizedBox(height: 24),
                AppButton.primary(
                  text: isSubmitting ? 'SUBMITTING...' : 'SUBMIT TICKET',
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final custName = nameCtrl.text.trim();
                          final custEmail = emailCtrl.text.trim();
                          final custPhone = phoneCtrl.text.trim();
                          final subject = subjectCtrl.text.trim();
                          final message = messageCtrl.text.trim();
                          if (custName.isEmpty || custEmail.isEmpty || subject.isEmpty || message.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please provide name, email, subject, and message.',
                                ),
                                backgroundColor: AppColors.error,
                              ),
                            );
                            return;
                          }

                          setSheetState(() => isSubmitting = true);
                          try {
                            final ticket = await ticketService.createTicket(
                              customerName: custName,
                              customerEmail: custEmail,
                              customerPhone: custPhone.isNotEmpty ? custPhone : null,
                              subject: subject,
                              category: selectedCategory,
                              priority: selectedPriority,
                              orderId: orderIdCtrl.text.trim().isNotEmpty
                                  ? orderIdCtrl.text.trim()
                                  : null,
                              message: message,
                            );

                            if (sheetCtx.mounted) {
                              Navigator.pop(sheetCtx);
                            }

                            if (mounted) {
                              showDialog(
                                context: context,
                                builder: (dialogCtx) => AlertDialog(
                                  backgroundColor: AppColors.surface,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  title: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: AppColors.primaryGold,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ticket Created',
                                        style: AppTypography.headlineMD(
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Your support ticket has been submitted to the atelier concierge.',
                                        style: AppTypography.bodyMD(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppColors.darkBase,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Ticket #:',
                                              style: AppTypography.labelSM(
                                                color: AppColors.textOnDark,
                                              ),
                                            ),
                                            Text(
                                              ticket.ticketNumber,
                                              style:
                                                  AppTypography.labelMD(
                                                    color:
                                                        AppColors.primaryGold,
                                                  ).copyWith(
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    AppButton.primary(
                                      text: 'DONE',
                                      onPressed: () => Navigator.pop(dialogCtx),
                                    ),
                                  ],
                                ),
                              );
                            }
                          } catch (e) {
                            setSheetState(() => isSubmitting = false);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to submit ticket: ${e.toString()}',
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Lookup & Track Support Ticket Bottom Sheet (API-driven GET /tickets/:id & POST /tickets/:id/reply)
  void _showTicketLookupSheet() {
    final ticketService = Provider.of<TicketService>(context, listen: false);
    final idCtrl = TextEditingController();
    final replyCtrl = TextEditingController();
    bool isLoading = false;
    bool isReplying = false;
    SupportTicket? ticket;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.outlineLight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Support Ticket Lookup',
                  style: AppTypography.headlineMD(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Enter ticket ID to check real-time status and responses',
                  style: AppTypography.bodyXS(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'TICKET ID',
                        hintText: 'Enter ticket ID',
                        controller: idCtrl,
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 22),
                      child: AppButton.primary(
                        text: isLoading ? '...' : 'FIND',
                        width: 76,
                        height: 48,
                        onPressed: isLoading
                            ? null
                            : () async {
                                final tid = idCtrl.text.trim();
                                if (tid.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter a ticket ID.',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                  return;
                                }
                                setSheetState(() => isLoading = true);
                                try {
                                  final result = await ticketService
                                      .getTicketDetails(tid);
                                  setSheetState(() {
                                    ticket = result;
                                    isLoading = false;
                                  });
                                } catch (e) {
                                  setSheetState(() => isLoading = false);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Ticket not found: ${e.toString()}',
                                        ),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                    ),
                  ],
                ),
                if (ticket != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.outlineLight),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ticket!.ticketNumber,
                              style: AppTypography.headlineSM(
                                color: AppColors.primaryGold,
                              ),
                            ),
                            AppBadgeChip(
                              label: ticket!.status.toUpperCase(),
                              variant:
                                  ticket!.status.toUpperCase() == 'RESOLVED'
                                  ? BadgeChipVariant.goldPurity
                                  : BadgeChipVariant.darkTag,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          ticket!.subject,
                          style: AppTypography.headlineMD(
                            color: AppColors.textPrimary,
                          ).copyWith(fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Category: ${ticket!.category} • Priority: ${ticket!.priority}',
                          style: AppTypography.bodyXS(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1),
                        const SizedBox(height: 12),
                        Text(
                          'Original Inquiry:',
                          style: AppTypography.labelSM(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          ticket!.message,
                          style: AppTypography.bodySM(
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (ticket!.responses.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Text(
                            'Responses:',
                            style: AppTypography.labelSM(
                              color: AppColors.primaryGold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...ticket!.responses.map(
                            (resp) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: resp.sender == 'customer'
                                    ? AppColors.surface
                                    : AppColors.darkBase,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: resp.sender == 'customer'
                                      ? AppColors.outlineLight
                                      : AppColors.primaryGold.withAlpha(120),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        resp.senderName ??
                                            (resp.sender == 'customer'
                                                ? 'You'
                                                : 'Concierge Staff'),
                                        style: AppTypography.labelSM(
                                          color: resp.sender == 'customer'
                                              ? AppColors.textPrimary
                                              : AppColors.primaryGold,
                                        ),
                                      ),
                                      Text(
                                        resp.createdAt.length > 10
                                            ? resp.createdAt.substring(0, 10)
                                            : resp.createdAt,
                                        style: AppTypography.bodyXS(
                                          color: AppColors.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    resp.message,
                                    style: AppTypography.bodySM(
                                      color: resp.sender == 'customer'
                                          ? AppColors.textPrimary
                                          : AppColors.textOnDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'REPLY TO TICKET',
                          hintText: 'Type your reply message...',
                          controller: replyCtrl,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 10),
                        AppButton.primary(
                          text: isReplying ? 'SENDING...' : 'SEND REPLY',
                          onPressed: isReplying
                              ? null
                              : () async {
                                  final msg = replyCtrl.text.trim();
                                  if (msg.isEmpty) return;
                                  setSheetState(() => isReplying = true);
                                  try {
                                    final updated = await ticketService
                                        .replyToTicket(
                                          id: ticket!.id,
                                          message: msg,
                                        );
                                    replyCtrl.clear();
                                    setSheetState(() {
                                      ticket = updated;
                                      isReplying = false;
                                    });
                                  } catch (e) {
                                    setSheetState(() => isReplying = false);
                                    if (mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Failed to send reply: ${e.toString()}',
                                          ),
                                          backgroundColor: AppColors.error,
                                        ),
                                      );
                                    }
                                  }
                                },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Change Password Bottom Sheet
  void _showChangePasswordSheet() {
    final currentPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Change Password',
                style: AppTypography.headlineMD(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Enter your current password and choose a new secure password',
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              AppTextField(
                label: 'CURRENT PASSWORD',
                controller: currentPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'NEW PASSWORD',
                controller: newPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(
                  Icons.key_outlined,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'CONFIRM NEW PASSWORD',
                controller: confirmPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'UPDATE PASSWORD',
                onPressed: () {
                  if (newPassCtrl.text.isEmpty ||
                      newPassCtrl.text != confirmPassCtrl.text) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Passwords do not match or are empty.'),
                        backgroundColor: AppColors.rubyRed,
                      ),
                    );
                    return;
                  }
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password updated successfully.'),
                      backgroundColor: AppColors.darkBase,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Notifications Bottom Sheet
  void _showNotificationsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Notification Settings',
                style: AppTypography.headlineMD(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose the notifications you want to receive',
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              _buildNotificationSwitch(
                title: 'Order & Transit Tracking',
                subtitle:
                    'Get real-time alerts on casting, stone setting & shipping',
                value: _orderUpdates,
                onChanged: (val) {
                  setModalState(() => _orderUpdates = val);
                  setState(() => _orderUpdates = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'Atelier Drops & New Pieces',
                subtitle:
                    'Early access notifications for limited seasonal collections',
                value: _dropAlerts,
                onChanged: (val) {
                  setModalState(() => _dropAlerts = val);
                  setState(() => _dropAlerts = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'Gold & Gem Spot Price Alerts',
                subtitle: 'Alerts when fine metals lock in favorable rates',
                value: _priceAlerts,
                onChanged: (val) {
                  setModalState(() => _priceAlerts = val);
                  setState(() => _priceAlerts = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'VIP Concierge Reminders',
                subtitle: 'Upcoming 1-on-1 consultations and jewelry previews',
                value: _conciergeReminders,
                onChanged: (val) {
                  setModalState(() => _conciergeReminders = val);
                  setState(() => _conciergeReminders = val);
                },
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'DONE',
                onPressed: () => Navigator.pop(ctx),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationSwitch({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.headlineSM(
                  color: AppColors.textPrimary,
                ).copyWith(fontSize: 14),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.bodyXS(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          activeTrackColor: AppColors.primaryGold,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // Sign Out Confirmation Dialog
  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text(
          'Log Out',
          style: AppTypography.headlineMD(color: AppColors.textPrimary),
        ),
        content: Text(
          'Are you sure you want to log out of your Hakori Al Madinah account?',
          style: AppTypography.bodyMD(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'CANCEL',
              style: AppTypography.labelMD(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rubyRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              final auth = Provider.of<AuthProvider>(context, listen: false);
              await auth.logout();
              if (mounted) {
                context.go('/welcome');
              }
            },
            child: Text(
              'LOG OUT',
              style: AppTypography.labelMD(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
