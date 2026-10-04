import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/services/storage_service.dart';
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
      badge: '18K & 24K SOLID GOLD',
      title: 'SOLID GOLD &\nVVS DIAMONDS',
      description:
          'Bespoke handcrafted gold necklaces, rings, and fine jewelry studded with certified brilliant-cut diamonds.',
      tags: ['18K & 24K Certified Gold', 'VVS1 Natural Diamonds'],
      bgImage:
          'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1200&auto=format&fit=crop',
      illustrationType: IllustrationType.goldJewelry,
    ),
    OnboardingSlideData(
      badge: '925 STERLING SILVER',
      title: 'STERLING SILVER\n& SOLID PLATINUM',
      description:
          'Artisanal 925 sterling silver and solid platinum chains, rings, and fine jewelry finished with brilliant luster.',
      tags: ['925 Sterling Silver', 'Pure Solid Platinum'],
      bgImage:
          'https://images.unsplash.com/photo-1535632066927-ab7c9ab60908?q=80&w=1200&auto=format&fit=crop',
      illustrationType: IllustrationType.silverJewelry,
    ),
    OnboardingSlideData(
      badge: 'CERTIFIED AUTHENTICITY',
      title: 'AUTHENTICATED JEWELRY\n& PRIVATE CONCIERGE',
      description:
          'Every piece is hallmarked, securely insured in transit, and accompanied by authentic gemological certification.',
      tags: ['Insured Global Delivery', 'Gemological Certificate'],
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

  void _dismissOnboarding() {
    try {
      Provider.of<StorageService>(context, listen: false).setOnboardingCompleted(true);
    } catch (_) {}
  }

  void _nextPage() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _dismissOnboarding();
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
                            _dismissOnboarding();
                            context.push('/login');
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
                          onPressed: () {
                            _dismissOnboarding();
                            context.push('/login');
                          },
                          child: Text(
                            'ALREADY HAVE AN ACCOUNT? LOG IN',
                            style: AppTypography.labelSM(color: AppColors.primaryGold).copyWith(
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ] else ...[
                        AppButton.primary(
                          text: 'CREATE AN ACCOUNT',
                          height: 50,
                          onPressed: () {
                            _dismissOnboarding();
                            context.push('/signup');
                          },
                          suffixIcon: const Icon(Icons.arrow_forward, size: 18, color: AppColors.textOnGold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: AppButton.dark(
                                text: 'LOG IN',
                                height: 46,
                                onPressed: () {
                                  _dismissOnboarding();
                                  context.push('/login');
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: AppButton.ghost(
                                text: 'EXPLORE AS GUEST',
                                height: 46,
                                onPressed: () {
                                  _dismissOnboarding();
                                  context.go('/home');
                                },
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
      case IllustrationType.goldJewelry:
        return const _GoldJewelryIllustration();
      case IllustrationType.silverJewelry:
        return const _SilverJewelryIllustration();
      case IllustrationType.vaultSecurity:
        return const _VaultIllustration();
    }
  }
}

enum IllustrationType {
  goldJewelry,
  silverJewelry,
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

// Custom Luxury Illustration: 18K Solid Gold & VVS Certified Diamonds
class _GoldJewelryIllustration extends StatelessWidget {
  const _GoldJewelryIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkCard,
        border: Border.all(color: AppColors.primaryGold.withAlpha(180), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44D4AF37),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial Concentric Gold Rings
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const RadialGradient(
                    colors: [Color(0x33D4AF37), Colors.transparent],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.diamond,
                    size: 38,
                    color: AppColors.primaryGold,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                      style: TextStyle(
                        color: AppColors.primaryGold,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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

// Custom Luxury Illustration: 925 Sterling Silver & Solid Platinum
class _SilverJewelryIllustration extends StatelessWidget {
  const _SilverJewelryIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkCard,
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3394A3B8),
            blurRadius: 36,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Radial Concentric Silver Rings
          Container(
            width: 138,
            height: 138,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x33CBD5E1), width: 1),
            ),
          ),
          Container(
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0x22CBD5E1), width: 1),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [Color(0x33E2E8F0), Colors.transparent],
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.military_tech_outlined,
                    size: 38,
                    color: Color(0xFFE2E8F0),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x20E2E8F0),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0x66E2E8F0), width: 0.8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, size: 10, color: Color(0xFFE2E8F0)),
                    SizedBox(width: 4),
                    Text(
                      '925 SILVER',
                      style: TextStyle(
                        color: Color(0xFFE2E8F0),
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0x24D4AF37),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.outlineGold, width: 0.8),
                ),
                child: const Text(
                  'CERTIFIED VAULT',
                  style: TextStyle(color: AppColors.primaryGold, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
