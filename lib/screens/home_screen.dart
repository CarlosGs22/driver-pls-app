import 'package:driver_pls_flutter/models/taxi_trip.dart';
import 'package:driver_pls_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_pls_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_pls_flutter/services/location_service.dart';
import 'package:driver_pls_flutter/utils/strings.dart';
import 'package:driver_pls_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final LocationService _locationService = LocationService();
  late GoogleMapController _mapController;
  Map<PolylineId, Polyline> _polylines = {};

  Future<bool> _requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    super.dispose();
  }

  void _startTrip() async {
    bool permissionGranted = await _requestLocationPermission();
    if (!permissionGranted) {
      return;
    }
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.startTrip();

    Position initialPosition = await _locationService.getCurrentLocation();
    Position currentPosition = initialPosition;

    _locationService.startLocationUpdates((Position newPosition) {
      double newDistance = _locationService.calculateDistanceInMeters(
          currentPosition, newPosition);
      tripProvider.updateTrip(
          tripProvider.currentTrip!.distanceInMeters + newDistance,
          tripProvider.currentTrip!.timeInSeconds + 5);
      currentPosition = newPosition;
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(newPosition.latitude, newPosition.longitude),
              zoom: 17),
        ),
      );
      _updatePolyline(newPosition);
    });
  }

  void _stopTrip() {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.stopTrip();
    _locationService.stopLocationUpdates();
  }

  void _cancelTrip() {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.cancelTrip();
    _locationService.stopLocationUpdates();
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    _goToCurrentLocation();
  }

  void _updatePolyline(Position currentPosition) {
    const polylineId = PolylineId('route');
    final position = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );
    late Polyline polyline;

    if (_polylines.containsKey(polylineId)) {
      final temp = _polylines[polylineId]!;
      polyline = temp.copyWith(pointsParam: [...temp.points, position]);
    } else {
      polyline = Polyline(
        polylineId: polylineId,
        points: [position],
        color: Colors.blue,
        width: 3,
      );
    }
    _polylines[polylineId] = polyline;
    setState(() {});

    /* setState(() {
       _polylines.add(
         Polyline(
           polylineId: PolylineId(currentPosition.toString()),
           points: [
             LatLng(currentPosition.latitude, currentPosition.longitude),
             LatLng(currentPosition.latitude, currentPosition.longitude),
           ],
           width: 3,
           color: Colors.blue,
         ),
       );
     });*/
  }

  Future<void> _goToCurrentLocation() async {
    Position position = await _locationService.getCurrentLocation();
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude), zoom: 17),
      ),
    );
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
        title: const Text(Strings.labelTaximetro),
        elevation: 0.1,
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
          )
        ],
      ),
      drawer: const MainDrawer(0),
      body: Consumer<TaxiTripProvider>(
        builder: (context, tripProvider, child) {
          TaxiTrip? currentTrip = tripProvider.currentTrip;

          int minutes =
              currentTrip != null ? currentTrip.timeInSeconds ~/ 60 : 0;
          int seconds =
              currentTrip != null ? currentTrip.timeInSeconds % 60 : 0;

          return Center(
              child: Column(
            children: [
              SizedBox(
                  width: MediaQuery.of(context).size.width,
                  height: 350,
                  child: GoogleMap(
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: const CameraPosition(
                      target: LatLng(20.652469, -100.410729), // Coordenadas de ejemplo, puede cambiarlas
                      zoom: 12,
                    ),
                    polylines: _polylines.values.toSet(),
                  )),
              currentTrip != null
                  ? Text(
                      'Distancia: ${currentTrip.distanceInKilometers.toStringAsFixed(2)} km')
                  : const Text('Distancia: 0.00 km'),
              currentTrip != null
                  ? Text('Tiempo: $minutes min $seconds s')
                  : const Text('Tiempo: 0 min 0 s'),
              currentTrip != null
                  ? Text(
                      'Total: \$${currentTrip.totalCharge.toStringAsFixed(2)}')
                  : const Text('Total: \$0.00'),
              const SizedBox(height: 20),
              tripProvider.isTripActive
                  ? SizedBox(
                      width: 185,
                      height: 50,
                      child: longButtons("Detener viaje", _stopTrip,
                          color: _colorFromHex(Widgets.colorPrimary)),
                    )
                  : SizedBox(
                      width: 185,
                      height: 50,
                      child: longButtons("Iniciar viaje", _startTrip,
                          color: _colorFromHex(Widgets.colorPrimary)),
                    ),
              const SizedBox(height: 5),
              SizedBox(
                  width: 185,
                  height: 50,
                  child: longButtons("Cancelar viaje",
                      tripProvider.isTripActive ? _cancelTrip : () {},
                      color: tripProvider.isTripActive
                          ? Colors.green
                          : Colors.grey)),
              if (_polylines.isNotEmpty && !tripProvider.isTripActive) ...[
                const SizedBox(height: 5),
                SizedBox(
                    width: 185,
                    height: 50,
                    child: longButtons("Borrar trayecto", () {
                      setState(() {
                        _polylines = {};
                      });
                    }, color: Colors.green))
              ]
            ],
          ));
        },
      ),
    );
  }
}
