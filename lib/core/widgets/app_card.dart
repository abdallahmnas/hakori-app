import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Reusable Material 3 card with consistent luxury styling.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final BorderRadiusGeometry? borderRadius;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.color,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedBorderRadius =
        borderRadius ?? BorderRadius.circular(AppConstants.radiusMd);

    return Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingMd,
        vertical: AppConstants.spacingSm,
      ),
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        borderRadius: resolvedBorderRadius,
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: resolvedBorderRadius,
        child: InkWell(
          onTap: onTap,
          borderRadius: resolvedBorderRadius as BorderRadius?,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(AppConstants.spacingMd),
            child: child,
          ),
        ),
      ),
    );
  }
}
