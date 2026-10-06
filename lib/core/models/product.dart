/// Product Model supporting API_DOCUMENTATION.md and active backend payload:
/// {
///   "id": "245eaddc-97d8-461b-95e9-6366056fc71d",
///   "name": "leshi",
///   "sku": "vvv",
///   "category": "necklace",
///   "price": 46,
///   "costPrice": 22,
///   "castingPrice": 46,
///   "stock": 67,
///   "description": "cccc",
///   "imageUrl": "https://...",
///   "images": ["https://..."],
///   "material": "18K Solid Yellow Gold",
///   "placement": "Fine Product",
///   "rating": 5,
///   "inStock": true,
///   "status": "Active",
///   "createdAt": "2026-10-03T12:56:50.445Z",
///   "updatedAt": "2026-10-03T12:56:50.445Z",
///   "inventory": 67,
///   "image": "https://...",
///   "lowStock": false
/// }
class Product {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final double price;
  final double costPrice;
  final double castingPrice;
  final String currency;
  final double rating;
  final int reviewCount;
  final String material;
  final String placement;
  final String diamondClarity;
  final List<String> images;
  final String description;
  final bool inStock;
  final bool lowStock;
  final int stock;
  final int inventory;
  final String sku;
  final String status;
  final String createdAt;
  final String updatedAt;
  final List<String> metalOptions;
  final List<String> stoneOptions;
  final bool isFeatured;
  final bool isBestSeller;

  Product({
    required this.id,
    String? title,
    String? name,
    this.subtitle = 'Haute Joaillerie Atelier Piece',
    required this.category,
    double? price,
    double? priceUsd,
    double? priceNgn,
    double? costPrice,
    double? castingPrice,
    String? imageUrl,
    this.currency = 'USD',
    this.rating = 5.0,
    this.reviewCount = 1,
    String? material,
    String? purity,
    String? placement,
    String? archType,
    this.diamondClarity = 'VVS1 Natural',
    List<String>? images,
    List<String>? galleryImages,
    required this.description,
    this.inStock = true,
    this.lowStock = false,
    int? stock,
    int? inventory,
    int? stockQuantity,
    this.sku = '',
    this.status = 'Active',
    this.createdAt = '',
    this.updatedAt = '',
    this.metalOptions = const [],
    this.stoneOptions = const [],
    this.isFeatured = false,
    this.isBestSeller = false,
  })  : title = (name != null && name.isNotEmpty) ? name : (title ?? 'Bespoke Atelier Piece'),
        price = price ?? priceUsd ?? 0.0,
        costPrice = costPrice ?? 0.0,
        castingPrice = castingPrice ?? 0.0,
        material = (material != null && material.isNotEmpty)
            ? material
            : (purity != null && purity.isNotEmpty ? purity : '18K Solid Yellow Gold'),
        placement = (placement != null && placement.isNotEmpty)
            ? placement
            : (archType != null && archType.isNotEmpty ? archType : 'Fine Product'),
        stock = stock ?? inventory ?? stockQuantity ?? 1,
        inventory = inventory ?? stock ?? stockQuantity ?? 1,
        images = (images != null && images.isNotEmpty)
            ? images
            : (galleryImages != null && galleryImages.isNotEmpty
                ? galleryImages
                : (imageUrl != null && imageUrl.isNotEmpty ? [imageUrl] : const []));

  // UI Backward Compatibility Getters
  String get name => title;
  String get purity => material;
  String get archType => placement;
  int get stockQuantity => stock;
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

    final rawCostPrice = json['costPrice'] ?? 0;
    final double parsedCostPrice = (rawCostPrice is num) ? rawCostPrice.toDouble() : double.tryParse(rawCostPrice.toString()) ?? 0.0;

    final rawCastingPrice = json['castingPrice'] ?? 0;
    final double parsedCastingPrice = (rawCastingPrice is num) ? rawCastingPrice.toDouble() : double.tryParse(rawCastingPrice.toString()) ?? 0.0;

    final rawStock = json['stock'] ?? json['inventory'] ?? json['stockQuantity'];
    final int parsedStock = (rawStock is num) ? rawStock.toInt() : (int.tryParse(rawStock?.toString() ?? '') ?? 0);

    final rawInStock = json['inStock'];
    final bool parsedInStock = (rawInStock is bool) ? rawInStock : (parsedStock > 0);

    final rawLowStock = json['lowStock'];
    final bool parsedLowStock = (rawLowStock is bool) ? rawLowStock : false;

    // Parse options only if explicitly provided in backend
    List<String> parsedMetalOptions = [];
    if (json['metalOptions'] is List && (json['metalOptions'] as List).isNotEmpty) {
      parsedMetalOptions = (json['metalOptions'] as List).map((e) => e.toString()).toList();
    }

    List<String> parsedStoneOptions = [];
    if (json['stoneOptions'] is List && (json['stoneOptions'] as List).isNotEmpty) {
      parsedStoneOptions = (json['stoneOptions'] as List).map((e) => e.toString()).toList();
    }

    return Product(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? 'Bespoke Atelier Piece',
      subtitle: json['subtitle']?.toString() ?? 'Haute Joaillerie Atelier Piece',
      category: json['category']?.toString() ?? 'Jewelry',
      price: parsedPrice,
      costPrice: parsedCostPrice,
      castingPrice: parsedCastingPrice,
      currency: json['currency']?.toString() ?? 'USD',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 1,
      material: json['material']?.toString() ?? json['purity']?.toString() ?? '18K Solid Yellow Gold',
      placement: json['placement']?.toString() ?? json['archType']?.toString() ?? 'Fine Product',
      diamondClarity: json['diamondClarity']?.toString() ?? 'VVS1 Natural',
      images: parsedImages,
      description: json['description']?.toString() ?? '',
      inStock: parsedInStock,
      lowStock: parsedLowStock,
      stock: parsedStock,
      inventory: parsedStock,
      sku: json['sku']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      createdAt: json['createdAt']?.toString() ?? '',
      updatedAt: json['updatedAt']?.toString() ?? '',
      metalOptions: parsedMetalOptions,
      stoneOptions: parsedStoneOptions,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isBestSeller: json['isBestSeller'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'title': title,
      'subtitle': subtitle,
      'category': category,
      'sku': sku,
      'price': price,
      'costPrice': costPrice,
      'castingPrice': castingPrice,
      'stock': stock,
      'inventory': inventory,
      'description': description,
      'imageUrl': imageUrl,
      'images': images,
      'material': material,
      'placement': placement,
      'rating': rating,
      'inStock': inStock,
      'lowStock': lowStock,
      'status': status,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'currency': currency,
      'diamondClarity': diamondClarity,
      'metalOptions': metalOptions,
      'stoneOptions': stoneOptions,
      'isFeatured': isFeatured,
      'isBestSeller': isBestSeller,
    };
  }
}
