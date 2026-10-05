/// Product Model supporting API_DOCUMENTATION.md and existing UI fields
class Product {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double price;
  final String currency;
  final double rating;
  final int reviewCount;
  final String purity;
  final String diamondClarity;
  final List<String> images;
  final String description;
  final bool inStock;
  final int stockQuantity;
  final String sku;
  final String archType; // 'Top 6', 'Bottom 6', 'Full 16', 'Single Cap'
  final List<String> metalOptions;
  final List<String> stoneOptions;
  final bool isFeatured;
  final bool isBestSeller;

  Product({
    required this.id,
    String? title,
    String? name,
    this.subtitle = 'Haute Joaillerie Dental Cap',
    required this.category,
    double? price,
    double? priceUsd,
    double? priceNgn,
    String? imageUrl,
    this.currency = 'USD',
    this.rating = 4.95,
    this.reviewCount = 48,
    this.purity = '18K Yellow Gold',
    this.diamondClarity = 'VVS1 Natural',
    List<String>? images,
    List<String>? galleryImages,
    required this.description,
    this.inStock = true,
    this.stockQuantity = 10,
    this.sku = '',
    this.archType = 'Top 6 Arch',
    this.metalOptions = const [
      '18K Yellow Gold',
      '18K White Gold',
      '18K Rose Gold',
      '950 Platinum'
    ],
    this.stoneOptions = const [
      'VVS1 Natural Diamonds',
      'Flawless Moissanite',
      'Emerald Inlay',
      'Deep Cut Plain'
    ],
    this.isFeatured = false,
    this.isBestSeller = false,
  })  : title = title ?? name ?? 'Haute Piece',
        price = price ?? priceUsd ?? 0.0,
        images = images ?? galleryImages ?? (imageUrl != null ? [imageUrl] : const []);

  // UI Backward Compatibility Getters
  String get name => title;
  double get priceUsd => price;
  double get priceNgn => price * 1550.0;
  String get imageUrl => images.isNotEmpty
      ? images.first
      : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop';
  List<String> get galleryImages => images;

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    List<String> parsedImages = [];
    if (rawImages is List && rawImages.isNotEmpty) {
      parsedImages = rawImages.map((e) => e.toString()).toList();
    } else if (json['imageUrl'] != null && json['imageUrl'].toString().isNotEmpty) {
      parsedImages = [json['imageUrl'].toString()];
    } else if (json['image'] != null && json['image'].toString().isNotEmpty) {
      parsedImages = [json['image'].toString()];
    }

    final rawPrice = json['price'] ?? json['priceUsd'] ?? 0;
    final double parsedPrice = (rawPrice is num) ? rawPrice.toDouble() : double.tryParse(rawPrice.toString()) ?? 0.0;

    final rawStock = json['stock'] ?? json['inventory'] ?? json['stockQuantity'];
    final int parsedStock = (rawStock is num) ? rawStock.toInt() : (json['inStock'] == false ? 0 : 10);

    final rawInStock = json['inStock'];
    final bool parsedInStock = (rawInStock is bool) ? rawInStock : (parsedStock > 0);

    return Product(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? json['name']?.toString() ?? 'Haute Piece',
      subtitle: json['subtitle']?.toString() ?? 'Haute Joaillerie Dental Cap',
      category: json['category']?.toString() ?? 'Haute Joaillerie',
      price: parsedPrice,
      currency: json['currency']?.toString() ?? 'USD',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.95,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 48,
      purity: json['purity']?.toString() ?? json['material']?.toString() ?? '18K Yellow Gold',
      diamondClarity: json['diamondClarity']?.toString() ?? 'VVS1 Natural',
      images: parsedImages,
      description: json['description']?.toString() ?? '',
      inStock: parsedInStock,
      stockQuantity: parsedStock,
      sku: json['sku']?.toString() ?? '',
      archType: json['archType']?.toString() ?? json['placement']?.toString() ?? 'Top 6 Arch',
      metalOptions: (json['metalOptions'] as List?)?.map((e) => e.toString()).toList() ??
          const ['18K Yellow Gold', '18K White Gold', '18K Rose Gold', '950 Platinum'],
      stoneOptions: (json['stoneOptions'] as List?)?.map((e) => e.toString()).toList() ??
          const ['VVS1 Natural Diamonds', 'Flawless Moissanite', 'Emerald Inlay', 'Deep Cut Plain'],
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'price': price,
      'currency': currency,
      'rating': rating,
      'reviewCount': reviewCount,
      'purity': purity,
      'diamondClarity': diamondClarity,
      'images': images,
      'description': description,
      'inStock': inStock,
      'stockQuantity': stockQuantity,
      'sku': sku,
      'archType': archType,
      'metalOptions': metalOptions,
      'stoneOptions': stoneOptions,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
    };
  }
}
