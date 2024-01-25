
import 'dart:developer';

import 'package:f_maps_firestore/api_key.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart' as maps;
import 'package:google_maps_webservice/directions.dart';

class DirectionProvider extends ChangeNotifier {

  GoogleMapsDirections directionsApi = GoogleMapsDirections(apiKey:  googleMapsApiKey);

  Set<maps.Polyline> _rutas = {};

  Set<maps.Polyline> get currentRuta => _rutas;

  findDirections(maps.LatLng from, maps.LatLng to) async {
      var origin = Location(lat:  from.latitude, lng:  from.longitude);
      var destination = Location(lat:  to.latitude, lng:  to.longitude);
      
      var result = await directionsApi.directionsWithLocation(origin, destination);
      Set<maps.Polyline> newRoute = {};
      log(result.toString());

      if(result.isOkay){

          var route = result.routes[0];
          var leg = route.legs[0];

          List<maps.LatLng> points = [];

          for (var step in leg.steps) { 
            points.add(maps.LatLng(step.startLocation.lat, step.startLocation.lng));
            points.add(maps.LatLng(step.endLocation.lat, step.endLocation.lng));
          }

          var line = maps.Polyline(points: points,
          polylineId: const maps.PolylineId("Ruta"),
          color: Colors.red,
          width: 4);

          newRoute.add(line);

          //log(line);

          _rutas = newRoute;

          notifyListeners();// notificar

      }

  }
}