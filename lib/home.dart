import 'package:f_maps_firestore/store.dart';
import 'package:flutter/material.dart';

import 'map.dart';

class HomeScreen extends StatelessWidget {
  final String usuario =
      "Adm"; // Puedes cambiar esto por el nombre de tu usuario.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Usuario: $usuario',
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const MapPage(),
                    ));
              },
              child: const Text('Buscar'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const StorePage(),
                    ));
                print('Productos');
              },
              child: const Text('Productos'),
            ),
          ],
        ),
      ),
    );
  }
}
