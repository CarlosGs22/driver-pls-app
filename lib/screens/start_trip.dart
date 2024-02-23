import 'dart:async';
import 'dart:convert';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/ruta_viaje_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:provider/provider.dart';
import 'package:location/location.dart' as loc;

class StartTrip extends StatefulWidget {
  final ViajeModel viaje;
  const StartTrip({required this.viaje});

  @override
  State<StartTrip> createState() => _StartTripState();
}

class _StartTripState extends State<StartTrip> {
  int selectedRoute = 0;

  GoogleMapController? mapController;

  List<RutaViajeModel> rutaViajes = [];

  loc.Location _locationServicex = loc.Location();

  CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  StreamSubscription<loc.LocationData>? _locationSubscription;

  loc.LocationData? _currentLocation;

  int seconds = 0;
  late Timer timer;

  final List<LatLng> _polylineCoordinates = [];
  bool _zoomMap = true;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  bool showBandStartTrip = false;

  late RutaViajeModel actualGeneralRoute;

  int selectedIndexRoute = 0;

  Set<Marker> markers = {};

  bool isLoading = false;

  String incidencia = "OK";

    final formIncidenceKey = GlobalKey<FormState>();

  void _addMarker(LatLng position, String markerId) {
    Marker newMarker = Marker(
      markerId: MarkerId(markerId),
      position: position,
      infoWindow: InfoWindow(title: markerId),
    );

    setState(() {
      markers.add(newMarker);
    });
  }

  _showCard() {
    return Container(
        margin: const EdgeInsets.only(top: 15, bottom: 15),
        color: _colorFromHex(Widgets.colorWhite),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
                flex: 4,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(children: [
                      Text(
                        "Parada " + selectedIndexRoute.toString(),
                        style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary),
                            fontSize: 14),
                      ),
                      Icon(
                        Icons.room_outlined,
                        size: 16,
                        color: _colorFromHex(Widgets.colorPrimary),
                      ),
                      Text(
                        "Hora: " + actualGeneralRoute.hora,
                        style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary),
                            fontSize: 15),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      showBandStartTrip
                          ? SizedBox(
                              child: ElevatedButton(
                              onPressed: () {
                                _handleFinishRoute(context);
                              },
                              child: Padding(
                                  padding: EdgeInsets.all(7),
                                  child: Text(
                                    'En\n punto',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: _colorFromHex(Widgets.colorWhite),
                                      fontSize: 20.0,
                                    ),
                                  )),
                              style: ElevatedButton.styleFrom(
                                primary: _colorFromHex(Widgets.colorPrimary),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                            ))
                          : SizedBox()
                    ]),
                  ],
                )),
            Flexible(
              flex: 6,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  validateNullOrEmptyString(actualGeneralRoute.parada1) != null
                      ? Text(
                          actualGeneralRoute.parada1,
                          style: TextStyle(
                              color: _colorFromHex(Widgets.colorWhite),
                              fontSize: 12),
                        )
                      : validateNullOrEmptyString(
                                  actualGeneralRoute.personaNombre) !=
                              null
                          ? Text(
                              actualGeneralRoute.personaNombre,
                              style: TextStyle(
                                  color: _colorFromHex(Widgets.colorWhite),
                                  fontSize: 12),
                            )
                          : Text(
                              "NA",
                              style: TextStyle(
                                  color: _colorFromHex(Widgets.colorWhite),
                                  fontSize: 12),
                            ),
                  const SizedBox(height: 5),
                  Text(
                    "Pertenece " + actualGeneralRoute.nombreEmpresa,
                    style: TextStyle(
                        color: _colorFromHex(Widgets.colorPrimary),
                        fontSize: 12),
                  ),
                  Text(
                    "Domicilio " + actualGeneralRoute.direccion,
                    style: TextStyle(
                        color: _colorFromHex(Widgets.colorPrimary),
                        fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Contacto " + actualGeneralRoute.personaTelefono,
                    style: TextStyle(
                        color: _colorFromHex(Widgets.colorPrimary),
                        fontSize: 12),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      IconButton(
                          icon: const Icon(Icons.phone),
                          color: _colorFromHex(Widgets.colorPrimary),
                          onPressed: () {}),
                      IconButton(
                        icon: const Icon(Icons.alt_route_outlined),
                        color: _colorFromHex(Widgets.colorPrimary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.message),
                        color: _colorFromHex(Widgets.colorPrimary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.image),
                        color: _colorFromHex(Widgets.colorPrimary),
                        onPressed: () {},
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  _getRutaViajes() async {
    setState(() {
      isLoading = true;
    });
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    List<RutaViajeModel> auxRutaViajes = await RutaViajeService.getViajes(
        context, widget.viaje.idViaje,
        path: cliente.path);

    if (auxRutaViajes.isNotEmpty) {
      rutaViajes = auxRutaViajes;

      for (var element in auxRutaViajes) {
        List<LatLng> decodedPolyline = decodePolyline(element.poligono);

        if (decodedPolyline.isNotEmpty) {
          // _addMarker(LatLng(decodedPolyline.first.latitude, decodedPolyline.first.longitude), decodedPolyline.first.longitude.toString());

          setState(() {
            _polylineCoordinates.addAll(decodedPolyline);
          });
        }
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  _handleSelectedRoute(RutaViajeModel ruta, BuildContext context, int index) {
    Navigator.pop(context);
    setState(() {
      actualGeneralRoute = ruta;
      selectedRoute = 1;
      selectedIndexRoute = index + 1;
    });
  }

  _getCurrentLocationMap() async {
    bool permision = await Utility.requestLocationPermission();

    if (!permision) {
      return;
    }

    await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.best)
        .then((geo.Position position) async {
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

  _handleShowRoutes(BuildContext context) {
    showFlexibleBottomSheet(
      minHeight: 0,
      context: context,
      builder: (context, scrollController, bottomSheetOffset) {
        return Container(
            alignment: Alignment.center,
            color: _colorFromHex(Widgets.colorWhite),
            child: SingleChildScrollView(
              physics: const ScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      color: _colorFromHex(Widgets.colorPrimary),
                      height: 52,
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Seleccionar parada",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 28,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )),
                  Container(
                      color: _colorFromHex(Widgets.colorGrayLight),
                      height: 40,
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                        "Detalle de ruta",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      )),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Padding(
                          padding: EdgeInsets.only(
                              left: 16, right: 16, top: 6, bottom: 6),
                          child: Card(
                            color: validateNullOrEmptyString(
                                            rutaViajes[index].fecha_fin_ruta) !=
                                        null &&
                                    validateNullOrEmptyString(
                                            rutaViajes[index].poligono) !=
                                        null
                                ? Colors.red
                                : Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (validateNullOrEmptyString(
                                            rutaViajes[index].fecha_fin_ruta) !=
                                        null &&
                                    validateNullOrEmptyString(
                                            rutaViajes[index].poligono) !=
                                        null) {
                                  print("PARADA YA REALIZADA");
                                  return;
                                }

                                _handleSelectedRoute(
                                    rutaViajes[index], context, index);
                              },
                              child: ListTile(
                                leading: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Parada " + (index + 1).toString(),
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 14),
                                    ),
                                    Icon(
                                      Icons.room_outlined,
                                      size: 16,
                                      color:
                                          _colorFromHex(Widgets.colorPrimary),
                                    ),
                                    Text(
                                      "Hora: " + rutaViajes[index].hora,
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 15),
                                    ),
                                  ],
                                ),
                                title: validateNullOrEmptyString(
                                            rutaViajes[index].parada1) !=
                                        null
                                    ? Text(
                                        rutaViajes[index].parada1,
                                        style: TextStyle(
                                            color: _colorFromHex(
                                                Widgets.colorWhite),
                                            fontSize: 12),
                                      )
                                    : validateNullOrEmptyString(
                                                rutaViajes[index]
                                                    .personaNombre) !=
                                            null
                                        ? Text(
                                            rutaViajes[index].personaNombre,
                                            style: TextStyle(
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                fontSize: 12),
                                          )
                                        : Text(
                                            "NA",
                                            style: TextStyle(
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                fontSize: 12),
                                          ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const SizedBox(height: 5),
                                    Text(
                                      "Pertenece " +
                                          rutaViajes[index].nombreEmpresa,
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 12),
                                    ),
                                    Text(
                                      "Domicilio " +
                                          rutaViajes[index].direccion,
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      "Contacto " +
                                          rutaViajes[index].personaTelefono,
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ));
                    },
                    itemCount: rutaViajes.length,
                  ),
                ],
              ),
            ));
      },
      anchors: [0, 0.5, 1],
    );
  }

  void _updateMapCamera() {
    if (mapController != null) {
      if (!_zoomMap) {
        return;
      }

      mapController!.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!),
        15.0,
      ));
    }
  }

  _handleStartTrip() async {
    var locat = loc.Location();

    bool serviceEnabled = await _locationServicex.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationServicex.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

     startTimer();

    setState(() {
      showBandStartTrip = true;
    });

   

    await geo.Geolocator.getCurrentPosition(
            desiredAccuracy: geo.LocationAccuracy.best)
        .then((geo.Position position) async {
      _addMarker(LatLng(position.latitude, position.longitude),
          position.timestamp.toString());
    });

    //LISTEN GPS
    locat.enableBackgroundMode(enable: true);
    locat.changeSettings(
        accuracy: loc.LocationAccuracy.high, interval: 1000, distanceFilter: 0);

    _locationSubscription =
        locat.onLocationChanged.listen((loc.LocationData locationData) {
      setState(() {
        _currentLocation = locationData;

        _polylineCoordinates.add(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));
      });
      _updateMapCamera();
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        seconds ++;
        print(seconds.toString());
      });
    });
  }

  _handleFinishRoute(BuildContext context) {
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    var formParams = {
      "idRuta": actualGeneralRoute.idRuta,
      "segundos": seconds.toString(),
      "poligono": json.encode(_polylineCoordinates)
    };

    _addMarker(
        LatLng(_polylineCoordinates.last.latitude,
            _polylineCoordinates.last.longitude),
        _polylineCoordinates.last.longitude.toString());

    HttpClass.httpData(
            context,
            Uri.parse(cliente.path + "aplicacion/finishRuta.php"),
            formParams,
            {},
            "POST")
        .then((response) {
          timer.cancel();
      if (response["status"] && response["code"] == 200) {
        setState(() {
          rutaViajes[selectedIndexRoute - 1].fecha_fin_ruta = "REALIZADA";
          rutaViajes[selectedIndexRoute - 1].poligono = "REALIZADA";
          showBandStartTrip = false;
          //actualGeneralRoute = ;
          selectedRoute = 0;
          selectedIndexRoute = 0;
          seconds = 0;
        });
      }
    });
  }

  _handleFinishGeneralTrip(BuildContext context) {
    var formParams = json.encode({
      "distancia":
          calcularDistanciaTotal(_polylineCoordinates).toStringAsFixed(2),
      "id_viaje": widget.viaje.idViaje,
      "tripStatus": 3,
      "poligono": json.encode(_polylineCoordinates)
    });

    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    HttpClass.httpData(
            context,
            Uri.parse(cliente.path + "aplicacion/insertviajes.php"),
            formParams,
            {"content-type": "application/json"},
            "POST")
        .then((response) {
      _handleTripResponse(response, context);
    });
  }

    _handleTripResponse(Map<String, dynamic> response, BuildContext context) {
    if (response["status"] && response["code"] == 200) {
      _finishTrip(context, response);
    } else {
      buidlDefaultFlushBar(
          context, "Error", "Ocurrió un error al finalizar viaje", 4);
    }
  }


  _handleSendIncidence(BuildContext context,Map<String,dynamic> dataInserted) {
    final form = formIncidenceKey.currentState;

    if (form!.validate()) {
      form.save();

      var formIncidence = json.encode({
        "id_viaje": widget.viaje.idViaje,
        "incidencia": incidencia,
        "tripStatus": 3
      });

      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      HttpClass.httpData(
              context,
              Uri.parse(cliente.path + "aplicacion/saveIncidence.php"),
              formIncidence,
              {"content-type": "application/json"},
              "POST")
          .then((response) {
        _handleIncidenceResponse(response, context,dataInserted);
      });
    }
  }

  _handleIncidenceResponse(
      Map<String, dynamic> response, BuildContext context, Map<String, dynamic> dataInserted) {
    Navigator.pop(context);

    if (response["status"] && response["code"] == 200) {
      widget.viaje.status = 3;
      widget.viaje.incidencias = incidencia;
      widget.viaje.poligono = json.encode(_polylineCoordinates);
      widget.viaje.fechaInicio = dataInserted["fechaInicio"];
      widget.viaje.fechaFin = dataInserted["fechaFin"];

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetailScreen(
                  viaje: widget.viaje,
                  redirect: "MAIN",
                  panelVisible: true,
                  bandCancelTrip: false,
                )),
        (Route<dynamic> route) => false,
      );
    } else {
      buidlDefaultFlushBar(
          context, "Error", "Ocurrió un error al registrar incidencia", 4);
    }
  }




    void _finishTrip(BuildContext context, 
      Map<String, dynamic> response) {
    Map<String, dynamic> getDataInserted = response["data"];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

        return WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: AlertDialog(
              title: Center(
                child: Text(
                  'Viaje cerrado',
                  style: TextStyle(
                    fontSize: 24.0,
                    color: _colorFromHex(Widgets.colorPrimary),
                  ),
                ),
              ),
              content: Container(
                width: double.maxFinite,
                constraints: BoxConstraints(
                    maxHeight:
                        MediaQuery.of(context).size.height - keyboardHeight),
                child: SingleChildScrollView(
                    child: Form(
                  key: formIncidenceKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Resumen',
                        style: TextStyle(
                          fontSize: 20.0,
                          color: _colorFromHex(Widgets.colorPrimary),
                        ),
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
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(
                                validateNullOrEmptyString(
                                            getDataInserted["distancia"]) !=
                                        null
                                    ? validateNullOrEmptyString(
                                                getDataInserted["distancia"])
                                            .toString() +
                                        ' km'
                                    : "0.00 Km",
                                style: GoogleFonts.poppins(
                                  fontSize: 21,
                                  color: _colorFromHex((Widgets.colorPrimary)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(
                                validateNullOrEmptyString(
                                            getDataInserted["formatoHora"]) !=
                                        null
                                    ? getDataInserted["formatoHora"].toString()
                                    : "00:00",
                                style: GoogleFonts.poppins(
                                  fontSize: 21,
                                  color: _colorFromHex((Widgets.colorPrimary)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
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
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(
                                validateNullOrEmptyString(
                                            getDataInserted["subtotal"]) !=
                                        null
                                    ? '\$ ' +
                                        getDataInserted["subtotal"].toString()
                                    : "\$0.00",
                                style: GoogleFonts.poppins(
                                  fontSize: 31,
                                  color: _colorFromHex((Widgets.colorPrimary)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                              //height: 48,
                              child: Padding(
                            padding: EdgeInsets.only(top: 13, bottom: 13),
                            child: TextFormField(
                              initialValue: "",
                              autofocus: false,
                              minLines: 6,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) =>
                                  validateField(value.toString()),
                              
                              onSaved: (value) => incidencia = value.toString(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.speaker_notes_sharp,
                                  
                                ),
                                hintText: Strings.hintIncidence,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 17,
                                 
                                ),
                                filled: true,
                                fillColor: _colorFromHex(Widgets.colorWhite),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4.0),
                                  ),
                                ),
                                errorStyle:
                                    GoogleFonts.poppins(color: Colors.red),
                              ),
                              style:
                                  GoogleFonts.poppins(),
                            ),
                          )),
                          Row(
                            children: [
                              Expanded(
                                flex: 10,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 3, right: 3),
                                  child: longButtons("Guardar", () {
                                    _handleSendIncidence(context,getDataInserted);
                                  },
                                      color:
                                          _colorFromHex(Widgets.colorPrimary)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
              ),
            ));
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocationMap();
    _getRutaViajes();
  }

  @override
  void dispose() {
    super.dispose();
    timer.cancel();
    _locationSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    CameraPosition _initialLocation =
        const CameraPosition(target: LatLng(0.0, 0.0));

    return Scaffold(
        appBar: AppBar(
          titleTextStyle: GoogleFonts.poppins(
              fontSize: 19,
              color: _colorFromHex(Widgets.colorWhite),
              fontWeight: FontWeight.w500),
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10),
              child: Row(
                children: [
                  InkWell(
                    child: Text(
                      "Finalizar viaje",
                      style: GoogleFonts.poppins(
                          fontSize: 19,
                          color: _colorFromHex(Widgets.colorWhite),
                          fontWeight: FontWeight.w500),
                    ),
                    onTap: () {
                      _handleFinishGeneralTrip(context);
                    },
                  )
                ],
              ),
            )
          ],
        ),
        body: isLoading
            ? buildCircularProgress(context)
            : SizedBox(
                height: height,
                width: width,
                child: Stack(
                  children: <Widget>[
                    GoogleMap(
                      onMapCreated: (c) {
                        mapController = c;
                      },
                      onCameraIdle: () {
                        setState(() {
                          _zoomMap = false;
                        });
                      },
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      myLocationEnabled: true,
                      initialCameraPosition: _initialLocation,
                      markers: markers,
                      polylines: {
                        Polyline(
                          polylineId: PolylineId('route'),
                          color: _colorFromHex(Widgets.colorSecundayLight2),
                          points: _polylineCoordinates,
                        ),
                      },
                      onCameraMove: (CameraPosition position) {},
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
                                    Widgets.colorPrimary), // button color
                                child: InkWell(
                                  splashColor: _colorFromHex(Widgets
                                      .colorSecundayLight), // inkwell color
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(Icons.add,
                                        color:
                                            _colorFromHex(Widgets.colorWhite)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _zoomMap = false;
                                    });
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
                                color: _colorFromHex(Widgets.colorPrimary),
                                child: InkWell(
                                  splashColor: _colorFromHex(Widgets
                                      .colorSecundayLight), // inkwell color
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: Icon(Icons.remove,
                                        color:
                                            _colorFromHex(Widgets.colorWhite)),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _zoomMap = false;
                                    });

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
                            //width: 400,

                            decoration: BoxDecoration(
                              color: _colorFromHex(Widgets.colorWhite),
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
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      selectedRoute != 0
                                          ? _showCard()
                                          : SizedBox(),
                                      ElevatedButton(
                                        onPressed: () {
                                          _handleShowRoutes(context);
                                        },
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            'VER RUTA',
                                            style: TextStyle(
                                              color: _colorFromHex(
                                                  Widgets.colorWhite),
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
                                    ],
                                  ),
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
                        child: Row(
                          children: [
                            !showBandStartTrip && selectedRoute != 0
                                ? Flexible(
                                    flex: 8,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            child: Padding(
                                                padding: EdgeInsets.only(
                                                    left: 17, right: 17),
                                                child: Material(
                                                  color: _colorFromHex(
                                                      Widgets.colorPrimary),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20.0),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20.0),
                                                    child: InkWell(
                                                      splashColor:
                                                          _colorFromHex(Widgets
                                                              .colorSecundayLight),
                                                      child: SizedBox(
                                                        width: 40,
                                                        height: 55,
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(5),
                                                          child: Center(
                                                            child: Text(
                                                              'Iniciar viaje',
                                                              style: TextStyle(
                                                                color: _colorFromHex(
                                                                    Widgets
                                                                        .colorWhite),
                                                                fontSize: 20.0,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      onTap: () async {
                                                        sendRequestTrip(
                                                            widget
                                                                .viaje.idViaje,
                                                            context);
                                                        _handleStartTrip();
                                                      },
                                                    ),
                                                  ),
                                                ))),
                                      ],
                                    ),
                                  )
                                : SizedBox(),
                            Flexible(
                              flex: 2,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 10.0, bottom: 10.0),
                                    child: ClipOval(
                                      child: Material(
                                        color:
                                            _colorFromHex(Widgets.colorPrimary),
                                        child: InkWell(
                                          splashColor: _colorFromHex(
                                              Widgets.colorSecundayLight),
                                          child: SizedBox(
                                            width: 56,
                                            height: 56,
                                            child: Icon(Icons.my_location,
                                                color: _colorFromHex(
                                                    Widgets.colorWhite)),
                                          ),
                                          onTap: () async {
                                            _getCurrentLocationMap();
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  ],
                )));
  }
}
