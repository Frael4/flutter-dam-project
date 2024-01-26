import 'package:f_maps_firestore/model/plato.dart';
import 'package:flutter/material.dart';
import 'detalleplatopage.dart';

class PlatosRestaurantePage extends StatelessWidget {
  final List<Plato> platos;

  const PlatosRestaurantePage(this.platos, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Platos del Restaurante'),
      ),
      body: ListView.builder(
        itemCount: platos.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () => _onPlatoTap(context, platos[index]),
            child: _buildPlatoCard(platos[index]),
          );
        },
      ),
    );
  }

  Widget _buildPlatoCard(Plato plato) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Image.network(
            plato.imagen,
            fit: BoxFit.cover,
            height: 200.0,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plato.nombre,
                  style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                Text(
                  'Precio: \$${plato.precio.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onPlatoTap(BuildContext context, Plato plato) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetallePlatoPage(plato),
      ),
    );
  }
}
