import 'package:flutter/material.dart';

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';

import 'api_key.dart';

// Center of the Google Map
const initialPosition = LatLng(37.7786, -122.4375);
// Hue used by the Google Map Markers to match the theme
const _pinkHue = 350.0;
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
  late Stream<QuerySnapshot> _iceCreamStores;
  final Completer<GoogleMapController> googleMapController = Completer();

  @override
  void initState() {
    super.initState();

    _iceCreamStores = FirebaseFirestore.instance
        .collection('ice_cream_stores')
        .orderBy('name')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ubicacion'),//Text(widget.title),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _iceCreamStores,
        builder: (context, snapshot) {
          return switch (snapshot) {
            AsyncSnapshot(hasError: true) =>
              Center(child: Text('Error: ${snapshot.error}' , style: const TextStyle(color: Colors.white),)),
            AsyncSnapshot(hasData: false) =>
              const Center(child: Text('Loading ...')),
            _ => Stack(
                children: [
                  StoreMap(
                      documents: snapshot.data!.docs,
                      initialPosition: initialPosition,
                      mapController: googleMapController),
                  StoreCarousel(
                      mapController: googleMapController,
                      documents: snapshot.data!.docs)
                ],
              )
          };
        },
      ),
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
    final details = await _placesApiClient.getDetailsByPlaceId(
      widget.document['placeId'] as String
    );

    if(!disposed){
      setState(() {
        placePhotoUrl = _placesApiClient.buildPhotoUrl(photoReference: details.result.photos[0].photoReference, maxHeight: 300);
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
        final controller = await widget.mapController.future;
        await controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(widget.document['location'].latitude as double,
                  widget.document['location'].longitude as double),
              zoom: 16),
        ));
      },
    );
  }
}

class StoreMap extends StatelessWidget {
  const StoreMap(
      {super.key,
      required this.documents,
      required this.initialPosition,
      required this.mapController});

  final List<DocumentSnapshot> documents;
  final LatLng initialPosition;
  final Completer<GoogleMapController> mapController;

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 12,
      ),
      markers: documents
          .map((e) => Marker(
              markerId: MarkerId(e['placeId'] as String),
              icon: BitmapDescriptor.defaultMarkerWithHue(_pinkHue),
              position: LatLng(
                e['location'].latitude as double,
                e['location'].longitude as double,
              ),
              infoWindow: InfoWindow(
                  title: e['name'] as String, snippet: e['address'] as String)))
          .toSet(),
      onMapCreated: (controller) => {mapController.complete(controller)},
    );
  }
}
