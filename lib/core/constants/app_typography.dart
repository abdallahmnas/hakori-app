import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Clean native system typography:
/// Uses default system fonts on the device (San Francisco on iOS, Roboto on Android)
/// so that system keyboards, input methods, and emojis are never overridden.
class AppTypography {
  AppTypography._();

  // Headlines
  static TextStyle headline2XL({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle headlineXL({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineLG({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: color,
      );

  static TextStyle headlineMD({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle headlineSM({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // Body
  static TextStyle bodyLG({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMD({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySM({Color color = AppColors.textSecondary}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyXS({Color color = AppColors.textMuted}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color,
      );

  // Labels & Buttons
  static TextStyle labelLG({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelMD({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle labelSM({Color color = AppColors.textSecondary}) =>
      TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle priceDisplay({Color color = AppColors.textPrimary}) =>
      TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle priceSecondary({Color color = AppColors.textSecondary}) =>
      TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
