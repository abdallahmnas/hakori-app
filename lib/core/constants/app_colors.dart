import 'package:flutter/material.dart';

/// Haute Joaillerie & Street Luxury Color Palette for Hakori Al Madinah / GoldSmile
/// Rooted in 18K/24K Yellow Gold, Obsidian Black, Pure Gallery Ivory, and Champagne Accents.
class AppColors {
  AppColors._();

  // Primary Metallics (18K & 24K Yellow Gold)
  static const Color primaryGold = Color(0xFFD4AF37);
  static const Color goldAccent = Color(0xFFE5C158);
  static const Color goldLight = Color(0xFFF3E5AB);
  static const Color goldDark = Color(0xFF997A15);
  static const Color goldContainer = Color(0xFFFFF6D6);
  static const Color onGoldContainer = Color(0xFF423300);

  // Material Theme Compatibility Aliases
  static const Color primary = primaryGold;
  static const Color primaryLight = goldLight;
  static const Color primaryDark = goldDark;
  static const Color primaryContainer = goldContainer;
  static const Color onPrimaryContainer = onGoldContainer;

  static const Color secondary = Color(0xFF18181B);
  static const Color secondaryLight = Color(0xFF27272A);
  static const Color secondaryDark = Color(0xFF0B0B0C);
  static const Color secondaryContainer = Color(0xFFF0EDEE);
  static const Color onSecondaryContainer = Color(0xFF1C1B1C);

  static const Color tertiary = goldAccent;
  static const Color tertiaryContainer = Color(0xFFFFE08B);

  // Obsidian & Neutral Foundations
  static const Color darkBase = Color(0xFF0B0B0C);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkCard = Color(0xFF1F1F23);
  static const Color darkBorder = Color(0xFF27272A);

  // Gallery Ivory & Light Mode Surfaces
  static const Color background = Color(0xFFFCF8F9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0EDEA);
  static const Color surfaceIvory = Color(0xFFFDFBF7);
  static const Color surfaceContainerLow = Color(0xFFF6F3F4);
  static const Color surfaceContainer = Color(0xFFF0EDEE);
  static const Color surfaceContainerHigh = Color(0xFFEBE7E8);
  static const Color surfaceContainerHighest = Color(0xFFE5E2E3);
  static const Color onBackground = Color(0xFF1C1B1C);
  static const Color onSurface = Color(0xFF1C1B1C);
  static const Color onSurfaceVariant = Color(0xFF4D4635);

  // Text & Typography Colors
  static const Color textPrimary = Color(0xFF1C1B1C);
  static const Color textSecondary = Color(0xFF71717A);
  static const Color textMuted = Color(0xFFA1A1AA);
  static const Color textGold = Color(0xFFD4AF37);
  static const Color textOnDark = Color(0xFFFDFBF7);
  static const Color textOnGold = Color(0xFF0B0B0C);

  // Hairlines & Outlines
  static const Color outline = Color(0xFFE4E4E7);
  static const Color outlineLight = Color(0xFFF0F0F2);
  static const Color outlineVariant = Color(0xFFD0C5AF);
  static const Color outlineGold = Color(0x66D4AF37);
  static const Color divider = Color(0xFFEBE7E8);

  // Status & Gem Tones
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color rubyRed = Color(0xFFEF4444);
  static const Color sapphireBlue = Color(0xFF3B82F6);
  static const Color diamondShimmer = Color(0xFFE0F2FE);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color success = Color(0xFF10B981);
  static const Color successContainer = Color(0xFFC8E6C9);

  // Shadows & Overlays
  static const Color shadow = Color(0x1A000000);
  static const Color scrim = Color(0x52000000);

  // Luxury Gradients
  static const List<Color> goldLinearGradient = [
    Color(0xFFE5C158),
    Color(0xFFD4AF37),
    Color(0xFFB88E18),
  ];

  static const List<Color> primaryGradient = goldLinearGradient;
  static const List<Color> goldGradient = goldLinearGradient;

  static const List<Color> darkLinearGradient = [
    Color(0xFF18181B),
    Color(0xFF0B0B0C),
  ];

  static const List<Color> heroGradient = darkLinearGradient;

  static const List<Color> goldShimmerGradient = [
    Color(0xFFD4AF37),
    Color(0xFFFFF6D6),
    Color(0xFFD4AF37),
  ];

  // Glow Shadows
  static const BoxShadow goldGlow = BoxShadow(
    color: Color(0x47D4AF37),
    blurRadius: 20,
    offset: Offset(0, 6),
  );

  static const BoxShadow softCardShadow = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );

  static const BoxShadow floatingSheetShadow = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 24,
    offset: Offset(0, -6),
  );
}
