import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen 5: password_recovery_security_reset
/// Multi-step password recovery & master credential reset matching API_DOCUMENTATION.md
class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  int _currentStep = 1;
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleNextStep() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (_currentStep == 1) {
      final email = _emailController.text.trim();
      if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid VIP email address.'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);
      final ok = await auth.forgotPassword(email);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        setState(() => _currentStep = 2);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Failed to request recovery code.'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (_currentStep == 2) {
      final token = _tokenController.text.trim();
      if (token.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the security recovery code.'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);
      final ok = await auth.verifyResetOtp(token);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        setState(() => _currentStep = 3);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Invalid security token.'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    if (_currentStep == 3) {
      final newPass = _newPasswordController.text;
      final confirmPass = _confirmPasswordController.text;

      if (newPass.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('New password must be at least 6 characters.'), backgroundColor: AppColors.error),
        );
        return;
      }

      if (newPass != confirmPass) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.'), backgroundColor: AppColors.error),
        );
        return;
      }

      setState(() => _isLoading = true);
      final ok = await auth.resetPassword(newPass);
      if (!mounted) return;
      setState(() => _isLoading = false);

      if (ok) {
        context.push('/password-success');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.errorMessage ?? 'Failed to update master password.'), backgroundColor: AppColors.error),
        );
      }
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
                    ? 'Enter the VIP email associated with your Place Vendôme vault certificate.'
                    : (_currentStep == 2
                        ? 'Enter the 6-digit emergency security code sent to your verified device.'
                        : 'Choose a high-entropy password to re-encrypt your digital 3D scans and orders.'),
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              // Step Content
              if (_currentStep == 1) ...[
                AppTextField(
                  label: 'Registered Collector Email',
                  hintText: 'collector@placevendome.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.mail_outline, color: AppColors.primaryGold),
                ),
              ] else if (_currentStep == 2) ...[
                AppTextField(
                  label: 'Security Reset Token (OTP)',
                  hintText: 'e.g. 894102',
                  controller: _tokenController,
                  prefixIcon: const Icon(Icons.key, color: AppColors.primaryGold),
                ),
              ] else if (_currentStep == 3) ...[
                AppTextField(
                  label: 'New Master Vault Password',
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
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.primaryGold),
                ),
              ],
              const SizedBox(height: 32),
              // Next / Complete Button
              AppButton.primary(
                text: _isLoading
                    ? 'PROCESSING PROTOCOL...'
                    : (_currentStep == 3 ? 'UPDATE MASTER CREDENTIALS' : 'CONTINUE PROTOCOL'),
                onPressed: _isLoading ? null : _handleNextStep,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
