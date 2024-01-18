class Product {
  final String title;
  final dynamic price;
  final String description;
  final List<String> images;
  final String brand;
  final String category;
  final dynamic rating;

  Product(
      {required this.title,
      required this.price,
      required this.description,
      required this.category,
      required this.images,
      required this.brand,
      required this.rating});
}
