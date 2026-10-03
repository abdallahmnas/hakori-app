import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/auth_provider.dart';
import '../../core/widgets/otp_input_field.dart';
import '../../core/widgets/custom_numpad.dart';

/// Screen 4: otp_biometric_verification
/// 6-digit OTP verification with custom luxury gold dialpad
class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  String _code = '';
  int _secondsRemaining = 45;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigitTap(String digit) {
    if (_isVerifying) return;
    if (_code.length < 6) {
      setState(() {
        _code += digit;
      });
      if (_code.length == 6) {
        _verifyCode();
      }
    }
  }

  void _onDeleteTap() {
    if (_isVerifying) return;
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
      });
    }
  }

  Future<void> _verifyCode() async {
    setState(() => _isVerifying = true);
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // If part of signup flow
    if (auth.signupSessionToken != null) {
      final verifyOk = await auth.verifySignupOtp(_code);
      if (!verifyOk) {
        if (!mounted) return;
        setState(() {
          _isVerifying = false;
          _code = '';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Invalid verification code.'),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }

      // Step 3: Complete registration
      final completeOk = await auth.completeSignup(
        password: auth.pendingPassword ?? 'Hakori@2026',
        fullName: auth.pendingFullName ?? 'VIP Patron',
        phone: auth.pendingPhone,
      );

      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (completeOk) {
        context.go('/home');
      } else {
        setState(() => _code = '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Account completion failed.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // If part of password reset flow
    if (auth.resetSessionToken != null) {
      final verifyResetOk = await auth.verifyResetOtp(_code);
      if (!mounted) return;
      setState(() => _isVerifying = false);

      if (verifyResetOk) {
        context.push('/recovery');
      } else {
        setState(() => _code = '');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Invalid reset code.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    // Default fallback
    if (!mounted) return;
    setState(() => _isVerifying = false);
    context.go('/home');
  }

  Future<void> _resendCode() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.lastEmail != null && auth.lastEmail!.isNotEmpty) {
      final ok = await auth.initiateSignup(auth.lastEmail!);
      if (ok) {
        _startTimer();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A new 6-digit cryptographic code has been sent.'),
            backgroundColor: AppColors.darkBase,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final targetContact = auth.lastEmail ?? '+234 (***) ***-8942';

    return Scaffold(
      backgroundColor: AppColors.darkBase,
      appBar: AppBar(
        backgroundColor: AppColors.darkBase,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppColors.primaryGold),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'SECURITY PROTOCOL',
          style: AppTypography.labelLG(color: AppColors.textOnDark).copyWith(letterSpacing: 2),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Security Shield Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.darkCard,
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(
                  Icons.lock_clock_outlined,
                  size: 28,
                  color: AppColors.primaryGold,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Enter 6-Digit Token',
                style: AppTypography.headlineLG(color: AppColors.textOnDark),
              ),
              const SizedBox(height: 6),
              Text(
                'Encrypted authorization token dispatched to\n$targetContact',
                textAlign: TextAlign.center,
                style: AppTypography.bodySM(color: AppColors.textMuted),
              ),
              const SizedBox(height: 28),
              // OTP Input Boxes
              OtpInputField(
                currentCode: _code,
                length: 6,
                isDark: true,
              ),
              const SizedBox(height: 16),
              if (_isVerifying)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                    ),
                  ),
                ),
              // Resend Timer Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _secondsRemaining > 0
                        ? 'Resend token in 00:${_secondsRemaining.toString().padLeft(2, '0')}'
                        : 'Did not receive code?',
                    style: AppTypography.bodySM(color: AppColors.textMuted),
                  ),
                  if (_secondsRemaining == 0) ...[
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: _resendCode,
                      child: Text(
                        'Request New',
                        style: AppTypography.labelMD(color: AppColors.primaryGold),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              // Custom Numeric Dialpad
              CustomNumpad(
                onDigitTap: _onDigitTap,
                onDeleteTap: _onDeleteTap,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
