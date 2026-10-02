/// Application-wide constants for Hakori Al Madinah / GoldSmile
class AppConstants {
  AppConstants._();

  // Branding
  static const String appName = 'Hakori Al Madinah';
  static const String brandTagline = 'Haute Joaillerie Meets Street Luxury';
  static const String atelierLocation = 'Place Vendôme Atelier • Lagos VIP Salon';
  static const String logoUrl = 'https://hakorialmadinah.com/media/26/content/favicon-32x32-1.png';
  static const String logoLocalPath = 'assets/images/logo.png';
  static const String appLogoSvg = 'assets/svg/logo.svg';
  static const String profilePlaceholderSvg = 'assets/svg/profile_placeholder.svg';
  static const String defaultUserName = 'Lord Alexander Wright';

  // Currencies
  static const String defaultCurrency = 'USD';
  static const String secondaryCurrency = 'NGN';
  static const double usdToNgnRate = 1550.0;
  static const double usdToEurRate = 0.92;
  static const double usdToGbpRate = 0.79;
  static const double usdToAedRate = 3.67;

  // Gold Standards
  static const String gold18K = '18K Yellow Gold';
  static const String gold18KWhite = '18K White Gold';
  static const String gold18KRose = '18K Rose Gold';
  static const String platinum950 = '950 Platinum';
  static const String vvsDiamond = 'VVS1 Natural Diamond';

  // Animation Durations
  static const Duration splashDuration = Duration(milliseconds: 2400);
  static const Duration defaultAnimDuration = Duration(milliseconds: 300);
  static const Duration fastAnimDuration = Duration(milliseconds: 150);

  // Spacing & Layout Constants (8pt grid system)
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 40.0;

  // Border Radii
  static const double radiusSm = 4.0;
  static const double radiusMd = 8.0;
  static const double radiusLg = 12.0;
  static const double radiusXl = 16.0;
  static const double radiusFull = 9999.0;

  // Avatar Sizes
  static const double avatarSizeSm = 32.0;
  static const double avatarSizeMd = 48.0;
  static const double avatarSizeLg = 80.0;

  // Icon Sizes
  static const double iconSizeSm = 16.0;
  static const double iconSizeMd = 24.0;
  static const double iconSizeLg = 32.0;
}
