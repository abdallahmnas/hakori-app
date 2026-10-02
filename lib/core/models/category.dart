class Category {
  final String id;
  final String title;
  final String subtitle;
  final int pieceCount;
  final double startingPriceUsd;
  final String imageUrl;

  const Category({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.pieceCount,
    required this.startingPriceUsd,
    required this.imageUrl,
  });
}
