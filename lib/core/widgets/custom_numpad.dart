import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Luxury Gold Dialpad for Biometric & OTP entry
class CustomNumpad extends StatelessWidget {
  final void Function(String) onDigitTap;
  final VoidCallback onDeleteTap;
  final VoidCallback? onBiometricTap;
  final bool isDark;

  const CustomNumpad({
    super.key,
    required this.onDigitTap,
    required this.onDeleteTap,
    this.onBiometricTap,
    this.isDark = true,
  });

  Widget _buildButton(String text, {VoidCallback? onTap, Widget? icon}) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: InkWell(
          onTap: onTap ?? (text.isNotEmpty ? () => onDigitTap(text) : null),
          borderRadius: BorderRadius.circular(40),
          splashColor: AppColors.primaryGold.withOpacity(0.2),
          child: Container(
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkCard.withOpacity(0.6) : AppColors.surfaceContainerLow,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.outlineLight,
                width: 1,
              ),
            ),
            child: Center(
              child: icon ??
                  Text(
                    text,
                    style: AppTypography.headlineMD(
                      color: isDark ? AppColors.textOnDark : AppColors.textPrimary,
                    ).copyWith(fontSize: 22),
                  ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _buildButton('1'),
            _buildButton('2'),
            _buildButton('3'),
          ],
        ),
        Row(
          children: [
            _buildButton('4'),
            _buildButton('5'),
            _buildButton('6'),
          ],
        ),
        Row(
          children: [
            _buildButton('7'),
            _buildButton('8'),
            _buildButton('9'),
          ],
        ),
        Row(
          children: [
            _buildButton(
              '',
              onTap: onBiometricTap,
              icon: Icon(
                Icons.fingerprint,
                size: 28,
                color: isDark ? AppColors.primaryGold : AppColors.textPrimary,
              ),
            ),
            _buildButton('0'),
            _buildButton(
              '',
              onTap: onDeleteTap,
              icon: Icon(
                Icons.backspace_outlined,
                size: 22,
                color: isDark ? AppColors.textSecondary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
