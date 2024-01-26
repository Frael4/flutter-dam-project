import 'package:f_maps_firestore/model/detalle_plato.dart';

class Plato {
  final String nombre;
  final String imagen;
  final double precio;
  final DetallePlato detalles;

  Plato(this.nombre, this.imagen, this.precio, this.detalles);
}
