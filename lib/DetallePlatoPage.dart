import 'package:flutter/material.dart';
import 'Restaurantes_page.dart';
import 'CarritoPage.dart'; // Asegúrate de importar CarritoPage

class DetallePlatoPage extends StatefulWidget {
  final Plato plato;

  const DetallePlatoPage(this.plato, {super.key});

  @override
  _DetallePlatoPageState createState() => _DetallePlatoPageState();
}

class _DetallePlatoPageState extends State<DetallePlatoPage> {
  int cantidad = 1; // Inicializar la cantidad en 1

  double getTotalPrice() {
    return widget.plato.detalles.precio * cantidad;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Plato'),
      ),
      body: SingleChildScrollView(
        child: Container(
          color: const Color.fromARGB(255, 226, 223, 223), // Fondo blanco
          padding:const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildImage(widget.plato.detalles.imagen),
              const SizedBox(height: 16.0),
              _buildDetails(widget.plato.detalles),
              const SizedBox(height: 16.0),
              _buildAddToCartButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return Container(
      height: 200.0,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetails(DetallePlato detalles) {
    return Container(
      
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: const Color.fromARGB(255, 39, 37, 37)), // Fondo blanco),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitle(detalles.nombre),
          const SizedBox(height: 8.0),
          _buildDescription(detalles.descripcion),
          const SizedBox(height: 8.0),
          _buildPrice(),
          const SizedBox(height: 8.0),
          _buildQuantitySelector(),
          const SizedBox(height: 8.0),
          _buildTotalPrice(),
        ],
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      'Descripción: $description',
      style: const TextStyle(fontSize: 18.0),
    );
  }

  Widget _buildPrice() {
    return Text(
      'Precio: \$${widget.plato.detalles.precio.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18.0),
    );
  }

  Widget _buildQuantitySelector() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: () {
            if (cantidad > 1) {
              setState(() {
                cantidad--;
              });
            }
          },
        ),
        Text(
          '$cantidad',
          style: const TextStyle(fontSize: 18.0),
        ),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            setState(() {
              cantidad++;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAddToCartButton() {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CarritoPage(
              productos: [
                ProductoCarrito(
                  producto: widget.plato,
                  cantidad: cantidad,
                  precioTotal: getTotalPrice(),
                ),
              ],
            ),
          ),
        );
      },
      child: const Text('Agregar al carrito'),
    );
  }

  Widget _buildTotalPrice() {
    double totalPrice = getTotalPrice();
    return Text(
      'Precio total: \$${totalPrice.toStringAsFixed(2)}',
      style: const TextStyle(fontSize: 18.0),
    );
  }
}
