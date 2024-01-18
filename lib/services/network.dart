import 'dart:convert';
import 'package:f_maps_firestore/Product.dart';
import 'package:http/http.dart' as http;


Future<List<Product>> getProducts() async {

  final response = await http.get(Uri.parse('https://dummyjson.com/products'));

  if(response.statusCode == 200){

    final Map<String, dynamic> responseData = jsonDecode(response.body);
    final List<dynamic> products = responseData['products'];

    return products.map((p) => Product(title: p['title'], price: p['price'], description: p['description'], category: p['category'], images: (p['images'] as List).cast<String>(), brand: p['brand'], rating: p['rating'])).toList();
  }
  else {
    throw Exception("Error consultando productos");
  }
}