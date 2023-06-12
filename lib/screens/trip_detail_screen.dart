import 'dart:convert';
import 'dart:typed_data';

import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/screens/map/google_map.dart';
import 'package:driver_please_flutter/screens/trip_list_screen.dart';
import 'package:driver_please_flutter/services/ruta_viaje_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'drawer/main_drawer.dart';

class TripDetailScreen extends StatefulWidget {
  ViajeModel viaje;
  var redirect;

  TripDetailScreen({Key? key, required this.viaje, required this.redirect})
      : super(key: key);

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool openDrawer = false;
  List<Color> colorListLocal = [];
  String incidencia = "";

  final formIncidenceKey = GlobalKey<FormState>();

  List<LatLng> listLocations = [];

  Set<Marker> markers = {};

  GoogleMapController? mapController;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
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

  _getMarkers() async {
    List<RutaViajeModel> rutaViajes =
        await RutaViajeService.getViajes(context, widget.viaje.idViaje);

    Set<Marker> auxMarkers = {};

    final Uint8List markerIcon =
        await Utility.getBytesFromAsset('assets/images/pinAzul.png', 80);

    for (var element in rutaViajes) {
      auxMarkers.add(Marker(
          markerId: MarkerId(element.toString()),
          icon: BitmapDescriptor.fromBytes(markerIcon),
          draggable: false,
          position: LatLng(element.latitud, element.longitud),
          onTap: () {}));
    }
    if (mounted) {
      setState(() {
        markers = auxMarkers;
      });
    }
  }

  @override
  void initState() {
    // _getRutaViajes();
    super.initState();

    setColor();
  }

  _closeTripAlert() {
    return Alert(
        context: context,
        type: AlertType.warning,
        padding: const EdgeInsets.all(0),
        title: "¡Atención!",
        desc: "¿Estás seguro de cancelar el viaje?",
        style: AlertStyle(
            titleStyle: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 17),
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
                    children: [
                      SizedBox(
                          //height: 48,
                          child: TextFormField(
                              initialValue: "",
                              autofocus: false,
                              minLines:
                                  6, // any number you need (It works as the rows for the textarea)
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              validator: (value) =>
                                  validateField(value.toString()),
                              onChanged: (value) => _setStateColor(value, 0),
                              onSaved: (value) => incidencia = value.toString(),
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(4.0))),
                                errorStyle:
                                    GoogleFonts.poppins(color: Colors.red),
                              ),
                              style: GoogleFonts.poppins(
                                  color: colorListLocal[0]))),
                      Row(
                        children: [
                          Expanded(
                              flex: 5,
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 3, right: 3),
                                child:
                                    longButtons(Strings.labelSendTripbtn, () {
                                  _handleCloseTrip();
                                }, color: _colorFromHex(Widgets.colorPrimary)),
                              )),
                          Expanded(
                              flex: 5,
                              child: Padding(
                                  padding:
                                      const EdgeInsets.only(left: 3, right: 3),
                                  child: longButtons("Cancelar", () {
                                    Navigator.pop(context);
                                  },
                                      color: _colorFromHex(
                                          Widgets.colorSecundary))))
                        ],
                      ),
                    ],
                  ),
                ))),
        buttons: []).show();
  }

  _handleCloseTrip() {
    final form = formIncidenceKey.currentState;

    if (form!.validate()) {
      form.save();

      var formIncidence = json.encode({
        "id_viaje": widget.viaje.idViaje,
        "incidencia": incidencia,
      });

      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/saveIncidence.php"),
              formIncidence,
              {},
              "POST")
          .then((response) {
        _handleIncidenceResponse(response, context);
      });
    }
  }

  _handleIncidenceResponse(
      Map<String, dynamic> response, BuildContext context) {
    Navigator.pop(context);
    if (response["status"]) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => TripDetailScreen(
                  viaje: widget.viaje,
                  redirect: "MAIN",
                )),
        (Route<dynamic> route) => false,
      );
    } else {
      buidlDefaultFlushBar(
          context, "Error", "Ocurrió un error al registrar incidencia", 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              setState(() {
                openDrawer = true;
              });
            }
          },
          appBar: AppBar(
              title: const Text(Strings.labelDetailTrip),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
              actions: <Widget>[
                widget.viaje.status != 6
                    ? IconButton(
                        icon: const Icon(Icons.location_pin),
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      WidgetGoogleMap(viaje: widget.viaje)));
                        },
                      )
                    : const SizedBox()
              ]),
          drawer: const MainDrawer(0),
          body: Container(
            padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
            child: ListView(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 130,
                        height: 119,
                        child: CircleAvatar(
                            backgroundColor:
                                _colorFromHex(Widgets.colorPrimary),
                            radius: 16,
                            child: IconButton(
                              iconSize: 66,
                              // remove default padding here
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.directions,
                              ),
                              color: Colors.white,
                              onPressed: () {},
                            ))),
                  ],
                ),
                const SizedBox(
                  height: 31,
                ),
                buildDetailform(Strings.labelTripDate, widget.viaje.fechaViaje,
                    Strings.labelTripHour, widget.viaje.horaViaje, "1"),
                buildDetailform(
                    Strings.labelTripLocation,
                    widget.viaje.nombreSucursal,
                    Strings.labelTripCompany,
                    widget.viaje.nombreEmpresa,
                    "2"),
                buildDetailform(
                    Strings.labelTripType,
                    widget.viaje.tipo,
                    Strings.labelTripOccupants,
                    widget.viaje.ocupantes.toString(),
                    "3"),
                const SizedBox(
                  height: 32,
                ),
                buildDetailform(Strings.labelTripStatus,
                    widget.viaje.status.toString(), "", "", "4"),
                SizedBox(
                  height: 400,
                  child: GoogleMap(
                    markers: markers,
                    onMapCreated: (c) {
                      _getMarkers();
                      mapController = c;
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()),
                      Factory<ScaleGestureRecognizer>(
                          () => ScaleGestureRecognizer()),
                      Factory<TapGestureRecognizer>(
                          () => TapGestureRecognizer()),
                      Factory<EagerGestureRecognizer>(
                          () => EagerGestureRecognizer()),
                    },
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: true,
                    myLocationEnabled: true,
                    initialCameraPosition: const CameraPosition(
                        target: LatLng(28.643540, -106.061683), zoom: 14),
                    mapType: MapType.normal,
                  ),
                ),
                const SizedBox(
                  height: 32,
                ),
                widget.viaje.status != 6
                    ? longButtons("Cancelar viaje", _closeTripAlert,
                        color: _colorFromHex(Widgets.colorPrimary))
                    : const SizedBox()
              ],
            ),
          ),
        ));
  }

  Future<bool> showExitPopup() async {
    if (openDrawer) {
      setState(() {
        openDrawer = false;
      });
      Navigator.of(context).pop(false);
      return false;
    } else {
      if (widget.redirect == "MAIN") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const TripListScreen()),
          (Route<dynamic> route) => false,
        );
        return true;
      } else {
        Navigator.pop(context, true);
        return true;
      }
    }
  }
}
