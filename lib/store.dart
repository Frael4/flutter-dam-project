import 'package:f_maps_firestore/product.dart';
//import 'package:webfeed/webfeed.dart';
import 'services/network.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StatefulWidget> createState() {
    return StorePageState();
  }
}


class StorePageState extends State<StorePage> {

  Future<List<Product_>>? future;

  @override
  void initState() {
    super.initState();
    future = getProducts();
    getProducts().then((value) => print('Tamaño: es ${value.length}'));
    //listenSensor();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Lista de Productos"),
        ),
        body: _body());
  }

 Widget _body() {
  return FutureBuilder<List<Product_>>(
    future: getProducts(),
    builder: (BuildContext context, AsyncSnapshot<List<Product_>> snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Si el Future aún está en proceso, mostrar un indicador de carga
        return const Center(child: CircularProgressIndicator());
      } else 
      if (snapshot.hasData) {
        // Si hay datos disponibles, construir la lista
        final products = snapshot.data;
        return ListView.builder(
          itemCount: products!.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return Card(
              /* color: const Color.fromARGB(255, 246, 246, 247), */
              child: ListTile(
                leading: SizedBox(
                  width: 50,
                  height: 60,
                  child: Image.network(product.images),
                ),
                title: Text(product.title, /* style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold), */),
                subtitle: Text(product.price.toString()),
              ),
            );
          },
        );
      } else if (snapshot.hasError) {
        // Si hay un error, mostrar un mensaje de error en el centro
        return Center(
          child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.white)),
        );
      } else {
        // Caso por defecto: Si no hay datos ni error, mostrar algo neutral
        return const Center(
          child:  Text("No hay datos disponibles."),
        );
      }
    },
  );
}


  /* Widget _bigItem() {
    var screenWidth = MediaQuery.of(context).size.width;

    return Stack(
      alignment: Alignment.center,
      children: <Widget>[
        Container(
          width: double.infinity,
          height: (screenWidth - 64.0) * 3.0 / 5.0,
          decoration: BoxDecoration(
              image: const DecorationImage(
                image: NetworkImage(
                    'https://www.elcomercio.com/wp-content/uploads/2021/06/logo-el-comercio.jpg'),
              ),
              borderRadius: BorderRadius.circular(30.0)),
        )
      ],
    );
  }

  Widget _item(RssItem item) {
    return Card(
      color: Colors.blueGrey.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      elevation: 3,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: <Widget>[
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.categories!.first.value,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16.0),
                ),
                Text(item.title!),
                Text('Autor: ${item.author}'),
              ],
            )),
            Container(
              width: 120.0,
              height: 120.0,
              child: Image(
                image: NetworkImage(item.enclosure?.url ??
                    'https://i.blogs.es/d5130c/wallpaper-2.png/1366_2000.jpeg'),
                fit: BoxFit.cover,
              ),
            )
          ],
        ),
      ),
    );
  }
 */
}
