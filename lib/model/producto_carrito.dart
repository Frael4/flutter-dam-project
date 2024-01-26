import 'package:f_maps_firestore/model/plato.dart';

class ProductoCarrito {
  final Plato producto;
  final int cantidad;
  final double precioTotal;

  ProductoCarrito({
    required this.producto,
    required this.cantidad,
    required this.precioTotal,
  });
}
