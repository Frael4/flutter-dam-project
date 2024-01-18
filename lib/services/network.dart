import 'dart:convert';
//import 'dart:ui';
import 'package:f_maps_firestore/product.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
//import 'dart:io';

Future<List<Product>> getProducts_() async {

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


Future<List<Product_>> getProducts() async {
  
  String jsonString = await rootBundle.loadString('assets/productlist.json');

  
  List<dynamic> productsJson = jsonDecode(jsonString);
  List<Product_> products = productsJson.map((json) => Product_.fromJson(json)).toList();

  return products;
}

/* Future<List<Product_>> getProducts() async {
  try {
    // Obtener la ruta del archivo JSON local
    String path = Path.from("") 'productlist.json'; // Reemplaza con la ruta correcta
    File file = File(path);

    // Leer el contenido del archivo
    String jsonString = await file.readAsString();

    // Decodificar el JSON y convertirlo en una lista de productos
    List<dynamic> productsJson = jsonDecode(jsonString);
    List<Product_> products = productsJson.map((json) => Product_.fromJson(json)).toList();

    return products;
  } catch (e) {
    print("Error al leer el archivo JSON local: $e");
    return [];
  }
} */