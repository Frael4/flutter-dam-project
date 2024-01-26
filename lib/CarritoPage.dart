import 'dart:developer';
import 'package:f_maps_firestore/model/producto_carrito.dart';
import 'package:flutter/material.dart';

class CarritoPage extends StatefulWidget {
  final List<ProductoCarrito> productos;

  const CarritoPage({super.key, required this.productos});

  @override
  _CarritoPageState createState() => _CarritoPageState();
}

class _CarritoPageState extends State<CarritoPage> {
  double getTotalCarrito() {
    return widget.productos
        .fold(0, (total, producto) => total + producto.precioTotal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrito de Compras'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            for (var producto in widget.productos)
              _buildProductoCarrito(producto),
            const SizedBox(height: 16.0),
            _buildTotalCarrito(),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                // Lógica para realizar la compra
                // Puedes implementar esto según tus necesidades
                log(
                    'Compra realizada. Total: \$${getTotalCarrito().toStringAsFixed(2)}');
              },
              child: const Text('Realizar compra'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductoCarrito(ProductoCarrito producto) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: _buildProductoImage(producto.producto.detalles.imagen),
        title: Text(producto.producto.nombre),
        subtitle: Text(
          'Cantidad: ${producto.cantidad}\nPrecio Total: \$${producto.precioTotal.toStringAsFixed(2)}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () {
            // Lógica para eliminar el producto del carrito
            // Puedes implementar esto según tus necesidades
            log(
                'Producto eliminado del carrito: ${producto.producto.nombre}');
            setState(() {
              widget.productos.remove(producto);
            });
          },
        ),
      ),
    );
  }

  Widget _buildProductoImage(String imageUrl) {
    return Container(
      height: 50.0,
      width: 50.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildTotalCarrito() {
    return Text(
      'Total del Carrito: \$${getTotalCarrito().toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
    );
  }
}
