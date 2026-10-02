import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/currency_provider.dart';
import '../../core/widgets/app_bar_luxury.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/badge_chip.dart';

/// Simplified & Comprehensive Profile Screen
/// Includes Profile Info, Account Settings, Notifications, Change Password, and Concierge Services
class VipProfileScreen extends StatefulWidget {
  const VipProfileScreen({super.key});

  @override
  State<VipProfileScreen> createState() => _VipProfileScreenState();
}

class _VipProfileScreenState extends State<VipProfileScreen> {
  // Mock Profile State
  String _userName = 'Alexander Wright';
  String _userEmail = 'alexander.wright@hakorialmadinah.com';
  String _userPhone = '+1 (555) 382-9012';
  String _userAddress = '742 Place Vendôme, Suite 402, Paris, France';

  // Notification Preferences State
  bool _orderUpdates = true;
  bool _dropAlerts = true;
  bool _priceAlerts = false;
  bool _conciergeReminders = true;
  bool _biometricEnabled = true;

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const LuxuryAppBar(
        title: 'PROFILE',
        showBack: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // User Profile Header Card
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
                              border: Border.all(color: AppColors.primaryGold, width: 2),
                              boxShadow: const [AppColors.goldGlow],
                            ),
                            child: Center(
                              child: Text(
                                _getInitials(_userName),
                                style: AppTypography.headlineMD(color: AppColors.primaryGold),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: _showEditProfileSheet,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: AppColors.primaryGold,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.edit, size: 13, color: AppColors.textOnGold),
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
                            const AppBadgeChip(
                              label: 'VIP MEMBER',
                              variant: BadgeChipVariant.goldPurity,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _userName,
                              style: AppTypography.headlineMD(color: AppColors.textPrimary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _userEmail,
                              style: AppTypography.bodyXS(color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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

            // Account & Security Section
            _buildMenuSection('ACCOUNT & SECURITY', [
              _buildMenuItem(
                icon: Icons.person_outline,
                title: 'Profile Information',
                subtitle: 'Name, email, phone number, and address',
                onTap: _showEditProfileSheet,
              ),
              const Divider(height: 1, indent: 56),
              _buildMenuItem(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Update your login password and security code',
                onTap: _showChangePasswordSheet,
              ),
              const Divider(height: 1, indent: 56),
              _buildMenuItem(
                icon: Icons.notifications_none_outlined,
                title: 'Notifications',
                subtitle: 'Order status, drop alerts, and VIP reminders',
                onTap: _showNotificationsSheet,
              ),
              const Divider(height: 1, indent: 56),
              _buildMenuItem(
                icon: Icons.fingerprint,
                title: 'Biometric Access',
                subtitle: _biometricEnabled ? 'Biometrics Active' : 'Disabled',
                trailing: Switch.adaptive(
                  value: _biometricEnabled,
                  activeColor: AppColors.primaryGold,
                  onChanged: (val) {
                    setState(() => _biometricEnabled = val);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(val ? 'Biometric access enabled.' : 'Biometric access disabled.'),
                        backgroundColor: AppColors.darkBase,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
                onTap: () {
                  setState(() => _biometricEnabled = !_biometricEnabled);
                },
              ),
            ]),
            const SizedBox(height: 20),

            // Preferences & Vault Assets Section
            _buildMenuSection('PREFERENCES & DIGITAL ASSETS', [
              _buildMenuItem(
                icon: Icons.currency_exchange,
                title: 'Currency & FX Ledger',
                subtitle: 'Active: ${currencyProvider.selectedCurrency.code} (${currencyProvider.selectedCurrency.name})',
                onTap: () => context.push('/fx-ledger'),
              ),
              const Divider(height: 1, indent: 56),
              _buildMenuItem(
                icon: Icons.view_in_ar,
                title: '3D Intraoral Dental Vault',
                subtitle: '3 verified digital impression meshes',
                onTap: () => context.push('/dental-scans'),
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
                      const Icon(Icons.logout, size: 18, color: AppColors.rubyRed),
                      const SizedBox(width: 8),
                      Text(
                        'LOG OUT',
                        style: AppTypography.labelMD(color: AppColors.rubyRed).copyWith(fontWeight: FontWeight.bold),
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
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'AW';
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
          child: Column(
            children: items,
          ),
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
                    style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(fontSize: 14),
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
            trailing ?? const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // Edit Profile Bottom Sheet
  void _showEditProfileSheet() {
    final nameCtrl = TextEditingController(text: _userName);
    final emailCtrl = TextEditingController(text: _userEmail);
    final phoneCtrl = TextEditingController(text: _userPhone);
    final addressCtrl = TextEditingController(text: _userAddress);

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
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Profile Information', style: AppTypography.headlineMD(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Update your personal details & shipping contact', style: AppTypography.bodyXS(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              AppTextField(
                label: 'FULL NAME',
                controller: nameCtrl,
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'EMAIL ADDRESS',
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.email_outlined, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'PHONE NUMBER',
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'PRIMARY DELIVERY ADDRESS',
                controller: addressCtrl,
                prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'SAVE CHANGES',
                onPressed: () {
                  setState(() {
                    _userName = nameCtrl.text.trim().isEmpty ? _userName : nameCtrl.text.trim();
                    _userEmail = emailCtrl.text.trim().isEmpty ? _userEmail : emailCtrl.text.trim();
                    _userPhone = phoneCtrl.text.trim().isEmpty ? _userPhone : phoneCtrl.text.trim();
                    _userAddress = addressCtrl.text.trim().isEmpty ? _userAddress : addressCtrl.text.trim();
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile information updated successfully.'),
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
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Change Password', style: AppTypography.headlineMD(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Enter your current password and choose a new secure password', style: AppTypography.bodyXS(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              AppTextField(
                label: 'CURRENT PASSWORD',
                controller: currentPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'NEW PASSWORD',
                controller: newPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(Icons.key_outlined, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'CONFIRM NEW PASSWORD',
                controller: confirmPassCtrl,
                isPassword: true,
                prefixIcon: const Icon(Icons.check_circle_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 24),
              AppButton.primary(
                text: 'UPDATE PASSWORD',
                onPressed: () {
                  if (newPassCtrl.text.isEmpty || newPassCtrl.text != confirmPassCtrl.text) {
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
                    color: AppColors.outline,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Notification Settings', style: AppTypography.headlineMD(color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text('Choose the notifications you want to receive', style: AppTypography.bodyXS(color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              _buildNotificationSwitch(
                title: 'Order & Transit Tracking',
                subtitle: 'Get real-time alerts on casting, stone setting & shipping',
                value: _orderUpdates,
                onChanged: (val) {
                  setModalState(() => _orderUpdates = val);
                  setState(() => _orderUpdates = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'Atelier Drops & New Pieces',
                subtitle: 'Early access notifications for limited seasonal collections',
                value: _dropAlerts,
                onChanged: (val) {
                  setModalState(() => _dropAlerts = val);
                  setState(() => _dropAlerts = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'Gold & FX Spot Volatility Alerts',
                subtitle: 'Alerts when 18K/24K spot prices lock in favorable rates',
                value: _priceAlerts,
                onChanged: (val) {
                  setModalState(() => _priceAlerts = val);
                  setState(() => _priceAlerts = val);
                },
              ),
              const Divider(height: 16),
              _buildNotificationSwitch(
                title: 'VIP Concierge Reminders',
                subtitle: 'Upcoming 1-on-1 consultations and dental scan reviews',
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
              Text(title, style: AppTypography.headlineSM(color: AppColors.textPrimary).copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTypography.bodyXS(color: AppColors.textSecondary)),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Switch.adaptive(
          value: value,
          activeColor: AppColors.primaryGold,
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
        title: Text('Log Out', style: AppTypography.headlineMD(color: AppColors.textPrimary)),
        content: Text(
          'Are you sure you want to log out of your Hakori Al Madinah account?',
          style: AppTypography.bodyMD(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('CANCEL', style: AppTypography.labelMD(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.rubyRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.go('/welcome');
            },
            child: Text('LOG OUT', style: AppTypography.labelMD(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
