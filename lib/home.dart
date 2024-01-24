import 'dart:developer';

import 'package:f_maps_firestore/login.dart';
import 'package:f_maps_firestore/model/usuario.dart';
import 'package:f_maps_firestore/store.dart';
import 'package:flutter/material.dart';

import 'map.dart';

class HomeScreen extends StatelessWidget {
  final String usuario;
  final String correo;

  const HomeScreen(
      {super.key,
      required this.usuario,
      required this.correo}); // Puedes cambiar esto por el nombre de tu usuario.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(Usuario.usuario),
              accountEmail: Text(Usuario.correo),
              currentAccountPicture: const CircleAvatar(
                backgroundImage:
                    AssetImage('assets/imagen_usuario.jpg'), // Imagen
              ),
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 17, 27, 54),
              ),
            ),
            /* const DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 243, 187, 33),
            ),
            child: Text('Menú'),
            
          ), */
            ListTile(
              title: const Text('Buscar Resurantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MapPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Productos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StorePage(),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Configuración'),
              onTap: () {
                // TODO
              },
            ),
            ListTile(
              title: const Text('Cerrar sesión'),
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LogIn(title: ''),
                  ),
                  (route) =>
                      false, // Elimina todas las rutas anteriores del historial de navegación
                );
              },
            ),
          ],
        ),
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
                log('Productos');
              },
              child: const Text('Productos'),
            ),
          ],
        ),
      ),
    );
  }
}
