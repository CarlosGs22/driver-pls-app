import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/taxi_trip.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_please_flutter/screens/map/google_map_single_route.dart';
import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/location_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

class WidgetGoogleMap extends StatefulWidget {
  final ViajeModel viaje;
  final List<RutaViajeModel> rutaViaje;

  const WidgetGoogleMap(
      {Key? key, required this.viaje, required this.rutaViaje})
      : super(key: key);
  @override
  _WidgetGoogleMapState createState() => _WidgetGoogleMapState();
}

class _WidgetGoogleMapState extends State<WidgetGoogleMap> {
  Set<Marker> markers = {};
  List<WidgetMarker> widgetMarkers = [];

  LatLng? source;

  Map<PolylineId, Polyline> polyLines = <PolylineId, Polyline>{};

  int polyLineIdCounter = 1;

  GoogleMapController? mapController;

  final LocationService _locationService = LocationService();

  List<LatLng> listLocations = [];

  PolylinePoints polylinePoints = PolylinePoints();
  int inicialTrip = 0;

  int bandFinishTrip = 0;

  CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  List<Color> colorListLocal = [];

  String incidencia = "OK";

  final formIncidenceKey = GlobalKey<FormState>();

  String inicialDate = "";
  String endDate = "";

  List<LatLng> polylineCoordinatesCurrent = [];

  Timer? _timer;
  int secondsElapsed = 0;
  Timer? timer;

  _getRutaViajes() async {
    List<LatLng> auxListLocations = [];

    for (var element in widget.rutaViaje) {
      auxListLocations.add(LatLng(element.latitud, element.longitud));
    }

    setState(() {
      listLocations = auxListLocations;
    });
  }

  @override
  void initState() {
    _getCurrentLocationMap();
    _getRutaViajes();
    super.initState();
    _determinePosition().then((value) {
      setState(() {
        source = LatLng(value.latitude, value.longitude);
      });
      sendRequest();
    });
    setColor();

    /*bg.BackgroundGeolocation.ready(bg.Config(
        desiredAccuracy: bg.Config.DESIRED_ACCURACY_HIGH,
        distanceFilter: 1.0,
        stopOnTerminate: false,
        startOnBoot: true,
        debug: true,
        logLevel: bg.Config.LOG_LEVEL_VERBOSE
    )).then((bg.State state) {
      if (!state.enabled) {
        bg.BackgroundGeolocation.start();
      }
    });*/
  }

  _setStateColor(value, int indexColor) {
    if (value != null && value.toString().trim().isNotEmpty) {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    } else {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorGrayLight);
      });
    }
  }

  setColor() {
    colorListLocal = List.generate(1, (index) {
      return _colorFromHex(Widgets.colorGrayLight);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    secondsElapsed = 0;
    _closeTrip("CANCEL");
    
    
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        secondsElapsed++;
      });

      print(secondsElapsed);
    });
  }

  _sendRequestTrip() {
    var formParams = {
      "id_viaje": widget.viaje.idViaje,
    };
    HttpClass.httpData(
            context,
            Uri.parse("https://www.driverplease.net/aplicacion/startViaje.php"),
            formParams,
            {},
            "POST")
        .then((response) {
          print("4423432");
      print(response);
    });
  }

  void _startTrip() async {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.startTrip();
    _sendRequestTrip();

    final Uint8List markerIcon =
        await Utility.getBytesFromAsset('assets/images/pinAzul.png', 80);

    Position currentPosition = await _locationService.getCurrentLocation();

    List<Position> listPosition = [];

    setState(() {
      inicialDate = Utility.getCurrentDate();
      listPosition.add(currentPosition);

      markers.add(Marker(
          markerId: const MarkerId("inicialLocation"),
          infoWindow: const InfoWindow(title: ("Inicio")),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          position: LatLng(listPosition.last.latitude.toDouble(),
              listPosition.last.longitude.toDouble()),
          onTap: () {}));

      inicialTrip = 1;
    });

    _locationService.startLocationUpdates((Position newLoc) async {
      double newDistance =
          _locationService.calculateDistanceInMeters(listPosition.last, newLoc);

      setState(() {
        /*markers.removeWhere(
            (element) => element.markerId == const MarkerId("currentLocation"));*/
        markers.add(Marker(
            infoWindow: const InfoWindow(title: ("Estoy aqui")),
            markerId: const MarkerId("currentLocation"),
            flat: true,
            //anchor: const Offset(0.5, 0.5),
            icon: BitmapDescriptor.fromBytes(markerIcon),
            position:
                LatLng(newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
            onTap: () {}));
      });

      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        Utility.googleMapAPiKey,
        PointLatLng(listPosition.last.latitude.toDouble(),
            listPosition.last.longitude.toDouble()),
        PointLatLng(newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
        travelMode: TravelMode.transit,
      );

      List<LatLng> auxpolylineCoordinatesCurrent = [];

      if (result.points.isNotEmpty) {
        for (var point in result.points) {
          auxpolylineCoordinatesCurrent
              .add(LatLng(point.latitude, point.longitude));
        }

        setState(() {
          polylineCoordinatesCurrent.addAll(auxpolylineCoordinatesCurrent);
        });
      }

      PolylineId id = const PolylineId("CurrentPoly");
      Polyline polyline = Polyline(
        polylineId: id,
        geodesic: true,
        color: Colors.deepPurpleAccent,
        points: polylineCoordinatesCurrent,
        width: 4,
      );

      tripProvider.updateTrip(
          tripProvider.currentTrip!.distanceInMeters + newDistance,
          secondsElapsed);

      setState(() {
        polyLines[id] = polyline;
        listPosition.add(newLoc);

        mapController!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(
                target: LatLng(
                    newLoc.latitude.toDouble(), newLoc.longitude.toDouble()),
                zoom: 17)));

        mapController!.animateCamera(CameraUpdate.newLatLng(
            LatLng(newLoc.latitude.toDouble(), newLoc.longitude.toDouble())));
      });
    });
  }

  void _cancelTrip(BuildContext context) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "¡Atención!",
      closeIcon: const SizedBox(),
      closeFunction: () {},
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

  _handleTripResponse(Map<String, dynamic> response, BuildContext context,
      TaxiTrip currentTrip) { 
       
    
    if (response["status"] && response["code"] == 200) {
      _closeTrip("FINISH");
      _finishTrip(context, currentTrip);
    } else {
      buidlDefaultFlushBar(
          context, "Error", "Ocurrió un error al finalizar viaje", 4);
    }
  }

  void _finishTrip(BuildContext context, TaxiTrip currentTrip) {
    //int minutes = currentTrip != null ? currentTrip.timeInSeconds ~/ 60 : 0;
    //int seconds = currentTrip != null ? currentTrip.timeInSeconds % 60 : 0;

    Alert(
        onWillPopActive: true,
        context: context,
        type: AlertType.warning,
        closeIcon: const SizedBox(),
        closeFunction: () {},
        padding: const EdgeInsets.all(0),
        title: "Viaje cerrado",
        desc: "",
        style: AlertStyle(
            titleStyle: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 19),
            descStyle: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 15)),
        content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
                decoration: BoxDecoration(
                  color: _colorFromHex(Widgets.colorSecundayLight),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(20.0),
                  ),
                ),
                //width: width * 0.9,
                child: Form(
                  key: formIncidenceKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Resumen',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: _colorFromHex(Widgets.colorPrimary)),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Distancia",
                                  style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  currentTrip != null
                                      ? '${currentTrip.distanceInKilometers.toStringAsFixed(2)} km'
                                      : "0.00 Km",
                                  style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Tiempo",
                                  style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  currentTrip != null
                                      ?  formatTimeSeconds(currentTrip.timeInSeconds)
                                      : "0 min 0 s",
                                  style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Total",
                                  style: GoogleFonts.poppins(
                                      fontSize: 21,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500)),
                              Text(
                                  currentTrip != null
                                      ? '\$${currentTrip.totalCharge.toStringAsFixed(2)}'
                                      : "\$0.00",
                                  style: GoogleFonts.poppins(
                                      fontSize: 31,
                                      color:
                                          _colorFromHex((Widgets.colorPrimary)),
                                      fontWeight: FontWeight.w500))
                            ],
                          ),
                          SizedBox(
                              //height: 48,
                              child: TextFormField(
                                  initialValue: "Escribe una incidencia",
                                  autofocus: false,
                                  minLines: 6,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: null,
                                  validator: (value) =>
                                      validateField(value.toString()),
                                  onChanged: (value) =>
                                      _setStateColor(value, 0),
                                  onSaved: (value) =>
                                      incidencia = value.toString(),
                                  decoration: InputDecoration(
                                    prefixIcon: Icon(Icons.speaker_notes_sharp,
                                        color: colorListLocal[0]),
                                    hintText: Strings.hintIncidence,
                                    hintStyle: GoogleFonts.poppins(
                                        fontSize: 17, color: colorListLocal[0]),
                                    filled: true,
                                    fillColor: Colors.white,
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4.0),
                                      borderSide: BorderSide(
                                        color: colorListLocal[0],
                                      ),
                                    ),
                                    border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4.0))),
                                    errorStyle:
                                        GoogleFonts.poppins(color: Colors.red),
                                  ),
                                  style: GoogleFonts.poppins(
                                      color: colorListLocal[0]))),
                          Row(
                            children: [
                              Expanded(
                                  flex: 10,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 3, right: 3),
                                    child: longButtons("Guardar", () {
                                      _handleSendIncidence(context);
                                    },
                                        color: _colorFromHex(
                                            Widgets.colorPrimary)),
                                  )),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ))),
        buttons: []).show();
  }

  _handleFinishTrip(BuildContext context, TaxiTrip currentTrip) {
    int minutes = currentTrip != null ? currentTrip.timeInSeconds ~/ 60 : 0;
    int seconds = currentTrip != null ? currentTrip.timeInSeconds % 60 : 0;

    String distancia = currentTrip.distanceInKilometers.toStringAsFixed(2);
    double bandera = currentTrip.initialCharge;

    var formParams = json.encode({
      "distancia": distancia,
      "tiempo": currentTrip.timeInSeconds,
      "bandera": bandera,
      "minutos": minutes,
      "segundos": seconds,
      "porcentaje_comision": 0.15,
      "iva_translado": 0.16,
      "id_viaje": widget.viaje.idViaje,
      "tripStatus": 3,
      "fecha_inicio": inicialDate,
      "fecha_fin": endDate
    });

    HttpClass.httpData(
            context,
            Uri.parse(
                "https://www.driverplease.net/aplicacion/insertviajes.php"),
            formParams,
            {"content-type": "application/json"},
            "POST")
        .then((response) {
      _handleTripResponse(response, context, currentTrip);
    });
  }

  _handleSendIncidence(BuildContext context) {
    final form = formIncidenceKey.currentState;

    if (form!.validate()) {
      form.save();

      var formIncidence = json.encode({
        "id_viaje": widget.viaje.idViaje,
        "incidencia": incidencia,
        "tripStatus": 3
      });

      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/saveIncidence.php"),
              formIncidence,
              {"content-type": "application/json"},
              "POST")
          .then((response) {
        _handleIncidenceResponse(response, context);
      });
    }
  }

  _handleIncidenceResponse(
      Map<String, dynamic> response, BuildContext context) {
    Navigator.pop(context);

    if (response["status"] && response["code"] == 200) {
      widget.viaje.status = 3;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetailScreen(
                  viaje: widget.viaje,
                  redirect: "MAIN",
                  panelVisible: true,
                )),
        (Route<dynamic> route) => false,
      );
    } else {
      buidlDefaultFlushBar(
          context, "Error", "Ocurrió un error al registrar incidencia", 4);
    }
  }

  _closeTrip(var option) {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.cancelTrip();
    tripProvider.dispose();
    
    _locationService.stopLocationUpdates();

    if (option == "FINISH") {
      setState(() {
        markers.removeWhere((element) =>
            element.markerId != const MarkerId("currentLocation") &&
            element.markerId != const MarkerId("inicialLocation"));

        polyLines.removeWhere((key, value) =>
            value.polylineId != const PolylineId("CurrentPoly"));

        inicialTrip = 0;
        bandFinishTrip = 0;

        timer!.cancel();
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
        timer!.cancel();
      });
    }
  }

  _getCurrentLocationMap() async {
    bool permision = await Utility.requestLocationPermission();

    if (!permision) {
      return;
    }

    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
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
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
          actions: [
            Row(
              children: [
                Text(
                  Strings.labelTripItinerario,
                  style: GoogleFonts.poppins(
                      fontSize: 19,
                      color: Colors.white,
                      fontWeight: FontWeight.w500),
                ),
                IconButton(
                  icon: const Icon(Icons.alt_route_rounded),
                  onPressed: () {
                    showFlexibleBottomSheet(
                      minHeight: 0,
                      initHeight: 0.7,
                      maxHeight: 1,
                      context: context,
                      builder: (context, scrollController, bottomSheetOffset) {
                        return TripDetailScreen(
                          viaje: widget.viaje,
                          redirect: null,
                          panelVisible: false,
                        );
                      },
                      anchors: [0, 0.5, 1],
                    );
                  },
                )
              ],
            )
          ],
        ),

        //drawer: const MainDrawer(0),
        body:
            Consumer<TaxiTripProvider>(builder: (context, tripProvider, child) {
          TaxiTrip? currentTrip = tripProvider.currentTrip;

     
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

                  SafeArea(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 10, left: 27, right: 27, bottom: 10),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _colorFromHex(Widgets.colorSecundayLight),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(20.0),
                            ),
                          ),
                          //width: width * 0.9,
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
                                                : "0.00 Km",
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
                                                ? formatTimeSeconds(currentTrip.timeInSeconds)
                                                : "00:00:00",
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
                                    switch (inicialTrip) {
                                      case 0:
                                        startTimer();
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
                                          : "CANCELAR VIAJE",
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
                                bandFinishTrip == 0
                                    ? inicialTrip == 1
                                        ? ElevatedButton(
                                            onPressed: () {
                                              setState(() {
                                                endDate =
                                                    Utility.getCurrentDate();
                                                bandFinishTrip = 1;
                                                
                                              });

                                              TaxiTrip? auxcurrentTrip =
                                                  tripProvider.currentTrip;

                                              tripProvider.stopTrip();
                                               _timer?.cancel();
                                              _handleFinishTrip(
                                                  context, auxcurrentTrip!);
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
                                        : const SizedBox()
                                    : buildCircularProgress(context),
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
          onTap: () {}));
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
    final polylinePoints = PolylinePoints();
    final List<LatLng> polylineCoordinates = [];

    final startPoint = PointLatLng(start.latitude, start.longitude);
    final finishPoint = PointLatLng(finish.latitude, finish.longitude);

    final result = await polylinePoints.getRouteBetweenCoordinates(
        Utility.googleMapAPiKey, startPoint, finishPoint,
        travelMode: TravelMode.driving,
        optimizeWaypoints: false,
        avoidHighways: false,
        avoidTolls: false,
        avoidFerries: true);

    if (result.points.isNotEmpty) {
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
        geodesic: true,
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await Geolocator.requestPermission();
      buidlDefaultFlushBar(
          context, "Error", "El permiso de ubicación esta desabilitado", 4);

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        buidlDefaultFlushBar(
            context, "Error", "El permiso de ubicación esta denegado", 4);

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      buidlDefaultFlushBar(
          context,
          "Error",
          "El permiso de ubicación esta permanentemente denegado\n Debe de permitirlo desde la configuración de la app",
          4);
      return Future.error(
          'El permiso de ubicación esta permanentemente denegado\n Debe de permitirlo desde la configuración de la app');
    }

    return await Geolocator.getCurrentPosition();
  }
}
