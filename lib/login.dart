import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_maps_firestore/directions_provider.dart';
import 'package:f_maps_firestore/home.dart';
import 'package:f_maps_firestore/services/autenticacion.dart';
import 'package:f_maps_firestore/signup.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:f_maps_firestore/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => DirectionProvider(),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Find Your Food",
          home: const LogIn(title: 'Maps Flutter 3'),
          theme: ThemeData.dark(),
        ));
  }
}

class LogIn extends StatefulWidget {
  const LogIn({required this.title, super.key});
  final String title;

  @override
  State<StatefulWidget> createState() {
    return LogInState();
  }
}

///  Manejador de los estados de mi clase
class LogInState extends State<LogIn> {
  late TextEditingController userController;
  late TextEditingController passwordController;

  //Estado Inicio
  @override
  void initState() {
    super.initState();

    userController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    ToastContext().init(context);

    return Scaffold(body: formLogIn());
  }

//Muestra mensajes
  void showToast(String action, [data = '', String message = '']) {
    if (action == 'Iniciar Sesion') {
      message += '$message $data';
    }
    if (action == 'Salir') {
      message = 'Ha salido del sistema';
    }

    Toast.show(message, duration: Toast.lengthLong, gravity: Toast.bottom);
  }

// Valida Campos vacios
  bool isValid() {
    return userController.text.isNotEmpty && passwordController.text.isNotEmpty;
  }

// Limpia campos
  void clearTexts() {
    userController.text = '';
    passwordController.text = '';
  }

// Verifica usuario existe
  /* bool existUser() {
    return userController.text == user && passwordController.text == pwd;
  } */

// Logeo
  void logIn() async {
    DocumentSnapshot? datos =
        await iniciarSesion(userController.text, passwordController.text);
    String user = '', correo = '';

    if (datos != null) {
      user = datos.get('usuario');
      correo = datos.get('correo');

      log(user);
    } else {
      showToast('action', '', 'Usuario no existe');
      return;
    }

    if (!isValid()) {
      showToast('action', '', 'Por favor llene los campos');
      return;
    }

    /* if (!existUser()) {
      showToast('action', '', 'Error en las credenciales de acceso');
    } */

    /* if (existUser()) { */
    showToast(
        'Iniciar Sesion',
        ' ${userController.text.trim()} pass: ${passwordController.text.trim()}',
        ' Acceso concedido');
    // ignore: use_build_context_synchronously
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            usuario: user,
            correo: correo,
          ),
        ));
    clearTexts();
    /* } */
  }

  Widget formLogIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Log In',
              style: TextStyle(
                  color: Colors.amber, fontSize: 50, fontFamily: 'bold')),
          /* Image(image: ImageProvider), */
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 50.0, right: 50.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: userController,
              decoration: const InputDecoration(labelText: 'User'),
              maxLength: 25,
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(bottom: 20.0, left: 50.0, right: 50.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              maxLength: 20,
              obscureText: true,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(onPressed: logIn, child: const Text('Iniciar Sesion')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen()
                    ));
              },
              child: const Text('Registrarse')),
          /* ElevatedButton(
              onPressed: () {
                showToast('Salir');
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Salir')
              ), */
        ],
      ),
    );
  }
}
