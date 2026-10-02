import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum AppButtonVariant {
  primaryGold,
  secondaryOutline,
  darkObsidian,
  ghostText,
}

/// Luxury Reusable Button matching Haute Joaillerie Design System
class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool isLoading;
  final double? width;
  final double height;
  final double borderRadius;
  final bool enableGlow;

  final EdgeInsetsGeometry? padding;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primaryGold,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 30,
    this.enableGlow = true,
    this.padding,
  });

  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 30,
    this.enableGlow = true,
    this.padding,
  }) : variant = AppButtonVariant.primaryGold;

  const AppButton.outline({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 30,
    this.enableGlow = false,
    this.padding,
  }) : variant = AppButtonVariant.secondaryOutline;

  const AppButton.dark({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height = 54,
    this.borderRadius = 30,
    this.enableGlow = false,
    this.padding,
  }) : variant = AppButtonVariant.darkObsidian;

  const AppButton.ghost({
    super.key,
    required this.text,
    this.onPressed,
    this.prefixIcon,
    this.suffixIcon,
    this.isLoading = false,
    this.width,
    this.height = 48,
    this.borderRadius = 24,
    this.enableGlow = false,
    this.padding,
  }) : variant = AppButtonVariant.ghostText;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;
    List<BoxShadow> shadows = [];

    switch (variant) {
      case AppButtonVariant.primaryGold:
        bgColor = AppColors.primaryGold;
        textColor = AppColors.textOnGold;
        if (enableGlow && onPressed != null) {
          shadows = [AppColors.goldGlow];
        }
        break;
      case AppButtonVariant.secondaryOutline:
        bgColor = Colors.transparent;
        textColor = AppColors.textPrimary;
        borderSide = const BorderSide(color: AppColors.primaryGold, width: 1.5);
        break;
      case AppButtonVariant.darkObsidian:
        bgColor = AppColors.darkBase;
        textColor = AppColors.primaryGold;
        borderSide = const BorderSide(color: AppColors.darkBorder, width: 1);
        break;
      case AppButtonVariant.ghostText:
        bgColor = Colors.transparent;
        textColor = AppColors.primaryGold;
        break;
    }

    if (onPressed == null) {
      bgColor = AppColors.surfaceContainerHigh;
      textColor = AppColors.textMuted;
      borderSide = BorderSide.none;
      shadows = [];
    }

    final effectivePadding = padding ?? EdgeInsets.symmetric(horizontal: height <= 42 ? 12 : 20);

    return Container(
      width: width ?? double.infinity,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: shadows,
      ),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          splashColor: const Color(0x33F9E79F),
          highlightColor: const Color(0x1AFCF3CF),
          child: Container(
            padding: effectivePadding,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              border: borderSide != BorderSide.none ? Border.fromBorderSide(borderSide) : null,
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.2,
                        valueColor: AlwaysStoppedAnimation<Color>(textColor),
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (prefixIcon != null) ...[
                          prefixIcon!,
                          const SizedBox(width: 6),
                        ],
                        Flexible(
                          child: Text(
                            text,
                            style: (height <= 42
                                    ? AppTypography.labelSM(color: textColor)
                                    : AppTypography.labelLG(color: textColor))
                                .copyWith(
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        if (suffixIcon != null) ...[
                          const SizedBox(width: 6),
                          suffixIcon!,
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
