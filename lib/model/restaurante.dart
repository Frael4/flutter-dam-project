import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:f_maps_firestore/model/detalle_plato.dart';
import 'package:f_maps_firestore/model/plato.dart';

class Restaurante {
  final String nombre;
  final String direccion;
  final String imagen;
  final List<Plato> platos;

  Restaurante(this.nombre, this.direccion, this.imagen, this.platos);

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
