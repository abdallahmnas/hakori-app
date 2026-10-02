import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Haute Joaillerie typography pairing:
/// Playfair Display (High-contrast luxury serif for headlines)
/// Inter (Clean, precise Swiss sans-serif for metadata and body)
class AppTypography {
  AppTypography._();

  // Serif Headlines (Playfair Display)
  static TextStyle headline2XL({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        height: 1.2,
        color: color,
      );

  static TextStyle headlineXL({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.4,
        height: 1.25,
        color: color,
      );

  static TextStyle headlineLG({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.3,
        height: 1.3,
        color: color,
      );

  static TextStyle headlineMD({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle headlineSM({Color color = AppColors.textPrimary}) =>
      GoogleFonts.playfairDisplay(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: color,
      );

  // Sans-serif Body (Inter)
  static TextStyle bodyLG({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle bodyMD({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle bodySM({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: color,
      );

  static TextStyle bodyXS({Color color = AppColors.textMuted}) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        height: 1.3,
        color: color,
      );

  // Sans-serif Labels & Buttons
  static TextStyle labelLG({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle labelMD({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.3,
        color: color,
      );

  static TextStyle labelSM({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: color,
      );

  static TextStyle priceDisplay({Color color = AppColors.textPrimary}) =>
      GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle priceSecondary({Color color = AppColors.textSecondary}) =>
      GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
