import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Central theme configuration for Hakori Al Madinah app.
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final textTheme = GoogleFonts.interTextTheme();

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: AppColors.primaryGold,
        onPrimary: AppColors.textOnGold,
        primaryContainer: AppColors.goldContainer,
        onPrimaryContainer: AppColors.onGoldContainer,
        secondary: AppColors.darkSurface,
        onSecondary: AppColors.textOnDark,
        secondaryContainer: AppColors.surfaceContainerHigh,
        onSecondaryContainer: AppColors.textPrimary,
        tertiary: AppColors.goldAccent,
        onTertiary: AppColors.textOnGold,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerHighest: AppColors.surfaceContainerHighest,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineLight,
      ),
      textTheme: textTheme.copyWith(
        displayLarge: AppTypography.headline2XL(),
        displayMedium: AppTypography.headlineXL(),
        displaySmall: AppTypography.headlineLG(),
        headlineMedium: AppTypography.headlineMD(),
        headlineSmall: AppTypography.headlineSM(),
        bodyLarge: AppTypography.bodyLG(),
        bodyMedium: AppTypography.bodyMD(),
        bodySmall: AppTypography.bodySM(),
        labelLarge: AppTypography.labelLG(),
        labelMedium: AppTypography.labelMD(),
        labelSmall: AppTypography.labelSM(),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: AppTypography.headlineMD(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.outlineLight, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceContainerLow,
        hintStyle: AppTypography.bodyMD(color: AppColors.textMuted),
        labelStyle: AppTypography.labelMD(color: AppColors.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryGold,
          foregroundColor: AppColors.textOnGold,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.labelLG(color: AppColors.textOnGold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          side: const BorderSide(color: AppColors.outline, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: AppTypography.labelLG(color: AppColors.textPrimary),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBase,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: AppColors.primaryGold,
        onPrimary: AppColors.textOnGold,
        primaryContainer: AppColors.darkCard,
        onPrimaryContainer: AppColors.primaryGold,
        secondary: AppColors.goldAccent,
        onSecondary: AppColors.textOnGold,
        secondaryContainer: AppColors.darkSurface,
        onSecondaryContainer: Colors.white,
        tertiary: AppColors.goldLight,
        onTertiary: AppColors.textOnGold,
        error: AppColors.error,
        onError: Colors.white,
        surface: AppColors.darkSurface,
        onSurface: AppColors.textOnDark,
        surfaceContainerHighest: AppColors.darkCard,
        outline: AppColors.darkBorder,
        outlineVariant: AppColors.darkBorder,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkBase,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textOnDark, size: 22),
        titleTextStyle: AppTypography.headlineMD(color: AppColors.textOnDark),
      ),
    );
  }
}
