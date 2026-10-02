import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

enum BadgeChipVariant {
  goldPurity,
  darkTag,
  statusSage,
  statusGold,
  statusRuby,
  outline,
}

/// Reusable Luxury Badge / Purity Chip
class AppBadgeChip extends StatelessWidget {
  final String label;
  final Widget? icon;
  final BadgeChipVariant variant;
  final VoidCallback? onTap;
  final bool isSelected;

  const AppBadgeChip({
    super.key,
    required this.label,
    this.icon,
    this.variant = BadgeChipVariant.goldPurity,
    this.onTap,
    this.isSelected = false,
  });

  const AppBadgeChip.purity({
    super.key,
    required this.label,
    this.icon,
    this.onTap,
  })  : variant = BadgeChipVariant.goldPurity,
        isSelected = false;

  const AppBadgeChip.status({
    super.key,
    required this.label,
    this.variant = BadgeChipVariant.statusGold,
    this.icon,
    this.onTap,
  }) : isSelected = false;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    BorderSide border = BorderSide.none;

    switch (variant) {
      case BadgeChipVariant.goldPurity:
        bgColor = const Color(0x24D4AF37);
        textColor = AppColors.primaryGold;
        border = const BorderSide(color: AppColors.outlineGold, width: 0.8);
        break;
      case BadgeChipVariant.darkTag:
        bgColor = isSelected ? AppColors.primaryGold : AppColors.darkSurface;
        textColor = isSelected ? AppColors.textOnGold : AppColors.textOnDark;
        border = BorderSide(color: isSelected ? AppColors.primaryGold : AppColors.darkBorder, width: 1);
        break;
      case BadgeChipVariant.statusSage:
        bgColor = const Color(0x2010B981);
        textColor = AppColors.emeraldGreen;
        border = const BorderSide(color: Color(0x4D10B981), width: 0.8);
        break;
      case BadgeChipVariant.statusGold:
        bgColor = const Color(0x2BD4AF37);
        textColor = AppColors.primaryGold;
        border = const BorderSide(color: AppColors.outlineGold, width: 0.8);
        break;
      case BadgeChipVariant.statusRuby:
        bgColor = const Color(0x20EF4444);
        textColor = AppColors.rubyRed;
        border = const BorderSide(color: Color(0x4DEF4444), width: 0.8);
        break;
      case BadgeChipVariant.outline:
        bgColor = isSelected ? AppColors.primaryGold : Colors.transparent;
        textColor = isSelected ? AppColors.textOnGold : AppColors.textPrimary;
        border = BorderSide(color: isSelected ? AppColors.primaryGold : AppColors.outline, width: 1);
        break;
    }

    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: border != BorderSide.none ? Border.fromBorderSide(border) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: AppTypography.labelSM(color: textColor).copyWith(fontSize: 10),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: chip,
      );
    }

    return chip;
  }
}
