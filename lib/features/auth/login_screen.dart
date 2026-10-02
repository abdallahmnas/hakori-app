import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen 3: log_in_biometric_vault_access
/// Dark luxury biometric login screen with Place Vendôme credentials
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _simulateBiometricAuth() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkCard,
                  border: Border.all(color: AppColors.primaryGold, width: 2),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(
                  Icons.fingerprint,
                  size: 54,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Biometric Vault Scanner',
                style: AppTypography.headlineMD(color: AppColors.textOnDark),
              ),
              const SizedBox(height: 8),
              Text(
                'Touch sensor or look directly at the front camera to unlock your encrypted 3D vault.',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              AppButton.primary(
                text: 'AUTHENTICATE WITH BIOMETRICS',
                onPressed: () {
                  Navigator.pop(context);
                  context.go('/home');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      appBar: AppBar(
        backgroundColor: AppColors.darkBase,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: AppColors.primaryGold,
          ),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'VAULT ACCESS',
          style: AppTypography.labelLG(
            color: AppColors.textOnDark,
          ).copyWith(letterSpacing: 2.5),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // Vault Shield Icon
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.darkCard,
                    border: Border.all(
                      color: AppColors.primaryGold,
                      width: 1.5,
                    ),
                    boxShadow: const [AppColors.goldGlow],
                  ),
                  child: const Icon(
                    Icons.lock_person_outlined,
                    size: 34,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Enter your credentials or authenticate with stored biometrics.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 36),
              // Email / ID Field
              AppTextField(
                label: 'Collector Email / Vault ID',
                hintText: 'client@domain.com',
                controller: _emailController,
                isDark: true,
                prefixIcon: const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 18),
              // Password Field
              AppTextField(
                label: 'Master Access Password',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                isDark: true,
                prefixIcon: const Icon(
                  Icons.key_outlined,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 14),
              // Remember Me & Forgot Password
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Checkbox(
                          value: _rememberMe,
                          activeColor: AppColors.primaryGold,
                          checkColor: AppColors.textOnGold,
                          onChanged: (val) =>
                              setState(() => _rememberMe = val ?? false),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Remember Token',
                        style: AppTypography.bodySM(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/recovery'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot Access Code?',
                        style: AppTypography.labelMD(
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Actions: Login & Biometric Auth
              Row(
                children: [
                  Expanded(
                    child: AppButton.primary(
                      text: 'Login',
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _simulateBiometricAuth,
                      borderRadius: BorderRadius.circular(30),
                      child: Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: AppColors.darkCard,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: AppColors.primaryGold,
                            width: 1.2,
                          ),
                          boxShadow: const [AppColors.goldGlow],
                        ),
                        child: const Icon(
                          Icons.fingerprint,
                          color: AppColors.primaryGold,
                          size: 28,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              // Register Link
              Center(
                child: InkWell(
                  onTap: () => context.push('/signup'),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an Atelier Identity? ",
                        style: AppTypography.bodyMD(color: AppColors.textMuted),
                        children: [
                          TextSpan(
                            text: 'Request Membership',
                            style: AppTypography.labelLG(
                              color: AppColors.primaryGold,
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
        ),
      ),
    );
  }
}
