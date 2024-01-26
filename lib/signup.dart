import 'dart:developer';

import 'package:f_maps_firestore/login.dart';
import 'package:f_maps_firestore/model/usuario.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Registro de Usuario'),
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'Nombres'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(labelText: 'Apellidos'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(labelText: 'Edad'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _emailController,
                    decoration:
                        const InputDecoration(labelText: 'Correo Electrónico'),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _userController,
                    decoration: const InputDecoration(labelText: 'Usuario'),
                  ),
                  const SizedBox(height: 16.0),
                  TextField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () {
                      _registerUser(context);
                    },
                    child: const Text('Registrar'),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  void limpiarTexts() {
    _userController.text = '';
    _firstNameController.text = '';
    _passwordController.text = '';
    _lastNameController.text = '';
    _ageController.text = '';
    _emailController.text = '';
  }

  void _registerUser(BuildContext context) async {
    String usuario = _userController.text.trim();
    String nombre = _firstNameController.text.trim();
    String apellido = _lastNameController.text.trim();
    int edad = int.tryParse(_ageController.text) ?? 0;
    String correo = _emailController.text.trim();
    String contasenia = _passwordController.text.trim();

    try {
      // Referencia a la colección
      CollectionReference users =
          FirebaseFirestore.instance.collection('usuario');
      final Usuario newUsuario = Usuario(
          nombre: nombre,
          edad: edad,
          correo: correo,
          usuario: usuario,
          apellidos: apellido,
          contrasenia: contasenia);
      // Añadir datos a la colección
      users.add(newUsuario.toMap()).then((value) {
        log('Datos agregados con éxito. Documento ID: ${value.id}');
      }).catchError((error) {
        log('Error al agregar datos: $error');
      });

      limpiarTexts();
      // Redirige a la pantalla de perfil del usuario después del registro
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const LogIn(
                  title: '',
                )),
      );
    } catch (e) {
      log('Error al registrar al usuario: $e');
      // Puedes mostrar un mensaje de error al usuario si el registro falla
    }
  }
}
