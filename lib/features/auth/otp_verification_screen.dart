import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
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
  String _code = '894';
  int _secondsRemaining = 45;
  Timer? _timer;

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
    if (_code.length < 6) {
      setState(() {
        _code += digit;
      });
      if (_code.length == 6) {
        // Auto submit
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            context.go('/home');
          }
        });
      }
    }
  }

  void _onDeleteTap() {
    if (_code.isNotEmpty) {
      setState(() {
        _code = _code.substring(0, _code.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'Encrypted authorization token dispatched to\n+234 (***) ***-8942',
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
                      onTap: _startTimer,
                      child: Text(
                        'Request New Code',
                        style: AppTypography.labelMD(color: AppColors.primaryGold),
                      ),
                    ),
                  ],
                ],
              ),
              const Spacer(),
              // Custom Luxury Numpad
              CustomNumpad(
                onDigitTap: _onDigitTap,
                onDeleteTap: _onDeleteTap,
                onBiometricTap: () => context.go('/home'),
                isDark: true,
              ),
              const SizedBox(height: 16),
              // Verify Button
              AppButton.primary(
                text: 'VERIFY & UNLOCK VAULT',
                onPressed: _code.length >= 4 ? () => context.go('/home') : null,
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
