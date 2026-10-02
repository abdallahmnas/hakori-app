import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/widgets/app_button.dart';
import '../../core/widgets/badge_chip.dart';

/// Screen 1: welcome_luxury_onboarding
/// Redesigned 3-Slide Interactive Pager Onboarding with Haute Joaillerie Illustrations
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlideData> _slides = [
    OnboardingSlideData(
      badge: 'PARIS VENDÔME ATELIER',
      title: 'HAUTE JOAILLERIE\nMEETS STREET LUXURY',
      description:
          'Bespoke 18K solid gold & VVS natural diamond dental artistry handcrafted with Place Vendôme prestige.',
      tags: ['18K & 24K Certified Gold', 'VVS1 Natural Diamonds'],
      bgImage:
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1200&auto=format&fit=crop',
      illustrationType: IllustrationType.diamondGrillz,
    ),
    OnboardingSlideData(
      badge: 'SUB-MILLIMETER ACCURACY',
      title: '3D INTRAORAL SCAN\n& AR LIVE FITTING',
      description:
          'Experience live augmented reality smile simulations and 0.05mm dental margin accuracy for a flawless fit.',
      tags: ['0.05mm Margin Fit', 'Real-Time AR Camera'],
      bgImage:
          'https://images.unsplash.com/photo-1600003014755-ba31aa59c4b6?q=80&w=1200&auto=format&fit=crop',
      illustrationType: IllustrationType.arScanner,
    ),
    OnboardingSlideData(
      badge: '256-BIT VAULT ESCROW',
      title: 'ARMORED ESCROW\n& VIP CONCIERGE',
      description:
          'Global insured transit with armored courier delivery and private 1-on-1 consultations with our Master Jewelers.',
      tags: ['Armored Courier Escrow', '1-on-1 Master Jeweler'],
      bgImage:
          'https://images.unsplash.com/photo-1515562141207-7a88fb7ce338?q=80&w=1200&auto=format&fit=crop',
      illustrationType: IllustrationType.vaultSecurity,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.push('/signup');
    }
  }

  @override
  Widget build(BuildContext context) {
    final slide = _slides[_currentPage];

    return Scaffold(
      backgroundColor: AppColors.darkBase,
      body: Stack(
        children: [
          // Background Photography with Smooth Cross-Fade
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Image.network(
                slide.bgImage,
                key: ValueKey(slide.bgImage),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: AppColors.darkBase,
                ),
              ),
            ),
          ),

          // Luxury Dark Gradient Scrim
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xCC0A0A0B),
                    Color(0x990A0A0B),
                    Color(0xEB0A0A0B),
                    AppColors.darkBase,
                  ],
                  stops: [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // Main Interactive Content Area
          SafeArea(
            child: Column(
              children: [
                // Top Brand Header & Skip Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryGold, width: 1.2),
                              color: AppColors.darkCard,
                              boxShadow: const [AppColors.goldGlow],
                            ),
                            child: const Icon(
                              Icons.diamond_outlined,
                              size: 16,
                              color: AppColors.primaryGold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'HAKORI',
                            style: AppTypography.labelLG(color: AppColors.textOnDark).copyWith(
                              letterSpacing: 2.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      if (_currentPage < _slides.length - 1)
                        TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              _slides.length - 1,
                              duration: const Duration(milliseconds: 350),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'SKIP',
                            style: AppTypography.labelSM(color: AppColors.textMuted).copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Interactive PageView
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) => setState(() => _currentPage = index),
                    itemCount: _slides.length,
                    itemBuilder: (context, index) {
                      final item = _slides[index];
                      return SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            // Custom Illustrated Focal Artwork
                            Center(
                              child: _buildIllustration(item.illustrationType),
                            ),
                            const SizedBox(height: 20),

                            // Badge Chip
                            AppBadgeChip(
                              label: item.badge,
                              variant: BadgeChipVariant.goldPurity,
                            ),
                            const SizedBox(height: 12),

                            // Headline
                            Text(
                              item.title,
                              style: AppTypography.headline2XL(color: AppColors.textOnDark).copyWith(
                                fontSize: 28,
                                letterSpacing: -0.5,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Description
                            Text(
                              item.description,
                              style: AppTypography.bodyMD(color: AppColors.surfaceContainerHigh).copyWith(
                                height: 1.45,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Feature Tags
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: item.tags
                                  .map(
                                    (tag) => AppBadgeChip(
                                      label: tag,
                                      icon: const Icon(Icons.check_circle_outline, size: 12, color: AppColors.primaryGold),
                                      variant: BadgeChipVariant.darkTag,
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Bottom Pagination Dots & Actions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Page Indicator Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _slides.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 6,
                            width: _currentPage == i ? 28 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == i ? AppColors.primaryGold : const Color(0x44D4AF37),
                              borderRadius: BorderRadius.circular(3),
                              boxShadow: _currentPage == i ? const [AppColors.goldGlow] : null,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Dynamic Action Buttons
                      if (_currentPage < _slides.length - 1) ...[
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.primary(
                                text: 'NEXT',
                                height: 50,
                                onPressed: _nextPage,
                                suffixIcon: const Icon(Icons.arrow_forward, size: 16, color: AppColors.textOnGold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => context.push('/login'),
                          child: Text(
                            'VIP VAULT ACCESS / LOG IN',
                            style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ] else ...[
                        AppButton.primary(
                          text: 'ENTER THE ATELIER',
                          height: 50,
                          onPressed: () => context.push('/signup'),
                          suffixIcon: const Icon(Icons.arrow_forward, size: 18, color: AppColors.textOnGold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.dark(
                                text: 'LOG IN',
                                height: 46,
                                onPressed: () => context.push('/login'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton.ghost(
                                text: 'EXPLORE GUEST',
                                height: 46,
                                onPressed: () => context.go('/home'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Illustration Widget Builder
  Widget _buildIllustration(IllustrationType type) {
    switch (type) {
      case IllustrationType.diamondGrillz:
        return const _GrillzIllustration();
      case IllustrationType.arScanner:
        return const _ScannerIllustration();
      case IllustrationType.vaultSecurity:
        return const _VaultIllustration();
    }
  }
}

enum IllustrationType {
  diamondGrillz,
  arScanner,
  vaultSecurity,
}

class OnboardingSlideData {
  final String badge;
  final String title;
  final String description;
  final List<String> tags;
  final String bgImage;
  final IllustrationType illustrationType;

  OnboardingSlideData({
    required this.badge,
    required this.title,
    required this.description,
    required this.tags,
    required this.bgImage,
    required this.illustrationType,
  });
}

// Custom Luxury Illustration: 18K Diamond Grillz & Haute Artistry
class _GrillzIllustration extends StatelessWidget {
  const _GrillzIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.primaryGold.withAlpha(160), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33D4AF37),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial Concentric Rings
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33D4AF37), width: 1),
            ),
          ),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x22D4AF37), width: 1),
            ),
          ),
          // Dental Arch & Gold Diamonds Center Piece
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  6,
                  (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2.5),
                    width: 15,
                    height: 28,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: i.isEven
                            ? [const Color(0xFFFFF3CD), AppColors.primaryGold]
                            : [const Color(0xFFFFFFFF), const Color(0xFFD4AF37)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: const [
                        BoxShadow(color: Color(0x44D4AF37), blurRadius: 6),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.auto_awesome,
                        size: 9,
                        color: i.isEven ? AppColors.darkBase : const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x2BD4AF37),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.outlineGold, width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.diamond, size: 10, color: AppColors.primaryGold),
                    SizedBox(width: 4),
                    Text(
                      '18K SOLID GOLD',
                      style: TextStyle(color: AppColors.primaryGold, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Custom Luxury Illustration: 3D Intraoral Scanner & Holographic AR
class _ScannerIllustration extends StatelessWidget {
  const _ScannerIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.primaryGold.withAlpha(160), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3310B981),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 3D Matrix Grid Circle
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x3310B981), width: 1),
            ),
          ),
          // AR Targeting Reticle
          const Icon(Icons.view_in_ar, size: 52, color: AppColors.primaryGold),
          Positioned(
            top: 36,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0x2B10B981),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0x6610B981), width: 0.8),
              ),
              child: const Text(
                '0.05mm TOLERANCE',
                style: TextStyle(color: AppColors.emeraldGreen, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.center_focus_strong, size: 14, color: AppColors.primaryGold),
                SizedBox(width: 4),
                Text(
                  'AR LIVE SMILE FIT',
                  style: TextStyle(color: AppColors.textOnDark, fontSize: 8, fontWeight: FontWeight.w600, letterSpacing: 1.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Luxury Illustration: Armored Escrow & Security Shield
class _VaultIllustration extends StatelessWidget {
  const _VaultIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.primaryGold.withAlpha(160), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33D4AF37),
            blurRadius: 32,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33D4AF37), width: 1),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0x2BD4AF37),
                  border: Border.all(color: AppColors.primaryGold, width: 1.5),
                  boxShadow: const [AppColors.goldGlow],
                ),
                child: const Icon(Icons.shield_outlined, size: 36, color: AppColors.primaryGold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0x24D4AF37),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineGold, width: 0.8),
                ),
                child: const Text(
                  'ARMORED TRANSIT ESCROW',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
