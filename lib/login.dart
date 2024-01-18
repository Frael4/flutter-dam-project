import 'dart:async';
import 'package:f_maps_firestore/home.dart';
import 'package:f_maps_firestore/map.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import 'package:f_maps_firestore/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

const user = 'adm';
const pwd = '123';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Find Your Food",
      home: const LogIn(title: 'Maps Flutter 3'),
      theme: ThemeData(
        // This is the theme of your application.
        scaffoldBackgroundColor: const Color.fromARGB(135, 75, 73, 73),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        //textTheme: TextTheme(),
        useMaterial3: true,
      ),
    );
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
  bool existUser() {
    return userController.text == user && passwordController.text == pwd;
  }

// Logeo
  void logIn() {
    if (!isValid()) {
      showToast('action', '', 'Por favor llene los campos');
      return;
    }

    if (!existUser()) {
      showToast('action', '', 'Error en las credenciales de acceso');
    }

    if (existUser()) {
      showToast(
          'Iniciar Sesion',
          ' ${userController.text.trim()} pass: ${passwordController.text.trim()}',
          ' Acceso concedido');
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ));
      clearTexts();
    }
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
            padding: const EdgeInsets.all(20.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              controller: userController,
              decoration: const InputDecoration(labelText: 'User'),
              maxLength: 25,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
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
          ElevatedButton(onPressed: () {}, child: const Text('Registrarse')),
          ElevatedButton(
              onPressed: () {
                showToast('Salir');
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: const Text('Salir')
              ),
        ],
      ),
    );
  }
}