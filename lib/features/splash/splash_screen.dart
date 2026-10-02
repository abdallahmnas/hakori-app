import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_typography.dart';

/// Animated Luxury Splash Screen with Hakori Al Madinah Logo and Gold Shimmer
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.65, curve: Curves.easeIn)),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic)),
    );

    _controller.forward();

    Timer(const Duration(milliseconds: 2600), () {
      if (mounted) {
        context.go('/welcome');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: Stack(
        children: [
          // Subtle Ambient Background Glow
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primaryGold.withOpacity(0.18),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo container with gold ring
                  Container(
                    width: 90,
                    height: 90,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.darkCard,
                      border: Border.all(color: AppColors.primaryGold, width: 1.5),
                      boxShadow: const [AppColors.goldGlow],
                    ),
                    child: Image.network(
                      AppConstants.logoUrl,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Image.asset(
                        AppConstants.logoLocalPath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.diamond,
                          size: 40,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // App Title
                  Text(
                    'HAKORI AL MADINAH',
                    textAlign: TextAlign.center,
                    style: AppTypography.headlineXL(color: AppColors.textOnDark).copyWith(
                      letterSpacing: 4.0,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Subtitle
                  Text(
                    'HAUTE JOAILLERIE & STREET LUXURY',
                    textAlign: TextAlign.center,
                    style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Place Vendôme • Bespoke Dental Artistry',
                    textAlign: TextAlign.center,
                    style: AppTypography.bodySM(color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 48),
                  // Shimmer progress line
                  SizedBox(
                    width: 140,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: const LinearProgressIndicator(
                        minHeight: 2,
                        backgroundColor: AppColors.darkBorder,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Bottom Place Vendôme Hallmark
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryGold),
                    const SizedBox(width: 6),
                    Text(
                      '18K SOLID GOLD • CERTIFIED VVS DIAMONDS',
                      style: AppTypography.labelSM(color: AppColors.textMuted).copyWith(fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
