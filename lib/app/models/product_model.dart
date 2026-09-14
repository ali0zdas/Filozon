class Product {
  final int id;
  final String title;
  final double price;
  final String description;
  final String category;
  final String? image;
  final double? rating;
  final int? ratingCount;

  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    this.rating,
    this.ratingCount,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      title: json['title'],
      price: (json['price'] as num).toDouble(),
      description: json['description'],
      category: json['category'],
      image: json['image'],
      rating: json['rating'] != null ? (json['rating']['rate'] as num?)?.toDouble() : null,
      ratingCount: json['rating'] != null ? json['rating']['count'] as int? : null,
    );
  }
}
