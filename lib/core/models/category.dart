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
    final rawStartPrice = json['startingPrice'] ?? json['startingPriceUsd'] ?? 0;
    final double parsedPrice = (rawStartPrice is num)
        ? rawStartPrice.toDouble()
        : double.tryParse(rawStartPrice.toString()) ?? 0.0;

    return Category(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? json['subtitle']?.toString() ?? '',
      pieceCount: (json['pieceCount'] as num?)?.toInt() ?? 0,
      startingPrice: parsedPrice,
      imageUrl: json['imageUrl']?.toString() ?? '',
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
