class FakeStoreProduct {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String image;
  final double? rating;
  final int? ratingCount;

  FakeStoreProduct({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
    this.ratingCount,
  });

  factory FakeStoreProduct.fromJson(Map<String, dynamic> json) {
    final ratingObj = json['rating'];
    double? rate;
    int? count;
    if (ratingObj is Map) {
      final r = ratingObj['rate'];
      final c = ratingObj['count'];
      rate = r is num ? r.toDouble() : null;
      count = c is num ? c.toInt() : null;
    }
    return FakeStoreProduct(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      image: json['image'] as String? ?? '',
      rating: rate,
      ratingCount: count,
    );
  }
}
