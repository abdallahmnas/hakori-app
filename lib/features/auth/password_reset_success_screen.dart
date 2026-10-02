import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';

/// Screen 6: password_reset_success_vault_re_entry
/// Success confirmation screen with re-entry trigger
class PasswordResetSuccessScreen extends StatelessWidget {
  const PasswordResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Gold Shield Icon
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkCard,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  size: 52,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Vault Access Restored',
                textAlign: TextAlign.center,
                style: AppTypography.headlineXL(color: AppColors.textOnDark),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Your master encryption key has been successfully updated. All saved 3D intraoral scans and active commissions are re-secured.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.textMuted).copyWith(height: 1.5),
                ),
              ),
              const SizedBox(height: 32),
              // Security stamp card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_outline, color: AppColors.primaryGold, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ENCRYPTION STATUS',
                            style: AppTypography.labelSM(color: AppColors.goldAccent),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AES-256 GCM • Active Biometric Token',
                            style: AppTypography.bodyXS(color: AppColors.textOnDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              AppButton.primary(
                text: 'ENTER VAULT NOW',
                onPressed: () => context.go('/home'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
