import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';

/// Editorial Section Header with optional action button
class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onActionTap;
  final bool isDark;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionText = 'VIEW ALL',
    this.onActionTap,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? AppColors.textOnDark : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: AppTypography.headlineMD(color: titleColor),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: AppTypography.bodyXS(color: AppColors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (onActionTap != null && actionText != null)
            InkWell(
              onTap: onActionTap,
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      actionText!,
                      style: AppTypography.labelSM(color: AppColors.primaryGold),
                    ),
                    const SizedBox(width: 3),
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 10,
                      color: AppColors.primaryGold,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
