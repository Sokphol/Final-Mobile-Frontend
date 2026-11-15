class Product {
  const Product({
    required this.image,
    required this.name,
    required this.detail,
    required this.price,
    this.id,
    this.description =
        'Fresh, high-quality, and carefully selected produce. Packed with natural nutrients and great taste for you and your family.',
    this.category = 'Fresh Produce & Vegetables',
    this.nutritions = '100gr (~89 kcal)',
    this.rating = 4.8,
    this.reviewCount = 86,
  });

  final String image;
  final String name;
  final String detail;
  final String price;
  final String? id;
  final String description;
  final String category;
  final String nutritions;
  final double rating;
  final int reviewCount;

  String get productId =>
      id ?? name.replaceAll(RegExp(r'[\s\n]+'), '-').toLowerCase();

  double get priceValue {
    final cleaned = price.replaceAll(RegExp(r'[^0-9.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
