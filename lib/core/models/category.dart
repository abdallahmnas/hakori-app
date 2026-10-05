/// Category / Collection Model matching API_DOCUMENTATION.md
class Category {
  final String id;
  final String name;
  final String slug;
  final String description;
  final int pieceCount;
  final double startingPrice;
  final String imageUrl;

  const Category({
    required this.id,
    String? name,
    String? title,
    this.slug = '',
    String? description,
    String? subtitle,
    this.pieceCount = 0,
    double? startingPrice,
    double? startingPriceUsd,
    required this.imageUrl,
  })  : name = name ?? title ?? '',
        description = description ?? subtitle ?? '',
        startingPrice = startingPrice ?? startingPriceUsd ?? 0.0;

  // UI Backward Compatibility Getters
  String get title => name;
  String get subtitle => description;
  double get startingPriceUsd => startingPrice;

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawStartPrice = json['startingPrice'] ?? json['startingPriceUsd'] ?? json['avgCommission'] ?? 0;
    final double parsedPrice = (rawStartPrice is num)
        ? rawStartPrice.toDouble()
        : double.tryParse(rawStartPrice.toString()) ?? 0.0;

    final rawCount = json['productCount'] ?? json['productsCount'] ?? json['pieceCount'] ?? json['nodeCount'] ?? 0;
    final int parsedCount = (rawCount is num) ? rawCount.toInt() : int.tryParse(rawCount.toString()) ?? 0;

    final rawImage = json['imageUrl'] ?? json['bannerImage'] ?? json['image'];
    final String parsedImage = (rawImage != null && rawImage.toString().isNotEmpty)
        ? rawImage.toString()
        : 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1000&auto=format&fit=crop';

    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? json['subtitle']?.toString() ?? '',
      pieceCount: parsedCount,
      startingPrice: parsedPrice,
      imageUrl: parsedImage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'pieceCount': pieceCount,
      'startingPrice': startingPrice,
      'imageUrl': imageUrl,
    };
  }
}
