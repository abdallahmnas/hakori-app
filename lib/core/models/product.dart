class Product {
  final String id;
  final String name;
  final String subtitle;
  final String category;
  final double priceUsd;
  final double priceNgn;
  final double rating;
  final int reviewCount;
  final String purity;
  final String diamondClarity;
  final String imageUrl;
  final List<String> galleryImages;
  final String description;
  final bool inStock;
  final String archType; // 'Top 6', 'Bottom 6', 'Full 16', 'Single Cap'
  final List<String> metalOptions;
  final List<String> stoneOptions;
  final bool isFeatured;
  final bool isBestSeller;

  const Product({
    required this.id,
    required this.name,
    this.subtitle = 'Haute Joaillerie Dental Cap',
    required this.category,
    required this.priceUsd,
    required this.priceNgn,
    this.rating = 4.95,
    this.reviewCount = 48,
    this.purity = '18K Yellow Gold',
    this.diamondClarity = 'VVS1 Natural',
    required this.imageUrl,
    this.galleryImages = const [],
    required this.description,
    this.inStock = true,
    this.archType = 'Top 6 Arch',
    this.metalOptions = const ['18K Yellow Gold', '18K White Gold', '18K Rose Gold', '950 Platinum'],
    this.stoneOptions = const ['VVS1 Natural Diamonds', 'Flawless Moissanite', 'Emerald Inlay', 'Deep Cut Plain'],
    this.isFeatured = false,
    this.isBestSeller = false,
  });
}
