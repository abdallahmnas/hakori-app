/// Promotional Banner Model matching API /banners
class PromoBanner {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? link;
  final String? ctaText;
  final String placement;
  final bool isActive;
  final int order;
  final String? createdAt;

  const PromoBanner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.link,
    this.ctaText,
    this.placement = 'hero',
    this.isActive = true,
    this.order = 1,
    this.createdAt,
  });

  /// Normalizes relative imageUrls to absolute backend URLs
  String get fullImageUrl {
    if (imageUrl.isEmpty) {
      return 'https://images.unsplash.com/photo-1599643478518-a784e5dc4c8f?q=80&w=1200&auto=format&fit=crop';
    }
    if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
      return imageUrl;
    }
    if (imageUrl.startsWith('/')) {
      return 'https://hakori-service.onrender.com$imageUrl';
    }
    return 'https://hakori-service.onrender.com/$imageUrl';
  }

  factory PromoBanner.fromJson(Map<String, dynamic> json) {
    return PromoBanner(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      subtitle: json['subtitle']?.toString() ?? '',
      imageUrl: (json['imageUrl'] ?? json['image'])?.toString() ?? '',
      link: json['link']?.toString(),
      ctaText: json['ctaText']?.toString() ?? 'Explore Collection',
      placement: json['placement']?.toString() ?? 'hero',
      isActive: json['isActive'] as bool? ?? true,
      order: (json['order'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      if (link != null) 'link': link,
      if (ctaText != null) 'ctaText': ctaText,
      'placement': placement,
      'isActive': isActive,
      'order': order,
      if (createdAt != null) 'createdAt': createdAt,
    };
  }
}
