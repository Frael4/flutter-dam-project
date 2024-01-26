import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_maps_firestore/model/restaurante.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
import 'CarritoPage.dart';
import 'PlatosRestaurantePage.dart';

class RestaurantesPage extends StatelessWidget {
  const RestaurantesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurantes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CarritoPage(
                      productos: [], // Asegúrate de pasar un producto válido aquí
                    ),
                  ));
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: getRestaurantes(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ...snapshot.data as List<Widget>,
                  const SizedBox(height: 20.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Ir a la página de inicio'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Future<List<Widget>> getRestaurantes(BuildContext context) async {
    try {
      CollectionReference restaurantes =
          FirebaseFirestore.instance.collection('restaurantes');

      QuerySnapshot querySnapshot = await restaurantes.get();

      List<Restaurante> restaurantesList = querySnapshot.docs
          .map((restauranteElement) =>
              Restaurante.fromSnapshot(restauranteElement))
          .toList();

      return restaurantesList
          .map((restaurante) => _buildRestauranteCard(context, restaurante))
          .toList();
      
    } catch (e) {
      log('Error: $e');
      return [];
    }

  }

  Widget _buildRestauranteCard(BuildContext context, Restaurante restaurante) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: () => _onRestauranteTap(context, restaurante),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              restaurante.imagen,
              fit: BoxFit.cover,
              height: 200.0,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurante.nombre,
                    style: const TextStyle(
                        fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'Dirección: ${restaurante.direccion}',
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRestauranteTap(BuildContext context, Restaurante restaurante) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlatosRestaurantePage(restaurante.platos),
      ),
    );
  }
}
