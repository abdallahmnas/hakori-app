import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_constants.dart';

/// Reusable widget for rendering SVG assets with consistent sizing.
class SvgIcon extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final Color? color;
  final BoxFit fit;

  const SvgIcon({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.color,
    this.fit = BoxFit.contain,
  });

  /// Convenience constructor for small icons (20px).
  const SvgIcon.small({
    super.key,
    required this.assetPath,
    this.color,
    this.fit = BoxFit.contain,
  })  : width = AppConstants.iconSizeSm,
        height = AppConstants.iconSizeSm;

  /// Convenience constructor for medium icons (24px).
  const SvgIcon.medium({
    super.key,
    required this.assetPath,
    this.color,
    this.fit = BoxFit.contain,
  })  : width = AppConstants.iconSizeMd,
        height = AppConstants.iconSizeMd;

  /// Convenience constructor for large icons (32px).
  const SvgIcon.large({
    super.key,
    required this.assetPath,
    this.color,
    this.fit = BoxFit.contain,
  })  : width = AppConstants.iconSizeLg,
        height = AppConstants.iconSizeLg;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      colorFilter: color != null
          ? ColorFilter.mode(color!, BlendMode.srcIn)
          : null,
    );
  }
}
