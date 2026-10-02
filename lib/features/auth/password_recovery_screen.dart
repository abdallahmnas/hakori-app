import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen 5: password_recovery_security_reset
/// Multi-step password recovery & master credential reset
class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  int _currentStep = 1;
  final _emailController = TextEditingController(text: 'vip.collector@placevendome.com');
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
    } else {
      context.push('/password-success');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () {
            if (_currentStep > 1) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'SECURITY RECOVERY',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator (Step 1 of 3)
              Row(
                children: List.generate(3, (index) {
                  final stepNum = index + 1;
                  final isActive = stepNum <= _currentStep;
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primaryGold : AppColors.outlineLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // Step Header
              Text(
                _currentStep == 1
                    ? 'Identify Vault Account'
                    : (_currentStep == 2 ? 'Verify Security Token' : 'Establish New Master Password'),
                style: AppTypography.headlineXL(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                _currentStep == 1
                    ? 'Enter the VIP email or phone associated with your Place Vendôme vault certificate.'
                    : (_currentStep == 2
                        ? 'Enter the 6-digit emergency security code sent to your verified device.'
                        : 'Choose a high-entropy password to re-encrypt your digital 3D scans and orders.'),
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Step Content
              if (_currentStep == 1) ...[
                AppTextField(
                  label: 'Registered Collector Email / Phone',
                  hintText: 'collector@domain.com',
                  controller: _emailController,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryGold),
                ),
              ] else if (_currentStep == 2) ...[
                AppTextField(
                  label: '6-Digit Security Token',
                  hintText: '894210',
                  controller: _tokenController,
                  keyboardType: TextInputType.number,
                  prefixIcon: const Icon(Icons.security, color: AppColors.primaryGold),
                ),
              ] else ...[
                AppTextField(
                  label: 'New Master Password',
                  hintText: '••••••••••••',
                  controller: _newPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold),
                ),
                const SizedBox(height: 16),
                AppTextField(
                  label: 'Confirm Master Password',
                  hintText: '••••••••••••',
                  controller: _confirmPasswordController,
                  isPassword: true,
                  prefixIcon: const Icon(Icons.lock_reset, color: AppColors.primaryGold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle, size: 14, color: AppColors.emeraldGreen),
                    const SizedBox(width: 6),
                    Text(
                      'Meets Place Vendôme 256-Bit Vault Standard',
                      style: AppTypography.bodyXS(color: AppColors.emeraldGreen),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 36),
              // Action Button
              AppButton.primary(
                text: _currentStep == 3 ? 'RESET MASTER CREDENTIAL' : 'CONTINUE PROTOCOL',
                onPressed: _nextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
