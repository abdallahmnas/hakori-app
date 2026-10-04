import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/services/order_provider.dart';
import '../../core/services/product_provider.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/app_text_field.dart';

/// Screen: Complete Profile (Step 3 of Onboarding)
/// Collects user details (First Name, Last Name, Password, Phone, Address) to finalize account
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _handleComplete() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final phone = _phoneController.text.trim();
    final address = _addressController.text.trim();
    final city = _cityController.text.trim();
    final country = _countryController.text.trim();

    if (firstName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your first name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your last name.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    final success = await auth.completeSignup(
      firstName: firstName,
      lastName: lastName,
      fullName: '$firstName $lastName'.trim(),
      password: password,
      phone: phone.isNotEmpty ? phone : null,
      address: address.isNotEmpty ? address : null,
      city: city.isNotEmpty ? city : null,
      country: country.isNotEmpty ? country : null,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      productProvider.fetchCatalog();
      orderProvider.fetchOrders();
      auth.refreshProfile();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome, $firstName! Your account is ready.'),
          backgroundColor: AppColors.darkBase,
        ),
      );
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Failed to complete profile.'),
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
          'COMPLETE PROFILE',
          style: AppTypography.labelLG(
            color: AppColors.textPrimary,
          ).copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress Indicator (Step 3 of 3)
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
                        color: AppColors.primaryGold,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Step 3 of 3: Profile Details',
                style: AppTypography.labelSM(color: AppColors.primaryGold),
              ),
              const SizedBox(height: 16),

              Text(
                'Complete Your Profile',
                style: AppTypography.headlineXL(color: AppColors.textPrimary),
              ),
              const SizedBox(height: 8),
              Text(
                'Enter your personal details and set your password to finalize your account.',
                style: AppTypography.bodyMD(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 28),

              // First Name & Last Name Row
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'First Name',
                      hintText: 'John',
                      controller: _firstNameController,
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
                      label: 'Last Name',
                      hintText: 'Doe',
                      controller: _lastNameController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Password Field
              AppTextField(
                label: 'Password',
                hintText: 'Minimum 6 characters',
                controller: _passwordController,
                isPassword: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),

              // Confirm Password Field
              AppTextField(
                label: 'Confirm Password',
                hintText: 'Re-enter your password',
                controller: _confirmPasswordController,
                isPassword: true,
                prefixIcon: const Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),

              // Phone Number
              AppTextField(
                label: 'Phone Number (Optional)',
                hintText: '+1 (555) 000-0000',
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),

              // Street Address
              AppTextField(
                label: 'Street Address (Optional)',
                hintText: '123 Luxury Lane, Suite 400',
                controller: _addressController,
                prefixIcon: const Icon(
                  Icons.home_outlined,
                  size: 20,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 16),

              // City and Country
              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: 'City (Optional)',
                      hintText: 'Paris / London / Lagos',
                      controller: _cityController,
                      prefixIcon: const Icon(
                        Icons.location_city_outlined,
                        size: 20,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: 'Country (Optional)',
                      hintText: 'United Kingdom',
                      controller: _countryController,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Submit Button
              AppButton.primary(
                text: _isSubmitting
                    ? 'CREATING ACCOUNT...'
                    : 'COMPLETE SIGN UP',
                onPressed: _isSubmitting ? null : _handleComplete,
                suffixIcon: const Icon(
                  Icons.check,
                  size: 18,
                  color: AppColors.textOnGold,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
