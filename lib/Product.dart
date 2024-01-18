// ignore: file_names
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

class Product_ {
  final String title;
  final String price;
  final String images;

  Product_({required this.title, required this.price, required this.images});

  factory Product_.fromJson(Map<String, dynamic> json) {
    return Product_(
      title: json['title'],
      price: json['price'],
      images: json['images']
    );
  }
}
