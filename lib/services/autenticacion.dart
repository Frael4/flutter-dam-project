import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_maps_firestore/model/usuario.dart';
//import 'package:f_maps_firestore/model/usuario.dart';

Future<DocumentSnapshot?> iniciarSesion(String user, String contrasenia) async {
  //Obtenemos la coleccion
  CollectionReference usuarios =
      FirebaseFirestore.instance.collection('usuario');
  
  //Filtramos por usuario y contrasenia
  QuerySnapshot querySnapshot = await usuarios
      .where('usuario', isEqualTo: user)
      .where('contrasenia', isEqualTo: contrasenia)
      .get();

  DocumentSnapshot? documento;
  
  //Verificamos si hay documentos
  if (querySnapshot.docs.isNotEmpty) {
    documento = querySnapshot.docs.first;

    // Accede a los datos del documento
    Object? datos = documento.data();
    //String nombres = documento.get('nombres');
    String correo = documento.get('correo');
    String usuario = documento.get('usuario');

    Usuario.usuario = usuario;
    Usuario.correo = correo;
    
    log(datos.toString());
  }

  return documento;
}
