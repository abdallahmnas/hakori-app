import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen: Sign Up (Step 1: Email Entry)
/// Users begin registration by entering their email address.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  bool _agreedToTerms = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleContinue() async {
    final email = _emailController.text.trim();

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (email.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the Terms of Service.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.initiateSignup(email);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      context.push('/otp');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Signup initiation failed. Please try again.'),
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
          'SIGN UP',
          style: AppTypography.labelLG(color: AppColors.textPrimary)
              .copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Bar (Step 1 of 3)
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
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.outlineLight,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Step 1 of 3: Email Address',
                style: AppTypography.labelSM(color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),

              // Title
              Text(
                'Create Your Account',
                style: AppTypography.headlineXL(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your email address to receive your verification code.',
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),

              // Email Field
              AppTextField(
                label: 'Email',
                hintText: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 24),

              // Terms & Conditions Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _agreedToTerms,
                    activeColor: AppColors.primaryGold,
                    checkColor: AppColors.textOnGold,
                    onChanged: (val) =>
                        setState(() => _agreedToTerms = val ?? false),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'I agree to the Terms of Service and Privacy Policy.',
                        style: AppTypography.bodySM(
                            color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Primary CTA
              AppButton.primary(
                text: _isSubmitting ? 'SENDING CODE...' : 'CONTINUE',
                onPressed: _isSubmitting ? null : _handleContinue,
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  size: 18,
                  color: AppColors.textOnGold,
                ),
              ),
              const SizedBox(height: 28),

              // Login Link
              Center(
                child: InkWell(
                  onTap: () => context.push('/login'),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: AppTypography.bodyMD(
                            color: AppColors.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Log In',
                            style: AppTypography.labelLG(
                                color: AppColors.primaryGold),
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
