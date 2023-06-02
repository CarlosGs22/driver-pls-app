import 'dart:typed_data';

import 'package:driver_please_flutter/models/taxi_trip.dart';
import 'package:driver_please_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/screens/map/google_map_single_route.dart';
import 'package:driver_please_flutter/services/location_service.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

/// This widget helps us to draw multiple polylines on the google map
class WidgetGoogleMap extends StatefulWidget {
  @override
  _WidgetGoogleMapState createState() => _WidgetGoogleMapState();
}

class _WidgetGoogleMapState extends State<WidgetGoogleMap> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Set<Marker> markers = {};
  List<WidgetMarker> widgetMarkers = [];

  LatLng? source;

  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};

  int polyLineIdCounter = 1;

  GoogleMapController? mapController;

  final LocationService _locationService = LocationService();

  List<LatLng> listLocations = [
    const LatLng(20.585946, -100.385417),
    const LatLng(20.571589, -100.406730),
    const LatLng(20.533760, -100.452506)
  ];


  PolylinePoints polylinePoints = PolylinePoints();
  int inicialTrip = 0;

  CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  @override
  void initState() {

    _getCurrentLocationMap();
    super.initState();
    _determinePosition().then((value) {
      setState(() {
        source = LatLng(value.latitude, value.longitude);
      });
      sendRequest();
    });
  }

  @override
  void dispose() {
    _locationService.stopLocationUpdates();
    super.dispose();
  }

  void _startTrip() async {
    if (inicialTrip == 0) {
      return;
    }

    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.startTrip();

    final Uint8List markerIcon =
        await Utility.getBytesFromAsset('assets/images/pinAzul.png', 80);

    Position initialPosition = await _locationService.getCurrentLocation();
    Position currentPosition = initialPosition;

    setState(() {
      markers.add(Marker(
          markerId: const MarkerId("inicialLocation"),
          infoWindow: const InfoWindow(title: ("Inicio")),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          position: LatLng(currentPosition.latitude.toDouble(),
              currentPosition.longitude.toDouble()),
          onTap: () {}));
    });

    _locationService.startLocationUpdates((Position newLoc) async {
      double newDistance =
          _locationService.calculateDistanceInMeters(currentPosition, newLoc);

      setState(() {
        markers.removeWhere(
            (element) => element.markerId == const MarkerId("currentLocation"));
        markers.add(Marker(
            infoWindow: const InfoWindow(title: ("Estoy aqui")),
            markerId: const MarkerId("currentLocation"),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            position:
                LatLng(newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
            onTap: () {}));
      });

      List<LatLng> polylineCoordinatesCurrent = [];

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Utility.googleMapAPiKey,
        PointLatLng(currentPosition.latitude.toDouble(),
            currentPosition.longitude.toDouble()),
        PointLatLng(newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
        travelMode: TravelMode.driving,
      );

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          polylineCoordinatesCurrent
              .add(LatLng(point.latitude, point.longitude));
        }
      } else {
        print(result.errorMessage);
      }

      PolylineId id = const PolylineId("CurrentPoly");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.deepPurpleAccent,
        points: polylineCoordinatesCurrent,
        width: 8,
      );
      polyLines[id] = polyline;

      tripProvider.updateTrip(
          tripProvider.currentTrip!.distanceInMeters + newDistance,
          tripProvider.currentTrip!.timeInSeconds + 5);

      mapController!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(
              target: LatLng(
                  newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
              zoom: 17)));

      setState(() {
        inicialTrip = 1;
      });
    });
  }

  void _cancelTrip(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "¡Atención!",
      desc: "¿Estás seguro de cancelar el viaje?",
      buttons: [
        DialogButton(
          child: const Text(
            "Aceptar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            _closeTrip("CANCEL");
            Navigator.pop(context);
          },
          color: _colorFromHex(Widgets.colorPrimary),
        ),
        DialogButton(
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: _colorFromHex(Widgets.colorSecundary),
        )
      ],
    ).show();
  }

  void _finishTrip(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "¡Atención!",
      desc: "¿Estás seguro de terminar el viaje?",
      buttons: [
        DialogButton(
          child: const Text(
            "Aceptar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            _closeTrip("FINISH");
            Navigator.pop(context);
          },
          color: _colorFromHex(Widgets.colorPrimary),
        ),
        DialogButton(
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: _colorFromHex(Widgets.colorSecundary),
        )
      ],
    ).show();
  }

  _closeTrip(var option) {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.cancelTrip();
    _locationService.stopLocationUpdates();

    if (option == "FINISH") {
      setState(() {
        markers.removeWhere((element) =>
            element.markerId != const MarkerId("currentLocation") &&
            element.markerId != const MarkerId("inicialLocation"));

        polyLines.removeWhere((key, value) =>
            value.polylineId != const PolylineId("CurrentPoly"));

        inicialTrip = 0;
      });
    }

    if (option == "CANCEL") {
      setState(() {
        markers.removeWhere((element) =>
            element.markerId == const MarkerId("currentLocation") ||
            element.markerId == const MarkerId("inicialLocation"));

        polyLines.removeWhere((key, value) =>
            value.polylineId == const PolylineId("CurrentPoly"));

        inicialTrip = 0;
      });
    }
  }

  _getCurrentLocationMap() async {
    bool permision = await Utility.requestLocationPermission();

    if (!permision) {
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
        _initialLocation = CameraPosition(
            target: LatLng(position.altitude, position.longitude));
      });
    }).catchError((e) {
      print("ERROR 1");
      print(e);
    });
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          titleTextStyle: GoogleFonts.poppins(
              fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
          title: const Text(Strings.labelTaximetro),
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.filter_alt_sharp),
              onPressed: () {},
            )
          ],
        ),
        drawer: const MainDrawer(0),
        body:
            Consumer<TaxiTripProvider>(builder: (context, tripProvider, child) {
          TaxiTrip? currentTrip = tripProvider.currentTrip;

          int minutes =
              currentTrip != null ? currentTrip.timeInSeconds ~/ 60 : 0;
          int seconds =
              currentTrip != null ? currentTrip.timeInSeconds % 60 : 0;

          return SizedBox(
              height: height,
              width: width,
              child: Stack(
                children: <Widget>[
                  GoogleMap(
                    polylines: Set<Polyline>.of(polyLines.values),
                    markers: markers,
                    //widgetMarkers: widgetMarkers,
                    onMapCreated: (c) {
                      mapController = c;
                    },
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    myLocationEnabled: true,
                    initialCameraPosition: _initialLocation,
                    mapType: MapType.normal,
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ClipOval(
                            child: Material(
                              color: _colorFromHex(
                                  Widgets.colorSecundary), // button color
                              child: InkWell(
                                splashColor: _colorFromHex(
                                    Widgets.colorPrimary), // inkwell color
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: Icon(Icons.add, color: Colors.white),
                                ),
                                onTap: () {
                                  mapController!.animateCamera(
                                    CameraUpdate.zoomIn(),
                                  );
                                },
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ClipOval(
                            child: Material(
                              color: _colorFromHex(Widgets.colorSecundary),
                              child: InkWell(
                                splashColor: _colorFromHex(
                                    Widgets.colorPrimary), // inkwell color
                                child: const SizedBox(
                                  width: 50,
                                  height: 50,
                                  child:
                                      Icon(Icons.remove, color: Colors.white),
                                ),
                                onTap: () {
                                  mapController!.animateCamera(
                                    CameraUpdate.zoomOut(),
                                  );
                                },
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // Show the place input fields & button for
                  // showing the route
                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorFromHex(Widgets.colorSecundayLight),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          width: width * 0.9,
                          child: Padding(
                            padding:
                                const EdgeInsets.only(top: 4.0, bottom: 4.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Tarifas',
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      color:
                                          _colorFromHex(Widgets.colorPrimary)),
                                ),
                                const SizedBox(height: 10),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Distancia",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            currentTrip != null
                                                ? '${currentTrip.distanceInKilometers.toStringAsFixed(2)} km'
                                                : "0.00",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500))
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Tiempo",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            currentTrip != null
                                                ? '$minutes min $seconds s'
                                                : "0 min 0 s",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500))
                                      ],
                                    ),

                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text("Total",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500)),
                                        Text(
                                            currentTrip != null
                                                ? '\$${currentTrip.totalCharge.toStringAsFixed(2)}'
                                                : "\$0.00",
                                            style: GoogleFonts.poppins(
                                                fontSize: 18,
                                                color: _colorFromHex(
                                                    (Widgets.colorPrimary)),
                                                fontWeight: FontWeight.w500))
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    print(inicialTrip);
                                    switch (inicialTrip) {
                                      case 0:
                                        _startTrip();
                                        break;
                                      case 1:
                                        _cancelTrip(context);
                                        break;
                                    }
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      inicialTrip == 0
                                          ? 'INICIAR VIAJE'
                                          : "DETENER VIAJE",
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20.0,
                                      ),
                                    ),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    primary:
                                        _colorFromHex(Widgets.colorSecundary),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
                                ),
                                inicialTrip == 1
                                    ? ElevatedButton(
                                        onPressed: () {
                                          _finishTrip(context);
                                        },
                                        child: const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Finalizar Viaje",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                            ),
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          primary: _colorFromHex(
                                              Widgets.colorPrimary),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Show current location button
                  SafeArea(
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(right: 10.0, bottom: 10.0),
                        child: ClipOval(
                          child: Material(
                            color: _colorFromHex(
                                Widgets.colorSecundary), // button color
                            child: InkWell(
                              splashColor: _colorFromHex(
                                  Widgets.colorPrimary), // inkwell color
                              child: const SizedBox(
                                width: 56,
                                height: 56,
                                child: Icon(Icons.my_location,
                                    color: Colors.white),
                              ),
                              onTap: () async {
                                _getCurrentLocationMap();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ));
        }));
  }

  void sendRequest() {
    getMultiplePolyLines();
    addMarker();
  }

  _handlePolylineTap(PolylineId polylineId, LatLng finish) {
    setState(() {
      Polyline newPolyline =
          polyLines[polylineId]!.copyWith(colorParam: Colors.blue);

      polyLines[polylineId] = newPolyline;
    });

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => GoogleMapSingleRoute(
                  currentLocation: source!,
                  polylineCoordinates: polyLines[polylineId]!.points,
                  destinationLocation: finish,
                ))).then((value) {
      polyLines.forEach((key, value) {
        if (value.color == Colors.blue) {
          Polyline newPolyline =
              polyLines[value.polylineId]!.copyWith(colorParam: Colors.red);

          polyLines[polylineId] = newPolyline;
        }
        setState(() {});
      });
    });
  }

  Future<void> addMarker() async {
    for (var i = 0; i < listLocations.length; i++) {
      var element = listLocations[i];

      double dista = 0;
      if (i != listLocations.length - 1) {
        dista = Utility.calculateDistance(
            listLocations[i].latitude,
            listLocations[i].latitude,
            listLocations[i + 1].latitude,
            listLocations[i + 1].latitude);
      }

      final Uint8List markerIcon =
          await Utility.getBytesFromAsset('assets/images/pinRojo.png', 80);

      markers.add(Marker(
          markerId: MarkerId(element.toString()),
          infoWindow: InfoWindow(
              title:
                  (dista != 0 ? dista.toStringAsFixed(3).toString() : "Fin")),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          draggable: false,
          position: LatLng(element.latitude, element.longitude),
          onTap: () {
            /*HelperClass()
                .onMarkerTapped(source!, element, context, mapController);*/
          }));

      /*widgetMarkers.add(createMarker(
          LatLng(element.latitude, element.longitude),
          element.toString(),
          Colors.red,
          (i + 1).toString()));*/
    }
  }

  getMultiplePolyLines() async {
    await Future.forEach(listLocations, (LatLng elem) async {
      await _getRoutePolyline(
        start: listLocations.first,
        finish: elem,
        color: Colors.green,
        id: '$elem',
        width: 4,
      );
    });

    setState(() {});
  }

  Future<Polyline> _getRoutePolyline(
      {required LatLng start,
      required LatLng finish,
      required Color color,
      required String id,
      int width = 6}) async {
    // Generates every polyline between start and finish
    final polylinePoints = PolylinePoints();
    // Holds each polyline coordinate as Lat and Lng pairs
    final List<LatLng> polylineCoordinates = [];

    final startPoint = PointLatLng(start.latitude, start.longitude);
    final finishPoint = PointLatLng(finish.latitude, finish.longitude);

    final result = await polylinePoints.getRouteBetweenCoordinates(
      Utility.googleMapAPiKey,
      startPoint,
      finishPoint,
       travelMode: TravelMode.driving,
       optimizeWaypoints: true,
    );

    if (result.points.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      for (var point in result.points) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      }
    }

    polyLineIdCounter++;

    final Polyline polyline = Polyline(
        polylineId: PolylineId(id),
        consumeTapEvents: true,
        points: polylineCoordinates,
        color: Colors.red,
        width: 4,
        onTap: () {
          _handlePolylineTap(
              PolylineId(
                id,
              ),
              finish);
        });

    setState(() {
      polyLines[PolylineId(id)] = polyline;
    });

    return polyline;
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;
  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    permission = await Geolocator.requestPermission();

    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return Future.error('Location permissions are denied');
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  return await Geolocator.getCurrentPosition();
}
