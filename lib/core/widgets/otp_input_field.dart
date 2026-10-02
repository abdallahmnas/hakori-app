import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// 6-Digit Luxury OTP Code Input Row
class OtpInputField extends StatelessWidget {
  final String currentCode;
  final int length;
  final bool isDark;

  const OtpInputField({
    super.key,
    required this.currentCode,
    this.length = 6,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(length, (index) {
        final hasChar = index < currentCode.length;
        final isCurrent = index == currentCode.length;
        final char = hasChar ? currentCode[index] : '';

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 48,
          height: 58,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCurrent
                  ? AppColors.primaryGold
                  : (hasChar
                      ? (isDark ? AppColors.goldAccent : AppColors.primaryGold)
                      : (isDark ? AppColors.darkBorder : AppColors.outline)),
              width: isCurrent ? 2 : 1,
            ),
            boxShadow: isCurrent ? [AppColors.goldGlow] : [],
          ),
          child: Center(
            child: Text(
              char,
              style: AppTypography.headlineMD(
                color: isDark ? AppColors.goldAccent : AppColors.textPrimary,
              ),
            ),
          ),
        );
      }),
    );
  }
}
