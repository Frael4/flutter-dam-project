import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart' show rootBundle;
import 'CarritoPage.dart';
import 'PlatosRestaurantePage.dart';
import 'package:xml/xml.dart' as xml;

class Plato {
  final String nombre;
  final String imagen;
  final double precio;
  final DetallePlato detalles;

  Plato(this.nombre, this.imagen, this.precio, this.detalles);
}

class DetallePlato {
  final String nombre;
  final String descripcion;
  final String imagen;
  final double precio;

  DetallePlato(this.nombre, this.descripcion, this.imagen, this.precio);
}

class Restaurante {
  final String nombre;
  final String direccion;
  final String imagen;
  final List<Plato> platos;

  Restaurante(this.nombre, this.direccion, this.imagen, this.platos);

  factory Restaurante.fromXml(xml.XmlElement element) {
    String nombre = element.findElements('nombre').single.text;
    String direccion = element.findElements('direccion').single.text;
    String imagen = element.findElements('imagen').single.text;

    List<Plato> platos = element
        .findElements('platos')
        .single
        .findElements('plato')
        .map((platoElement) {
      String nombrePlato = platoElement.findElements('nombre').single.text;
      String imagenPlato = platoElement.findElements('imagen').single.text;
      double precioPlato =
          double.parse(platoElement.findElements('precio').single.text);

      // Detalles del plato
      xml.XmlElement detallesElement =
          platoElement.findElements('detalles').single;
      String nombreDetalle = detallesElement.findElements('nombre').single.text;
      String descripcionDetalle =
          detallesElement.findElements('descripcion').single.text;
      String imagenDetalle = detallesElement.findElements('imagen').single.text;
      double precioDetalle =
          double.parse(detallesElement.findElements('precio').single.text);

      DetallePlato detalles = DetallePlato(
          nombreDetalle, descripcionDetalle, imagenDetalle, precioDetalle);

      return Plato(nombrePlato, imagenPlato, precioPlato, detalles);
    }).toList();

    return Restaurante(nombre, direccion, imagen, platos);
  }

  factory Restaurante.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    List<dynamic> platos = data['platos'] as List<dynamic>;
    //DocumentSnapshot platos = data['platos'] as DocumentSnapshot;
    //log(platos.toString());
    List<Plato> pla = platos.map((e) {
      String nombrePlato = e['nombre'];
      String imagenPlato = e['imagen'];
      double precioPlato = double.parse(e['precio']);

      Map<String, dynamic> details = e['detalles'] as Map<String, dynamic>;

      DetallePlato detalle = DetallePlato(
          details['nombre'],
          details['descripcion'],
          details['imagen'],
          double.parse(details['precio']));

      return Plato(nombrePlato, imagenPlato, precioPlato, detalle);
    }).toList();

    return Restaurante(doc['nombre'], doc['direccion'], doc['imagen'], pla);
  }
}

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
