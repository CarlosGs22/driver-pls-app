import 'dart:convert';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Location _location = Location();
  List<LatLng> _points = [];
  Set<Polyline> _polylines = {};
  bool _isTracking = false;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  void _requestLocationPermission() async {
    var serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    var permissionGranted = await _location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
  }

  void _startTracking() async {
    _isTracking = true;

    final currentLocation = await _location.getLocation();
    final latLng = LatLng(currentLocation.latitude!, currentLocation.longitude!);

    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16.0));

    setState(() {
      _points.clear();
      _points.add(latLng);
      _polylines.clear();
    });

    _location.onLocationChanged.listen((locationData) {
      if (_isTracking) {
        final newLatLng = LatLng(locationData.latitude!, locationData.longitude!);
        setState(() {
          _points.add(newLatLng);
          _updateRoute();
        });
      }
    });
  }

  void _stopTracking() {
    _isTracking = false;
  }

  void _updateRoute() async {
    if (_points.length < 2) {
      return;
    }

    LatLng origin = _points[_points.length - 2];
    LatLng destination = _points.last;

    String apiKey = Utility.googleMapAPiKey; // Reemplaza con tu clave de API válida para Google Maps Directions API
    String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&mode=driving&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);

      if (decoded['status'] == 'OK') {
        List<LatLng> points = _decodePolylinePoints(decoded['routes'][0]['overview_polyline']['points']);
        setState(() {
          _polylines = {
            Polyline(
              polylineId: PolylineId('route'),
              points: [..._points, ...points],
              color: Colors.blue,
              width: 4,
            ),
          };
        });
      }
    }
  }

  List<LatLng> _decodePolylinePoints(String encodedPoints) {
    List<LatLng> points = [];

    for (final point in decodeEncodedPolyline(encodedPoints)) {
      points.add(LatLng(point[0], point[1]));
    }

    return points;
  }

  List<List<double>> decodeEncodedPolyline(String encoded) {
    List<List<double>> poly = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / 1e5;
      double longitude = lng / 1e5;
      poly.add([latitude, longitude]);
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
