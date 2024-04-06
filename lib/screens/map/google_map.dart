import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/taxi_trip.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_please_flutter/screens/map/google_map_single_route.dart';
import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/location_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_background/flutter_background.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:widget_marker_google_map/widget_marker_google_map.dart';

import 'package:http/http.dart' as http;

import 'package:location/location.dart' as loc;

import 'package:intl/date_symbol_data_local.dart';

import 'package:wakelock/wakelock.dart';

StreamSubscription<LocationData>? _locationSubscription;

class WidgetGoogleMap extends StatefulWidget {
  final ViajeModel viaje;
  final List<RutaViajeModel> rutaViaje;

  const WidgetGoogleMap(
      {Key? key, required this.viaje, required this.rutaViaje})
      : super(key: key);
  @override
  _WidgetGoogleMapState createState() => _WidgetGoogleMapState();
}

class _WidgetGoogleMapState extends State<WidgetGoogleMap>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Future<void> initBackgroundTasks() async {
    await FlutterBackground.initialize();
    // Configura aquí tus tareas en segundo plano
  }

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
  bool bandWaitTime = false;

  CameraPosition _initialLocation =
      const CameraPosition(target: LatLng(0.0, 0.0));

  List<Color> colorListLocal = [];

  String incidencia = "OK";

  final formIncidenceKey = GlobalKey<FormState>();

  String inicialDate = "";
  String endDate = "";

  int secondsWaitTime = 0;

  List<LatLng> polylineCoordinatesCurrent = [];

  int secondsElapsed = 0;
  Timer? timer;

  loc.Location _locationServicex = loc.Location();

  List<LatLng> _polylineCoordinates = [];
  Set<Polyline> _polylines = {};
  LatLng _initialCameraPosition = LatLng(0, 0);
  //LatLng? _currentLocation;
  LatLng? _previousLocation;

  LatLng? _startMarkerPosition;
  LatLng? _endMarkerPosition;

  LocationData? _currentLocation;

  bool _zoomMap = true;

  bool isLoading = false;

  bool validateViaje = true;

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
    Wakelock.enable();

    WidgetsBinding.instance!.addObserver(this);
    initBackgroundTasks();

    initializeDateFormatting();
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

    if (validateNullOrEmptyString(widget.viaje.idViaje) == null) {
      setState(() {
        validateViaje = false;
      });
    }


  }

  _setStateColor(value, int indexColor) {
    if (value != null && value.toString().trim().isNotEmpty) {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    } else {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    }
  }

  setColor() {
    colorListLocal = List.generate(1, (index) {
      return _colorFromHex(Widgets.colorPrimary);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      setState(
          () {}); 
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    secondsElapsed = 0;
    //_closeTrip("CANCEL");
    if (_locationSubscription != null) {
      _locationSubscription!.cancel();
    }

    WidgetsBinding.instance!.removeObserver(this);

    super.dispose();
  }

  void startTimer(var type) {
    switch (type) {
      case "WAITTIME":
        TaxiTripProvider tripProvider =
            Provider.of<TaxiTripProvider>(context, listen: false);

        tripProvider.startTrip();

        timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            secondsElapsed++;
            tripProvider.updateTrip(0, secondsElapsed);
          });
        });

        DateTime now = DateTime.now();
        String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss')
            .format(now); 
        UserPreferences().saveValueUser("INICIALDATE", formattedDate);
        break;

      case "TRIP":
        timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            secondsElapsed++;
            bandWaitTime = false;
            //print(secondsElapsed);
          });
        });
        break;
      default:
    }
  }

  _sendRequestTrip() async {
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    final SharedPreferences prefs = await SharedPreferences.getInstance();


    var formParams = {
      "id_viaje": widget.viaje.idViaje,
      "segundos_espera": secondsWaitTime.toString(),
    };

    if(validateNullOrEmptyString(prefs.getString("INICIALDATE")) != null) {
      formParams.addAll({"fecha_inicial" : prefs.getString("INICIALDATE").toString()});
    }

    HttpClass.httpData(
            context,
            Uri.parse(cliente.path + "aplicacion/startViaje.php"),
            formParams,
            {},
            "POST")
        .then((response) {
      setState(() {
        secondsWaitTime = 0;
      });

      UserPreferences().removeValueUser("INICIALDATE");

      print("CAMBIO DE STATUS DE VIAJE");
      print(response);
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
          child: Text(
            "Cancelar",
            style: TextStyle(
                color: _colorFromHex(Widgets.colorWhite), fontSize: 18),
          ),
          onPressed: () => Navigator.pop(context),
          color: _colorFromHex(Widgets.colorSecundary),
        ),
        DialogButton(
          child: Text(
            "Aceptar",
            style: TextStyle(
                color: _colorFromHex(Widgets.colorWhite), fontSize: 18),
          ),
          onPressed: () {
            _closeTrip("CANCEL");
            Navigator.pop(context);
          },
          color: _colorFromHex(Widgets.colorPrimary),
        ),
      ],
    ).show();
  }

  void _handleModalCloseTrip(
      BuildContext context, TaxiTripProvider tripProvider) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "¡Atención!",
      closeIcon: const SizedBox(),
      closeFunction: () {},
      desc: "¿Estás seguro de finalizar el viaje?",
      buttons: [
        DialogButton(
          child: Text(
            "Cancelar",
            style: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 18),
          ),
          border: Border.all(color: _colorFromHex(Widgets.colorPrimary)),
          onPressed: () => Navigator.pop(context),
          color: _colorFromHex(Widgets.colorWhite),
        ),
        DialogButton(
          child: Text(
            "Aceptar",
            style: TextStyle(
                color: _colorFromHex(Widgets.colorWhite), fontSize: 18),
          ),
          onPressed: () {
            setState(() {
              endDate = Utility.getCurrentDate();
              bandFinishTrip = 1;
            });

            TaxiTrip? auxcurrentTrip = tripProvider.currentTrip;

            tripProvider.stopTrip();
            timer?.cancel();
            _locationSubscription!.cancel();

            _handleFinishTrip(context, auxcurrentTrip!);
          },
          color: _colorFromHex(Widgets.colorPrimary),
        ),
      ],
    ).show();
  }

  _handleTripResponse(Map<String, dynamic> response, BuildContext context,
      TaxiTrip currentTrip) {
    if (response["status"] && response["code"] == 200) {
      _closeTrip("FINISH");
      _finishTrip(context, currentTrip, response);
    } else {
      buidlDefaultFlushBar(context, "Ocurrió un error al finalizar viaje",
          response["data"].toString(), 4);
    }
  }

//DATA INSERTED
  void _finishTripNoNetwork(BuildContext context, TaxiTrip currentTrip,
      Map<String, dynamic> response) {
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
                  'Viaje cerrado \n Tu recorrido se procesará cuando vuelvas a tener conexión a internet ',
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
                                            response["distancia"]) !=
                                        null
                                    ? validateNullOrEmptyString(
                                                response["distancia"])
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
                                validateNullOrEmptyString(response["tiempo"]) !=
                                        null
                                    ? validateNullOrEmptyString(
                                            response["tiempo"])
                                        .toString()
                                    : "0:00",
                                style: GoogleFonts.poppins(
                                  fontSize: 21,
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
                              onChanged: (value) => _setStateColor(value, 0),
                              onSaved: (value) => incidencia = value.toString(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.speaker_notes_sharp,
                                  color: colorListLocal[0],
                                ),
                                hintText: Strings.hintIncidence,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 17,
                                  color: colorListLocal[0],
                                ),
                                filled: true,
                                fillColor: _colorFromHex(Widgets.colorWhite),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: colorListLocal[0],
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
                                  GoogleFonts.poppins(color: colorListLocal[0]),
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
                                    _handleSendIncidence(context);
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

  void _finishTrip(BuildContext context, TaxiTrip currentTrip,
      Map<String, dynamic> response) {
    Map<String, dynamic> getDataInserted = response["data"];

    int segundos = (validateNullOrEmptyNumber(
            int.tryParse(getDataInserted["segundos_espera"]) ?? 0) ??
        0);
    String resultadoSegundosEspera = convertirSegundosAHora(segundos);

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
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
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
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
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
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
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
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(
                                  fontSize: 19,
                                  color: _colorFromHex((Widgets.colorPrimary)),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),

                          //TIEMPO ESPERA

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Tiempo \nde espera",
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color:
                                        _colorFromHex((Widgets.colorPrimary)),
                                    fontWeight: FontWeight.w500,
                                  )),
                              Text(
                                ((validateNullOrEmptyString(
                                        convertirSegundosAHora(int.tryParse(
                                                getDataInserted[
                                                    "segundos_espera"]) ??
                                            0))) ??
                                    "00:00:00"),
                                textAlign: TextAlign.end,
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
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
                                  textAlign: TextAlign.start,
                                  style: GoogleFonts.poppins(
                                    fontSize: 19,
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
                                textAlign: TextAlign.end,
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
                              onChanged: (value) => _setStateColor(value, 0),
                              onSaved: (value) => incidencia = value.toString(),
                              decoration: InputDecoration(
                                prefixIcon: Icon(
                                  Icons.speaker_notes_sharp,
                                  color: colorListLocal[0],
                                ),
                                hintText: Strings.hintIncidence,
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 17,
                                  color: colorListLocal[0],
                                ),
                                filled: true,
                                fillColor: _colorFromHex(Widgets.colorWhite),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: colorListLocal[0],
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
                                  GoogleFonts.poppins(color: colorListLocal[0]),
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
                                    _handleSendIncidence(context);
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

  _handleFinishTrip(BuildContext context, TaxiTrip currentTrip) async {
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
      "fecha_fin": endDate,
      "poligono": json.encode(_polylineCoordinates)
    });

    var connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.wifi ||
        connectivityResult == ConnectivityResult.mobile) {
      Navigator.pop(context);

      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      HttpClass.httpData(
              context,
              Uri.parse(cliente.path + "aplicacion/insertviajes.php"),
              formParams,
              {"content-type": "application/json"},
              "POST")
          .then((response) {
        _handleTripResponse(response, context, currentTrip);
      });
    } else {
      UserPreferences().saveValueUser("TRIPDATA", formParams);
      _closeTrip("FINISH");
      _finishTripNoNetwork(context, currentTrip, json.decode(formParams));
    }
  }

  _handleSendIncidence(BuildContext context) async {
    final form = formIncidenceKey.currentState;

    if (form!.validate()) {
      form.save();

      var formIncidence = json.encode({
        "id_viaje": widget.viaje.idViaje,
        "incidencia": incidencia,
        "tripStatus": 3
      });

      var connectivityResult = await Connectivity().checkConnectivity();

      if (connectivityResult == ConnectivityResult.wifi ||
          connectivityResult == ConnectivityResult.mobile) {
        final cliente =
            Provider.of<ClienteProvider>(context, listen: false).cliente;

        HttpClass.httpData(
                context,
                Uri.parse(cliente.path + "aplicacion/saveIncidence.php"),
                formIncidence,
                {"content-type": "application/json"},
                "POST")
            .then((response) {
          _handleIncidenceResponse(response, context);
        });
      } else {
        UserPreferences().saveValueUser("TRIPINCIDENCE", formIncidence);
        Navigator.pop(context);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => TripDetailScreen(
                    viaje: widget.viaje,
                    redirect: "MAIN",
                    panelVisible: true,
                    bandCancelTrip: false,
                    bandItinerario: false,
                  )),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  _handleIncidenceResponse(
      Map<String, dynamic> response, BuildContext context) {
    Navigator.pop(context);

    if (response["status"] && response["code"] == 200) {
      widget.viaje.status = 3;
      widget.viaje.incidencias = incidencia;
      widget.viaje.poligono = json.encode(_polylineCoordinates);
      widget.viaje.fechaInicio = inicialDate;
      widget.viaje.fechaFin = endDate;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetailScreen(
                viaje: widget.viaje,
                redirect: "MAIN",
                panelVisible: true,
                bandCancelTrip: false,
                bandItinerario: false)),
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

    //_locationService.stopLocationUpdates();

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

        if (inicialTrip == 1) {
          setState(() {
            _zoomMap = true;
          });
        }
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

  Future<void> getRouteBetweenCoordinates(
      LatLng origin, LatLng destination) async {
    final apiKey = Utility.googleMapAPiKey;

    String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var data = json.decode(response.body);
      if (data['status'] == 'OK') {
        List<LatLng> points = [];
        var routes = data['routes'][0]['legs'][0]['steps'];
        routes.forEach((step) {
          points.add(LatLng(
            step['start_location']['lat'],
            step['start_location']['lng'],
          ));
          points.add(LatLng(
            step['end_location']['lat'],
            step['end_location']['lng'],
          ));
        });

        setState(() {
          _polylineCoordinates.addAll(points);
          _polylines.clear();
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            color: _colorFromHex(Widgets.colorSecundayLight2),
            points: _polylineCoordinates,
            width: 3,
          ));
        });
      }
    }
  }

  void _updateMarkers() {
    if (_currentLocation != null) {
      if (_startMarkerPosition == null) {
        _startMarkerPosition =
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
      }
      _endMarkerPosition =
          LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!);
    }
  }

  void _startTrip() async {
    var locat = loc.Location();
    _currentLocation = await locat.getLocation();

    bool serviceEnabled = await _locationServicex.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationServicex.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionGranted =
        await _locationServicex.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationServicex.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);
    tripProvider.startTrip();
    _sendRequestTrip();

    setState(() {
      inicialDate = Utility.getCurrentDate();
      inicialTrip = 1;
      _zoomMap = true;
    });

    locat.enableBackgroundMode(enable: true);
    locat.changeSettings(
        accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 0);

    _locationSubscription =
        locat.onLocationChanged.listen((LocationData locationData) {
      setState(() {
        _currentLocation = locationData;

        if (_polylineCoordinates.isNotEmpty) {
          double newDistance = _locationService.calculateDistanceInMeters(
            _polylineCoordinates.last.latitude,
            _polylineCoordinates.last.longitude,
            _currentLocation!.latitude,
            _currentLocation!.longitude,
          );

          tripProvider.updateTrip(
              tripProvider.currentTrip!.distanceInMeters + newDistance,
              secondsElapsed);
        }

        _polylineCoordinates.add(
            LatLng(_currentLocation!.latitude!, _currentLocation!.longitude!));

        _updateMarkers();
      });
      _updateMapCamera();
    });
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

  void _handleStartWaitTime(BuildContext context) {
    if (puedeIniciarViaje(widget.viaje.fechaViaje, widget.viaje.horaViaje)) {
      setState(() {
        bandWaitTime = true;
      });
      startTimer("WAITTIME");
    } else {
      MotionToast.warning(
              title: const Text("Atención"),
              description: const Text(
                  "No se puede iniciar tiempo de espera antes de la hora programada."))
          .show(context);
    }
  }

  void _handleStoptWaitTime(BuildContext context) {
    TaxiTripProvider tripProvider =
        Provider.of<TaxiTripProvider>(context, listen: false);

    secondsWaitTime = secondsElapsed;

    setState(() {
      secondsElapsed = 0;
      bandWaitTime = false;
      timer!.cancel();
      isLoading = true;
    });

    tripProvider.stopTrip();
    tripProvider.cancelTrip();

    Future.delayed(Duration(seconds: 2)).then((value) {
      setState(() {
        isLoading = false;
      });
      startTimer("TRIP");
      _startTrip();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return WillPopScope(onWillPop: () async {
      if (inicialTrip == 1 || bandWaitTime) {
        return false;
      } else {
        return true;
      }
    }, child:
        Consumer<TaxiTripProvider>(builder: (context, tripProvider, child) {
      TaxiTrip? currentTrip = tripProvider.currentTrip;

      return Scaffold(
          appBar: AppBar(
            titleTextStyle: GoogleFonts.poppins(
                fontSize: 19,
                color: _colorFromHex(Widgets.colorWhite),
                fontWeight: FontWeight.w500),
            elevation: 0.1,
            backgroundColor: _colorFromHex(Widgets.colorPrimary),
            actions: [
              inicialTrip == 1
                  ? Container(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleModalCloseTrip(context, tripProvider);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Finalizar viaje',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _colorFromHex(Widgets.colorPrimary),
                              fontSize: 16.0,
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: _colorFromHex(Widgets.colorWhite),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                    )
                  : SizedBox()
            ],
          ),

          //drawer: const MainDrawer(0),
          body: isLoading
              ? buildCircularProgress(context)
              : !validateViaje
                  ? Center(
                      child: Text(
                        'ID VIAJE NO PRESENTE',
                        style: TextStyle(
                            fontSize: 20.0,
                            color: _colorFromHex(Widgets.colorPrimary)),
                      ),
                    )
                  : SizedBox(
                      height: height,
                      width: width,
                      child: Stack(
                        children: <Widget>[
                          GoogleMap(
                            markers: {
                              if (_startMarkerPosition != null)
                                Marker(
                                    markerId: MarkerId('start'),
                                    position: _startMarkerPosition!),
                              if (_endMarkerPosition != null)
                                Marker(
                                    markerId: MarkerId('end'),
                                    position: _endMarkerPosition!),
                            },
                            polylines: {
                              Polyline(
                                polylineId: PolylineId('route'),
                                color:
                                    _colorFromHex(Widgets.colorSecundayLight2),
                                points: _polylineCoordinates,
                              ),
                            },
                            onCameraIdle: () {
                              if (inicialTrip == 1) {
                                setState(() {
                                  _zoomMap = false;
                                });
                              }
                            },
                            onCameraMove: (CameraPosition position) {
                              if (inicialTrip == 1) {
                                if (!_zoomMap) {
                                  setState(() {
                                    _zoomMap = true;
                                  });
                                }
                              }
                            },
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
                                          Widgets.colorPrimary), // button color
                                      child: InkWell(
                                        splashColor: _colorFromHex(Widgets
                                            .colorPrimary), // inkwell color
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Icon(Icons.add,
                                              color: _colorFromHex(
                                                  Widgets.colorWhite)),
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
                                      color:
                                          _colorFromHex(Widgets.colorPrimary),
                                      child: InkWell(
                                        splashColor: _colorFromHex(Widgets
                                            .colorPrimary), // inkwell color
                                        child: SizedBox(
                                          width: 50,
                                          height: 50,
                                          child: Icon(Icons.remove,
                                              color: _colorFromHex(
                                                  Widgets.colorWhite)),
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
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          blurRadius: 90,
                                          blurStyle: BlurStyle.outer)
                                    ],
                                    color: _colorFromHex(Widgets.colorWhite),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(20.0),
                                    ),
                                  ),
                                  //width: width * 0.9,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 4.0, bottom: 4.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                          'Recorrido',
                                          style: TextStyle(
                                              fontSize: 20.0,
                                              color: _colorFromHex(
                                                  Widgets.colorPrimary)),
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
                                                            (Widgets
                                                                .colorPrimary)),
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    currentTrip != null
                                                        ? '${currentTrip.distanceInKilometers.toStringAsFixed(2)} km'
                                                        : "0.00 Km",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        color: _colorFromHex(
                                                            (Widgets
                                                                .colorPrimary)),
                                                        fontWeight:
                                                            FontWeight.w500))
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
                                                            (Widgets
                                                                .colorPrimary)),
                                                        fontWeight:
                                                            FontWeight.w500)),
                                                Text(
                                                    currentTrip != null
                                                        ? formatTimeSeconds(
                                                            currentTrip
                                                                .timeInSeconds)
                                                        : "00:00:00",
                                                    style: GoogleFonts.poppins(
                                                        fontSize: 18,
                                                        color: _colorFromHex(
                                                            (Widgets
                                                                .colorPrimary)),
                                                        fontWeight:
                                                            FontWeight.w500))
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 10),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4, right: 4),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              widget.viaje.tipo != "SALIDA" &&
                                                      inicialTrip == 0
                                                  ? Flexible(
                                                      flex: 5,
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .only(
                                                                left: 4,
                                                                right: 4),
                                                        child: SizedBox(
                                                          height: 55,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              startTimer(
                                                                  "TRIP");
                                                              _startTrip();
                                                            },
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                'INICIAR VIAJE',
                                                                textAlign:
                                                                    TextAlign
                                                                        .center,
                                                                style:
                                                                    TextStyle(
                                                                  color: _colorFromHex(
                                                                      Widgets
                                                                          .colorWhite),
                                                                  fontSize:
                                                                      16.0,
                                                                ),
                                                              ),
                                                            ),
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              primary:
                                                                  _colorFromHex(
                                                                      Widgets
                                                                          .colorPrimary),
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            20.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ))
                                                  : SizedBox()

                                              //TIEMPO DE ESPERA
                                            ],
                                          ),
                                        ),
                                        !bandWaitTime
                                            ? SizedBox()
                                            : Container(
                                                alignment:
                                                    Alignment.bottomCenter,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 30,
                                                          right: 30,
                                                          bottom: 10,
                                                          top: 10),
                                                  child: SizedBox(
                                                    height: 55,
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _handleStoptWaitTime(
                                                            context);
                                                      },
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Text(
                                                          "INICIAR VIAJE",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color: _colorFromHex(
                                                                Widgets
                                                                    .colorWhite),
                                                            fontSize: 14.0,
                                                          ),
                                                        ),
                                                      ),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        primary: _colorFromHex(
                                                            Widgets
                                                                .colorPrimary),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20.0),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        bandFinishTrip == 0
                                            ? inicialTrip == 1
                                                ? ElevatedButton(
                                                    onPressed: () {
                                                      showFlexibleBottomSheet(
                                                        minHeight: 0,
                                                        initHeight: 0.8,
                                                        maxHeight: 1,
                                                        context: context,
                                                        builder: (context,
                                                            scrollController,
                                                            bottomSheetOffset) {
                                                          return TripDetailScreen(
                                                            viaje: widget.viaje,
                                                            redirect: null,
                                                            panelVisible: false,
                                                            bandCancelTrip:
                                                                false,
                                                            bandItinerario:
                                                                true,
                                                          );
                                                        },
                                                        anchors: [0, 0.5, 1],
                                                      );
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        "Ver detalle",
                                                        style: TextStyle(
                                                          color: _colorFromHex(
                                                              Widgets
                                                                  .colorWhite),
                                                          fontSize: 20.0,
                                                        ),
                                                      ),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      primary: _colorFromHex(
                                                          Widgets.colorPrimary),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(20.0),
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
                          SafeArea(
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 12, bottom: 12),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    inicialTrip == 0 &&
                                            !bandWaitTime &&
                                            widget.viaje.tipo != "ENTRADA"
                                        ? Flexible(
                                            flex: 5,
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, right: 4),
                                              child: SizedBox(
                                                height: 55,
                                                width: 200,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    _handleStartWaitTime(
                                                        context);
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Text(
                                                      "INICIAR TIEMPO DE ESPERA",
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: _colorFromHex(
                                                            Widgets.colorWhite),
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                                  ),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    primary: _colorFromHex(
                                                        Widgets.colorPrimary),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20.0),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ))
                                        : SizedBox(),
                                    Flexible(
                                      flex: 5,
                                      child: ClipOval(
                                        child: Material(
                                          color: _colorFromHex(Widgets
                                              .colorPrimary), // button color
                                          child: InkWell(
                                            splashColor: _colorFromHex(Widgets
                                                .colorPrimary), // inkwell color
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
                            ),
                          ),
                        ],
                      )));
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

    // Navigator.push(
    //     context,
    //     MaterialPageRoute(
    //         builder: (_) => GoogleMapSingleRoute(
    //               currentLocation: source!,
    //               polylineCoordinates: polyLines[polylineId]!.points,
    //               destinationLocation: finish,
    //             ))).then((value) {
    //   polyLines.forEach((key, value) {
    //     if (value.color == Colors.blue) {
    //       Polyline newPolyline =
    //           polyLines[value.polylineId]!.copyWith(colorParam: Colors.red);

    //       polyLines[polylineId] = newPolyline;
    //     }
    //     setState(() {});
    //   });
    // });
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
      int width = 4}) async {
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

  Future<geo.Position> _determinePosition() async {
    bool serviceEnabled;
    geo.LocationPermission permission;
    serviceEnabled = await geo.Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      permission = await geo.Geolocator.requestPermission();
      buidlDefaultFlushBar(
          context, "Error", "El permiso de ubicación esta desabilitado", 4);

      return Future.error('Location services are disabled.');
    }

    permission = await geo.Geolocator.checkPermission();
    if (permission == geo.LocationPermission.denied) {
      permission = await geo.Geolocator.requestPermission();
      if (permission == geo.LocationPermission.denied) {
        buidlDefaultFlushBar(
            context, "Error", "El permiso de ubicación esta denegado", 4);

        return Future.error('Location permissions are denied');
      }
    }

    if (permission == geo.LocationPermission.deniedForever) {
      buidlDefaultFlushBar(
          context,
          "Error",
          "El permiso de ubicación esta permanentemente denegado\n Debe de permitirlo desde la configuración de la app",
          4);
      return Future.error(
          'El permiso de ubicación esta permanentemente denegado\n Debe de permitirlo desde la configuración de la app');
    }

    return await geo.Geolocator.getCurrentPosition();
  }
}
