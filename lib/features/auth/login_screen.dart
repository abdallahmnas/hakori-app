import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/order_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/services/storage_service.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen: Login
/// Standard credentials authentication with biometric quick-access
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: '');
  final _passwordController = TextEditingController(text: '');
  bool _rememberMe = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = Provider.of<StorageService>(context, listen: false);
      final savedEmail = storage.getSavedEmail();
      if (savedEmail != null && savedEmail.isNotEmpty) {
        _emailController.text = savedEmail;
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your password.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.login(
      email: email,
      password: password,
      rememberMe: _rememberMe,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      // Fetch products on dashboard, categories, orders, and profile from APIs
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      productProvider.fetchCatalog();
      orderProvider.fetchOrders();
      auth.refreshProfile();

      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Invalid email or password.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showBiometricComingSoon() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fingerprint login is coming soon.'),
        backgroundColor: AppColors.darkBase,
        duration: Duration(seconds: 2),
      ),
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
          'LOG IN',
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
                    Icons.lock_outline,
                    size: 34,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  'Welcome back. Log in to your account.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMD(color: AppColors.textMuted),
                ),
              ),
              const SizedBox(height: 36),

              // Email Field
              AppTextField(
                label: 'Email',
                hintText: 'you@example.com',
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                isDark: true,
                prefixIcon: const Icon(
                  Icons.mail_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 18),

              // Password Field
              AppTextField(
                label: 'Password',
                hintText: '••••••••••••',
                controller: _passwordController,
                isPassword: true,
                isDark: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
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
                        'Remember Me',
                        style: AppTypography.bodySM(color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => context.push('/recovery'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Forgot Password?',
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
                      text: _isSubmitting ? 'LOGGING IN...' : 'LOG IN',
                      onPressed: _isSubmitting ? null : _handleLogin,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _showBiometricComingSoon,
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
                        text: "Don't have an account? ",
                        style: AppTypography.bodyMD(color: AppColors.textMuted),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
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
