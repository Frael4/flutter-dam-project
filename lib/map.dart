import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:f_maps_firestore/directions_provider.dart';
import 'package:flutter/material.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as location;
import 'package:http/http.dart' as http;
import 'api_key.dart';
import 'package:provider/provider.dart';

// Center of the Google Map
//const initialPosition = LatLng(37.7786, -122.4375);
location.Location initialPosition = location.Location();
//var currentPosition; //= const LatLng(0, 0);

// Hue used by the Google Map Markers to match the theme
const hue = 350.0;
// Places API client used for Place Photos
final _placesApiClient = GoogleMapsPlaces(apiKey: googleMapsApiKey);

class MapPage extends StatefulWidget {
  /* const MapPage({required this.title, super.key}); */
  const MapPage({super.key});
  /* final String title; */

  @override
  State<StatefulWidget> createState() {
    return _MapPageState();
  }
}

class _MapPageState extends State<MapPage> {
  //late Stream<QuerySnapshot> _iceCreamStores;
  final Completer<GoogleMapController> googleMapController = Completer();
  // ignore: prefer_typing_uninitialized_variables
  var currentPosition;
  final String placesBaseUrl =
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json';
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Set<Marker> markers = {};
  List<dynamic> restaurants = [];

  @override
  void initState() {
    super.initState();

    _initializeLocation();

    getNearbyRestaurants();

    /* _iceCreamStores = FirebaseFirestore.instance
        .collection('ice_cream_stores')
        .orderBy('name')
        .snapshots(); */
  }

  Future<void> _initializeLocation() async {
    log("Primer mensaje");
    LatLng? userLocation = await getLocation();

    if (userLocation != null) {
      log("userLocation no es nulo");
      setState(() {
        currentPosition = userLocation;
      });
    } else {
      log("userLocation es nulo");
    }
  }

  //Obtener los permisos de localizacion
  // Y la localizacion del usuario
  Future<LatLng?> getLocation() async {
    try {
      bool permission = await initialPosition.serviceEnabled();

      if (!permission) {
        permission = await initialPosition.requestService();
        if (!permission) {
          log("El usuario no habilito el servicio");
          //return Error("e");
          return null;
        }
      }

      location.PermissionStatus status = await initialPosition.hasPermission();

      if (status == location.PermissionStatus.denied) {
        status = await initialPosition.requestPermission();
        if (status != location.PermissionStatus.granted) {
          log("El usuario no habilito los permisos de ubicacion");
          return null;
        }
      }

      var userLocation = await initialPosition.getLocation();

      log(userLocation.longitude.toString());
      log(userLocation.latitude.toString());

      return LatLng(userLocation.latitude!, userLocation.longitude!);
      //LatLng(-2.0663351,-79.9295041);
    } catch (e) {
      log("Error getting location: $e");
      return const LatLng(0, 0);
    }
  }

  Future<void> getNearbyRestaurants() async {
    LatLng? loc = await getLocation();

    if (loc != null) {
      log("Loc no es nulo");

      final response = await http.get(Uri.parse(
          '$placesBaseUrl?location=${loc.latitude},${loc.longitude}&radius=1500&type=restaurant&key=$googleMapsApiKey'));

      log(response.statusCode.toString());
      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        setState(() {
          currentPosition = loc;
          restaurants = data['results'];
          markers = Set.from(
            restaurants.map((restaurant) => Marker(
                markerId: MarkerId(restaurant['place_id']),
                position: LatLng(
                  restaurant['geometry']['location']['lat'],
                  restaurant['geometry']['location']['lng'],
                ),
                infoWindow: InfoWindow(
                  title: restaurant['name'],
                  snippet: restaurant['vicinity'],
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(hue),
                onTap: () {
                  log('Mostrando sheet');
                  scaffoldKey.currentState!
                      .showBottomSheet((context) => Container(
                            height: 500,
                            color: Colors.transparent,
                            child: getBottomSheet(restaurant),
                          ));
                })),
          );
        });
      } else {
        throw Exception('Failed to load restaurants');
      }
    }
  }

  Future<PlacesDetailsResponse> getDetailsRestaurant(dynamic restaurant) async {
    //log(restaurant.toString());
    PlacesDetailsResponse details = await _placesApiClient
        .getDetailsByPlaceId(restaurant['place_id'] as String);

    log("entra aqui");
    //log(details.toString());

    return details;
  }

  searchRoute(dynamic restaurant) async {
    log('On pressed');
    var to = LatLng(restaurant['geometry']['location']['lat'] as double,
        restaurant['geometry']['location']['lng'] as double);

    LatLng from = currentPosition;

    var api = Provider.of<DirectionProvider>(context, listen: false);

    log("buscando direcciones");
    await api.findDirections(from, to);

    var left = math.min(from.latitude, to.latitude);
    var right = math.max(from.latitude, to.latitude);
    var top = math.max(from.longitude, to.longitude);
    var bottom = math.min(from.longitude, to.longitude);

    for (var point in api.currentRuta.first.points) {
      left = math.min(left, point.latitude);
      right = math.max(right, point.latitude);
      top = math.max(top, point.longitude);
      bottom = math.min(bottom, point.longitude);
    }

    var bounds = LatLngBounds(
      southwest: LatLng(left, bottom),
      northeast: LatLng(right, top),
    );

    // Ajustamos la posicion de la camara
    var cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    final controller = await googleMapController.future;
    controller.animateCamera(cameraUpdate);
  }

  Widget getBottomSheet(dynamic restaurant) {
    var isOpen = restaurant?['opening_hours']?['open_now'];
    String estado = "";
    if (isOpen != null) {
      estado = isOpen ? 'Abierto' : 'Cerrado';
    } else {
      estado = "Cerrado";
    }
    //PlacesDetailsResponse details = getDetailsRestaurant(restaurant);

    return FutureBuilder<PlacesDetailsResponse>(
        future: getDetailsRestaurant(restaurant),
        builder: (BuildContext context,
            AsyncSnapshot<PlacesDetailsResponse> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Si el Future aún está en proceso, mostrar un indicador de carga
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // Si hay un error, mostrar un mensaje de error en el centro
            log(snapshot.stackTrace.toString());
            log(snapshot.error.toString());
            return Center(
              child: Text("Error: ${snapshot.error}",
                  style: const TextStyle(color: Colors.white)),
            );
          } else if (snapshot.hasData) {
            var data = snapshot.data!.result;
            var number = data.formattedPhoneNumber ?? 'Sin numero';
            var photoUrl = _placesApiClient.buildPhotoUrl(
              photoReference: data.photos[0].photoReference,
              maxHeight: 350);

            return Stack(
              children: <Widget>[
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          photoUrl,
                          width: double.infinity,
                          height: 200.0,
                          fit: BoxFit.cover,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            } else {
                              return Center(
                                child: CircularProgressIndicator(
                                  value: loadingProgress.expectedTotalBytes !=
                                          null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          (loadingProgress.expectedTotalBytes ??
                                              1)
                                      : null,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      Container(
                        color: const Color.fromARGB(255, 32, 50, 80),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                restaurant['name'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 5),
                              Row(
                                children: <Widget>[
                                  Text(restaurant['rating'].toString(),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                  const Icon(Icons.star, color: Colors.yellow),
                                  const SizedBox(width: 20),
                                  const Text("970 Followers",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 14)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Text(restaurant['vicinity'],
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 20),
                          const Icon(Icons.access_time, color: Colors.blue),
                          const SizedBox(width: 20),
                          Text(
                            estado,
                            style: const TextStyle(
                                color: Color.fromARGB(255, 5, 5, 5),
                                fontSize: 14),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: <Widget>[
                          const SizedBox(width: 20),
                          const Icon(Icons.call, color: Colors.blue),
                          const SizedBox(width: 20),
                          Text(number,
                              style: const TextStyle(color: Colors.black)),
                        ],
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.topRight,
                    child: FloatingActionButton(
                        onPressed: () => searchRoute(restaurant),
                        child: const Icon(Icons.navigation)),
                  ),
                )
              ],
            );
          } else {
            // Caso por defecto: Si no hay datos ni error, mostrar algo neutral
            return const Center(
              child: Text("No hay datos disponibles."),
            );
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text('Ubicacion'), //Text(widget.title),
        ),
        body: /*StreamBuilder<QuerySnapshot>(
        stream: _iceCreamStores,
        builder:  (context, snapshot) {
          return switch (snapshot) {
            AsyncSnapshot(hasError: true) => Center(
                  child: Text(
                'Error: ${snapshot.error}',
                //style: const TextStyle(color: Colors.white),
              )),
            AsyncSnapshot(hasData: false) =>
              const Center(child: Text('Loading ...')),
            _ => */
            Stack(
          children: [
            StoreMap(
              /* documents: snapshot.data!.docs, */
              initialPosition: currentPosition, //initialPosition,
              mapController: googleMapController,
              markers: markers,
            ),
            /* StoreCarousel(
                    mapController: googleMapController,
                    documents: snapshot.data!.docs,
                  ) */
          ],
        )
        /*   };
        },
      ), */
        );
  }
}

class StoreCarousel extends StatelessWidget {
  const StoreCarousel(
      {super.key, required this.documents, required this.mapController});

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.topLeft,
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            height: 90,
            child: StoreCarouselList(
                documents: documents, mapController: mapController),
          ),
        ));
  }
}

class StoreCarouselList extends StatelessWidget {
  const StoreCarouselList(
      {super.key, required this.documents, required this.mapController});

  final List<DocumentSnapshot> documents;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: documents.length,
      itemBuilder: (context, index) {
        return SizedBox(
          width: 340,
          child: Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Card(
              child: Center(
                child: StoreListTile(
                  document: documents[index],
                  mapController: mapController,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class StoreListTile extends StatefulWidget {
  const StoreListTile(
      {super.key, required this.document, required this.mapController});

  final DocumentSnapshot document;
  final Completer<GoogleMapController> mapController;

  @override
  State<StatefulWidget> createState() {
    return _StoreListTileState();
  }
}

class _StoreListTileState extends State<StoreListTile> {
  //Imagen de lugar
  String placePhotoUrl = '';
  bool disposed = false;

  @override
  void initState() {
    super.initState();
    _retrievePlacesDetails();
  }

  @override
  void dispose() {
    disposed = true;
    super.dispose();
  }

  //
  Future<void> _retrievePlacesDetails() async {
    final details = await _placesApiClient
        .getDetailsByPlaceId(widget.document['placeId'] as String);

    if (!disposed) {
      setState(() {
        placePhotoUrl = _placesApiClient.buildPhotoUrl(
            photoReference: details.result.photos[0].photoReference,
            maxHeight: 300);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.document['name'] as String),
      subtitle: Text(widget.document['address'] as String),
      leading: SizedBox(
        width: 100,
        height: 100,
        child: placePhotoUrl.isNotEmpty
            ? ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(2)),
                child: Image.network(placePhotoUrl, fit: BoxFit.cover),
              )
            : Container(),
      ),
      onTap: () async {
        //Ubicamos posicion cuanda da clic en el card
        /* final controller = await widget.mapController.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(widget.document['location'].latitude as double,
                  widget.document['location'].longitude as double),
              zoom: 16),
        )); */
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap(
      {super.key,
      /* required this.documents, */
      required this.initialPosition,
      required this.mapController,
      required this.markers});

  /* final List<DocumentSnapshot> documents; */
  final LatLng? initialPosition;
  final Completer<GoogleMapController> mapController;
  final dynamic markers;

  // Pinta el map
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<DirectionProvider>(builder:
          (BuildContext context, DirectionProvider api, Widget? child) {
        return GoogleMap(
          polylines: api.currentRuta,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          initialCameraPosition: CameraPosition(
            target: initialPosition ?? const LatLng(-2.06601, -79.9294133),
            zoom: 16,
          ),
          markers: markers!,
          onTap: (initialPosition) {
            log(initialPosition.toString());
          },
          onMapCreated: (controller) => {mapController.complete(controller)},
        );
      }),
    );
  }
}
