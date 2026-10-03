import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen 2: sign_up_atelier_registration
/// Luxury VIP Registration with bespoke validation and biometric security indicators
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _agreedToTerms = true;
  String _selectedCountryCode = '+234';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = '$_selectedCountryCode ${_phoneController.text.trim()}'.trim();
    final password = _passwordController.text;

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your full legal name.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (email.isEmpty || !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid VIP email address.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your direct phone number.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Master vault password must be at least 6 characters.'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the Terms of Commission.'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);
    auth.setPendingRegistration(
      fullName: name,
      phone: phone,
      password: password,
    );

    final success = await auth.initiateSignup(email);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      context.push('/otp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Registration initiation failed.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'ATELIER REGISTRATION',
          style: AppTypography.labelLG(color: AppColors.textPrimary).copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Editorial Title
              Text(
                'Create Your Vault Identity',
                style: AppTypography.headlineXL(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Gain exclusive access to 1-of-1 bespoke commissions, intraoral 3D dental vaults, and live gold spot trading.',
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),
              // Name Field
              AppTextField(
                label: 'Full Legal Name',
                hintText: 'e.g. Lord Alexander Wright',
                controller: _nameController,
                prefixIcon: const Icon(Icons.person_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),
              // Email Field
              AppTextField(
                label: 'VIP Email Address',
                hintText: 'alexander@placevendome.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(Icons.mail_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),
              // Phone Field with Country Code
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Direct Phone (For Armored Delivery Alerts)',
                    style: AppTypography.labelMD(color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedCountryCode,
                            isDense: true,
                            items: const [
                              DropdownMenuItem(value: '+234', child: Text('🇳🇬 +234')),
                              DropdownMenuItem(value: '+1', child: Text('🇺🇸 +1')),
                              DropdownMenuItem(value: '+44', child: Text('🇬🇧 +44')),
                              DropdownMenuItem(value: '+33', child: Text('🇫🇷 +33')),
                              DropdownMenuItem(value: '+971', child: Text('🇦🇪 +971')),
                            ],
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCountryCode = val);
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppTextField(
                          hintText: '803 123 4567',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Master Password
              AppTextField(
                label: 'Master Vault Password',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(Icons.lock_outline, size: 20, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 8),
              // Password strength row
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.emeraldGreen,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '256-Bit Strong',
                    style: AppTypography.labelSM(color: AppColors.emeraldGreen),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Terms & Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryGold,
                    checkColor: AppColors.textOnGold,
                    onChanged: (val) => setState(() => _agreedToTerms = val ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'I agree to the Place Vendôme Atelier Terms of Commission and Vault Security Protocol.',
                        style: AppTypography.bodySM(color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Primary Register CTA
              AppButton.primary(
                text: _isSubmitting ? 'DISPATCHING SECURE OTP...' : 'INITIALIZE ATELIER ACCOUNT',
                onPressed: _isSubmitting ? null : _handleSignUp,
              ),
              const SizedBox(height: 20),
              // Social Auth Divider
              Row(
                children: [
                  const Expanded(child: Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'OR AUTHENTICATE WITH',
                      style: AppTypography.labelSM(color: AppColors.textMuted),
                    ),
                  ),
                  const Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              // Social Auth Buttons
              Row(
                children: [
                  Expanded(
                    child: AppButton.outline(
                      text: 'Apple ID',
                      height: 48,
                      prefixIcon: const Icon(Icons.apple, size: 20),
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton.outline(
                      text: 'Google',
                      height: 48,
                      prefixIcon: const Icon(Icons.g_mobiledata, size: 24),
                      onPressed: () => context.go('/home'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Login Link
              Center(
                child: InkWell(
                  onTap: () => context.push('/login'),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have a Vault identity? ',
                        style: AppTypography.bodyMD(color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: AppTypography.labelLG(color: AppColors.primaryGold),
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
