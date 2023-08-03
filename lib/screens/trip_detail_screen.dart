import 'dart:convert';
import 'dart:typed_data';

import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_resumen_model.dart';
import 'package:driver_please_flutter/screens/map/google_map.dart';
import 'package:driver_please_flutter/screens/recibo_viaje_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_assigned_screen.dart';
import 'package:driver_please_flutter/services/ruta_viaje_service.dart';
import 'package:driver_please_flutter/services/viaje_resumen_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_expanded_tile/flutter_expanded_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'drawer/main_drawer.dart';

class TripDetailScreen extends StatefulWidget {
  ViajeModel viaje;
  var redirect;
  bool panelVisible;

  TripDetailScreen({Key? key, required this.viaje, required this.redirect, required this.panelVisible})
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

  List<RutaViajeModel> rutaViajes = [];
  Map<String, dynamic> viajeResumen = {};

  ExpandedTileController? _controller;

  ExpandedTileController? _controllerTarifa;

  ExpandedTileController? _controllerRecibo;

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
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    }
  }

  setColor() {
    colorListLocal = List.generate(1, (index) {
      return _colorFromHex(Widgets.colorPrimary);
    });
  }

  _getMarkers() async {
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

  _getRutaViajes() async {
    List<RutaViajeModel> auxRutaViajes =
        await RutaViajeService.getViajes(context, widget.viaje.idViaje);

    if (auxRutaViajes.isNotEmpty) {
      setState(() {
        rutaViajes = auxRutaViajes;
      });
    }
  }

  _getViajeResumen() async {
    Map<String, dynamic> auxViajeResumen =
        await ViajeResumenService.getViajeResumen(
            context, widget.viaje.idViaje);

    if (auxViajeResumen.isNotEmpty) {
      setState(() {
        viajeResumen = auxViajeResumen;
      });
    }
  }

  @override
  void initState() {
    _controller = ExpandedTileController(isExpanded: false);
    _controllerTarifa = ExpandedTileController(isExpanded: false);
    _controllerRecibo = ExpandedTileController(isExpanded: false);
    super.initState();
    _getRutaViajes();
    _getViajeResumen();
    setColor();
    Intl.defaultLocale = "es_MX";
    initializeDateFormatting();
  }

  @override
  void dispose() {
    super.dispose();
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
        "tripStatus": 6
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
                  panelVisible: true,
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
          ),
          //drawer: const MainDrawer(0),
          body: Container(
            padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
            child: ListView(
              children: [
                widget.panelVisible ? 
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 130,
                      height: 130,
                      child: ClipOval(
                        child: Material(
                          color: _colorFromHex(Widgets.colorPrimary),
                          child: InkWell(
                            splashColor:
                                _colorFromHex(Widgets.colorSecundayLight),

                            onTap: () {
                              if (widget.viaje.status == 3 ||
                                  widget.viaje.status == 6) {
                                return;
                              }

                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => WidgetGoogleMap(
                                            viaje: widget.viaje,
                                            rutaViaje: rutaViajes,
                                          )));
                            },
                            // button pressed
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                const Icon(
                                  Icons.moving_sharp,
                                  color: Colors.white,
                                  size: 40,
                                ), // icon
                                Text(
                                  setStatusTrip(widget.viaje.status),
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.white),
                                ), // text
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  
                  const SizedBox(
                  height: 31,
                ),
                  ],
                ) : SizedBox(),
                
                buildDetailform(
                    Strings.labelTripDate,
                    getFormattedDateFromFormattedString(
                        widget.viaje.fechaViaje),
                    Strings.labelTripHour,
                    widget.viaje.horaViaje,
                    "1"),
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
                buildDetailform(
                    Strings.labelTripStatus,
                    Utility.setStatusTrip(widget.viaje.status.toString()),
                    "",
                    "",
                    "4"),
                const SizedBox(
                  height: 13,
                ),
                buildDetailform(
                    Strings.labelTripInicialDate,
                    widget.viaje.fechaInicio,
                    Strings.labelTripEndDate,
                    widget.viaje.fechaFin,
                    "5"),
                const SizedBox(
                  height: 13,
                ),
                viajeResumen["estatus"].toString() == "3" ||
                        viajeResumen["estatus"].toString() == "6"
                    ? ExpandedTile(
                        theme: ExpandedTileThemeData(
                          headerColor:
                              _colorFromHex(Widgets.colorSecundayLight),
                          headerRadius: 5.0,
                          headerPadding: const EdgeInsets.all(10),
                          headerSplashColor:
                              _colorFromHex(Widgets.colorPrimary),
                          contentBackgroundColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(0),
                          contentRadius: 2.0,
                        ),
                        controller: _controllerRecibo!,
                        title: Text(
                          "Recibo de pago",
                          style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary),
                            fontSize: 16,
                          ),
                        ),
                        content: SizedBox(),
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReciboViajeScreen(
                                        viajeResumen: viajeResumen,
                                      )));
                        },
                      )
                    : SizedBox(),
                const SizedBox(
                  height: 13,
                ),
                ExpandedTile(
                  theme: ExpandedTileThemeData(
                    headerColor: _colorFromHex(Widgets.colorSecundayLight),
                    headerRadius: 5.0,
                    headerPadding: const EdgeInsets.all(10),
                    headerSplashColor: _colorFromHex(Widgets.colorPrimary),
                    contentBackgroundColor: Colors.transparent,
                    contentPadding: const EdgeInsets.all(0),
                    contentRadius: 2.0,
                  ),
                  controller: _controller!,
                  title: Text(
                    Strings.labelTripItinerario,
                    style: TextStyle(
                      color: _colorFromHex(Widgets.colorPrimary),
                      fontSize: 16,
                    ),
                  ),
                  content: SingleChildScrollView(
                    physics: const ScrollPhysics(),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        ListView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Card(
                              child: ListTile(
                                leading: Column(
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

                                    if (validateNullOrEmptyString(
                                            rutaViajes[index]
                                                .hora) !=
                                        null) ...[
                                      Text(
                                        "Hora " +
                                            rutaViajes[index].hora,
                                        style: TextStyle(
                                            color: _colorFromHex(
                                                Widgets.colorPrimary),
                                            fontSize: 15),
                                      ),
                                    ],
                                  ],
                                ),
                                title: Text(
                                  rutaViajes[index].personaNombre,
                                  style: TextStyle(
                                      color:
                                          _colorFromHex(Widgets.colorPrimary),
                                      fontSize: 14),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.phone),
                                  color: _colorFromHex(Widgets.colorPrimary),
                                  onPressed: validateNullOrEmptyString(
                                              rutaViajes[index]
                                                  .personaTelefono) !=
                                          null
                                      ? () async {
                                          Uri link = Uri(
                                            scheme: 'tel',
                                            path: rutaViajes[index]
                                                .personaTelefono,
                                          );

                                          try {
                                            if (await canLaunchUrl(link)) {
                                              await launchUrl(link,
                                                  mode: LaunchMode
                                                      .externalApplication);
                                            } else {
                                              MotionToast.error(
                                                      title:
                                                          const Text("Error"),
                                                      description: const Text(
                                                          "No se puede abrir el enlace"))
                                                  .show(context);
                                            }
                                          } catch (error) {
                                            print("AKIII");
                                            print(error);
                                            MotionToast.error(
                                                    title: const Text("Error"),
                                                    description: const Text(
                                                        "Error No se puede abrir el enlace"))
                                                .show(context);
                                          }
                                        }
                                      : null,
                                ),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 5),
                                    if (validateNullOrEmptyString(
                                            rutaViajes[index].nombreSucursal) !=
                                        null) ...[
                                      Text(
                                        "Pertenece " +
                                            rutaViajes[index].nombreSucursal,
                                        style: TextStyle(
                                            color: _colorFromHex(
                                                Widgets.colorPrimary),
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 5),
                                    ] else ...[
                                      const SizedBox(),
                                    ],
                                    Text(
                                      "Domicilio " +
                                          rutaViajes[index].direccion,
                                      style: TextStyle(
                                          color: _colorFromHex(
                                              Widgets.colorPrimary),
                                          fontSize: 12),
                                    ),
                                    const SizedBox(height: 5),
                                    if (validateNullOrEmptyString(
                                            rutaViajes[index]
                                                .personaTelefono) !=
                                        null) ...[
                                      Text(
                                        "Contacto " +
                                            rutaViajes[index].personaTelefono,
                                        style: TextStyle(
                                            color: _colorFromHex(
                                                Widgets.colorPrimary),
                                            fontSize: 12),
                                      ),
                                    ],
                                    
                                   
                                  ],
                                ),
                              ),
                            );
                          },
                          itemCount: rutaViajes.length,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 13,
                ),
                
                widget.panelVisible ?
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
                )
                : SizedBox() ,
                  widget.panelVisible ? const SizedBox(
                  height: 32,
                ) : SizedBox(),
                (widget.viaje.status == 1 || widget.viaje.status == 2) && widget.panelVisible  == true
                    ? longButtons("Cancelar viaje", _closeTripAlert,
                        color: _colorFromHex(Widgets.colorPrimary))
                    : const SizedBox(),
                const SizedBox(
                  height: 32,
                ),
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
          MaterialPageRoute(
              builder: (context) => const TripListAssignedScreen()),
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
