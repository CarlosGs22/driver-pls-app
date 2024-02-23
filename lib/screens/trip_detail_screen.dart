import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:camera/camera.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/dashboard_screen.dart';
import 'package:driver_please_flutter/screens/map/google_map.dart';
import 'package:driver_please_flutter/screens/preview_evidence.dart';
import 'package:driver_please_flutter/screens/recibo_viaje_screen.dart';
import 'package:driver_please_flutter/screens/start_trip.dart';
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
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;

class TripDetailScreen extends StatefulWidget {
  ViajeModel viaje;
  var redirect;
  bool panelVisible;
  bool bandCancelTrip;

  TripDetailScreen(
      {Key? key,
      required this.viaje,
      required this.redirect,
      required this.panelVisible,
      required this.bandCancelTrip})
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

  ExpandedTileController? _controllerIncidencia;

  ExpandedTileController? _controllerNota;

  late CameraController _camController;
  List<CameraDescription>? cameras;

  bool onLoadingCam = false;

  Position? position;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  String locationName = "NA";

  Future<void> getLocationName() async {
    try {
      Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        position = pos;
      });

      List<Placemark> placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks[0];
        String street = placemark.street!;
        String subLocality = placemark.subLocality!;
        String locality = placemark.locality!;
        String administrativeArea = placemark.administrativeArea!;
        String country = placemark.country!;

        String completeAddress =
            "$street,$subLocality, $locality, $administrativeArea, $country";
        setState(() {
          locationName = completeAddress;
        });
      } else {
        setState(() {
          locationName = "Dirección no encontrada";
        });
      }
    } catch (e) {
      setState(() {
        locationName = "Error: $e";
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


  _getRutaViajes() async {
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    List<RutaViajeModel> auxRutaViajes = await RutaViajeService.getViajes(
        context, widget.viaje.idViaje,
        path: cliente.path);

    if (auxRutaViajes.isNotEmpty) {
      setState(() {
        rutaViajes = auxRutaViajes;
      });
    }
  }

  _getViajeResumen() async {
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    Map<String, dynamic> auxViajeResumen =
        await ViajeResumenService.getViajeResumen(context, widget.viaje.idViaje,
            path: cliente.path);

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
    _controllerIncidencia = ExpandedTileController(isExpanded: false);
    _controllerNota = ExpandedTileController(isExpanded: false);

    super.initState();
    _getRutaViajes();
    _getViajeResumen();
    setColor();
    Intl.defaultLocale = "es_MX";
    initializeDateFormatting();
  _initializeCamera();

    getLocationName();
  }

  @override
  void dispose() {
   
    _camController.dispose();
 

    super.dispose();
  }

  Future<File> _takePicture() async {
    if (!_camController.value.isInitialized) {
      return File("");
    }

    try {
      final XFile imageFile = await _camController.takePicture();
      File capturedImage = File(imageFile.path);
      return capturedImage;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir evidencia'),
        ),
      );
      return File("");
    }
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
            child: Form(
              key: formIncidenceKey,
              child: Column(
                children: [
                  SizedBox(
                      //height: 48,
                      child: //height: 48,
                          Padding(
                              padding: EdgeInsets.only(top: 13, bottom: 13),
                              child: TextFormField(
                                  initialValue: "",
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
                                    fillColor:
                                        _colorFromHex(Widgets.colorWhite),
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
                                      color: colorListLocal[0])))),
                  Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3),
                              child: longButtons("Cancelar", () {
                                Navigator.pop(context);
                              },
                                  color: _colorFromHex(Widgets.colorWhite),
                                  textColor:
                                      _colorFromHex(Widgets.colorPrimary)))),
                      Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: longButtons(Strings.labelSendTripbtn, () {
                              _handleCloseTrip();
                            }, color: _colorFromHex(Widgets.colorPrimary)),
                          )),
                    ],
                  ),
                ],
              ),
            )),
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

      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      HttpClass.httpData(
              context,
              Uri.parse(cliente.path + "aplicacion/saveIncidence.php"),
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
      widget.viaje.status = 6;
      widget.viaje.confirmado = "2";
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

  _sendRequestOnConfirm(
      var formParams, var option, ViajeModel viaje, var redirec) {
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    HttpClass.httpData(
            context,
            Uri.parse(cliente.path + "aplicacion/confirmViaje.php"),
            formParams,
            {},
            "POST")
        .then((response) {
      if (response["status"] && response["data"] != null) {
        Navigator.pop(context);

        if (redirec == "1") {
          widget.viaje.status = 1;
          widget.viaje.confirmado = "2";

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TripDetailScreen(
                        panelVisible: true,
                        viaje: widget.viaje,
                        redirect: "MAIN",
                        bandCancelTrip: true,
                      )));
        } else {
          widget.viaje.status = 6;
          widget.viaje.confirmado = "3";

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dashboard()),
            (Route<dynamic> route) => false,
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocurrió un error'),
          ),
        );
      }
    });
  }

  _handleOnConfirmTrip(var idViaje, ViajeModel viaje) {
    return Alert(
        context: context,
        type: AlertType.warning,
        padding: const EdgeInsets.all(0),
        title: "¡Atención!",
        desc: "¿Aceptar viaje?",
        style: AlertStyle(
            titleStyle: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 17),
            descStyle: TextStyle(
                color: _colorFromHex(Widgets.colorPrimary), fontSize: 15)),
        content: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: _colorFromHex(Widgets.colorWhite),
                borderRadius: const BorderRadius.all(
                  Radius.circular(20.0),
                ),
              ),
              //width: width * 0.9,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                          flex: 5,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3),
                              child: longButtons("Rechazar", () {
                                var option = "3";
                                var formParams = {
                                  "id_viaje": idViaje,
                                  "opcion": option
                                };
                                _sendRequestOnConfirm(
                                    formParams, option, viaje, "2");
                              },
                                  color: _colorFromHex(Widgets.colorWhite),
                                  textColor:
                                      _colorFromHex(Widgets.colorPrimary)))),
                      Expanded(
                          flex: 5,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 3, right: 3),
                            child: longButtons("Aceptar", () {
                              var option = "2";
                              var formParams = {
                                "id_viaje": idViaje,
                                "opcion": option
                              };
                              _sendRequestOnConfirm(
                                  formParams, option, viaje, "1");
                            }, color: _colorFromHex(Widgets.colorPrimary)),
                          )),
                    ],
                  ),
                ],
              ),
            )),
        buttons: []).show();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    final firstCamera = cameras!.first;

    _camController = CameraController(
      firstCamera,
      ResolutionPreset.ultraHigh,
    );

    await _camController.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  _handleCondition(File evidence, RutaViajeModel rutaViajeModel) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () async {
            return false;
          },
          child: AlertDialog(
            title: Center(
              child: Text(
                '¿Estás seguro de enviar esta evidencia?',
                style: TextStyle(
                  fontSize: 24.0,
                  color: _colorFromHex(Widgets.colorPrimary),
                ),
              ),
            ),
            content: SizedBox(
              height: 139,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment
                    .center, // Centra verticalmente el contenido
                children: [
                  Text(
                    "Esta opción no se puede restablecer",
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      color: _colorFromHex(Widgets.colorGray),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Centra los botones horizontalmente
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 4,
                          right: 4,
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            if (onLoadingCam) {
                              return;
                            }
                            _camController.resumePreview();
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Cancelar",
                              style: TextStyle(
                                color: _colorFromHex(Widgets.colorPrimary),
                                fontSize: 20.0,
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
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 4, right: 4),
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              onLoadingCam = true;
                            });

                            _handleSendEvidence(evidence, rutaViajeModel);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              "Aceptar",
                              style: TextStyle(
                                color: _colorFromHex(Widgets.colorWhite),
                                fontSize: 18.0,
                              ),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            primary: _colorFromHex(Widgets.colorPrimary),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _handleSendEvidence(File evidence, RutaViajeModel rutaViajeModel) async {
    try {
      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      Navigator.pop(context);
      Navigator.pop(context);

      setState(() {
        onLoadingCam = true;
      });

      double latitude = position!.latitude;
      double longitude = position!.longitude;

      // Procesa la imagen y agrega la marca de tiempo
      img.Image? image = img.decodeImage(evidence.readAsBytesSync());
      img.drawString(image!, img.arial_24, 10, 10,
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()),
          color: img.getColor(255, 255, 255, 1));
      File processedImageFile = File(evidence.path);
      await processedImageFile
          .writeAsBytes(Uint8List.fromList(img.encodePng(image)));

      // Luego, aquí puedes enviar la imagen al servidor como lo hacías antes.
      var request = http.MultipartRequest(
          'POST', Uri.parse(cliente.path + "aplicacion/evidencia.php"));
      request.files.add(await http.MultipartFile.fromPath(
          'evidencia', processedImageFile.path));

      request.fields['idRuta'] = rutaViajeModel.idRuta;
      request.fields['idViaje'] = rutaViajeModel.idViaje;
      request.fields['poligono'] = [latitude, longitude].toString();

      var response = await request.send();

      if (response.statusCode == 200) {
        setState(() {
          onLoadingCam = false;
          rutaViajeModel.evidencia = evidence.path;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Evidencia cargada con éxito'),
          ),
        );
        print("IMAGEN CARGADA");
        print(evidence.path);
        print(rutaViajeModel.idViaje);
        print("RUTA" + rutaViajeModel.idRuta);
      } else {
        setState(() {
          onLoadingCam = false;
        });

        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al subir imagen'),
          ),
        );
      }
    } catch (e) {
      setState(() {
        onLoadingCam = false;
      });
      print("Error al procesar la imagen: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    List<LatLng> listaLatLong = [];

    if (validateNullOrEmptyString(widget.viaje.poligono) != null) {
      listaLatLong = (json.decode(widget.viaje.poligono) as List<dynamic>)
          .map<LatLng>((dynamic coords) => LatLng(coords[0], coords[1]))
          .toList();
    }

    _handleShowCamara(RutaViajeModel rutaViajeModel) {
      _camController.resumePreview();

      showFlexibleBottomSheet(
        minHeight: 0,
        initHeight: 0.96,
        maxHeight: 1,
        context: context,
        builder: (context, scrollController, bottomSheetOffset) {
          return Scaffold(
            appBar: AppBar(
              title: Text("Evidencia"),
              titleTextStyle: GoogleFonts.poppins(
                  fontSize: 19,
                  color: _colorFromHex(Widgets.colorWhite),
                  fontWeight: FontWeight.w500),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
              actions: [],
            ),
            body: Stack(
              alignment: Alignment.center,
              children: [
                CameraPreview(_camController),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Fecha: ${DateFormat('dd-MM-yyyy HH:mm').format(DateTime.now())}',
                        style: TextStyle(
                          color: _colorFromHex(Widgets.colorWhite),
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Ubicación: ' + locationName,
                        style: TextStyle(
                          color: _colorFromHex(Widgets.colorWhite),
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
              onPressed: () async {
                File evidence = await _takePicture();
                _camController.pausePreview();

                if (evidence.existsSync() &&
                    evidence.readAsBytesSync().isNotEmpty) {
                  _handleCondition(evidence, rutaViajeModel);
                }
              },
              child: onLoadingCam
                  ? buildCircularProgress(context)
                  : Icon(Icons.camera,
                      color: _colorFromHex(Widgets.colorWhite)),
            ),
          );
        },
        anchors: [0, 0.5, 1],
      );
    }

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
          backgroundColor: _colorFromHex(Widgets.colorGrayBackground),
          appBar: AppBar(
            title: const Text(Strings.labelDetailTrip),
            elevation: 0.1,
            backgroundColor: _colorFromHex(Widgets.colorPrimary),
          ),
          //drawer: const MainDrawer(0),
          body: onLoadingCam
              ? buildCircularProgress(context)
              : Container(
                  padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
                  child: ListView(
                    children: [
                      widget.panelVisible
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 130,
                                  height: 130,
                                  child: ClipOval(
                                    child: Material(
                                      color:
                                          _colorFromHex(Widgets.colorPrimary),
                                      child: InkWell(
                                        splashColor: _colorFromHex(
                                            Widgets.colorSecundayLight),

                                        onTap: () {
                                          if (widget.viaje.status == 3 ||
                                              widget.viaje.status == 6) {
                                            return;
                                          }

                                          if (widget.viaje.status == 1 &&
                                              widget.viaje.confirmado == "2") {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        WidgetGoogleMap(
                                                          viaje: widget.viaje,
                                                          rutaViaje: rutaViajes,
                                                        )));

                                            // Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //         builder: (context) =>
                                            //             StartTrip(viaje: widget.viaje)));
                                          } else {
                                            _handleOnConfirmTrip(
                                                widget.viaje.idViaje,
                                                widget.viaje);
                                          }
                                        },
                                        // button pressed
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Icon(
                                              Icons.moving_sharp,
                                              color: _colorFromHex(
                                                  Widgets.colorWhite),
                                              size: 40,
                                            ), // icon
                                            Text(
                                              setStatusTrip(
                                                  widget.viaje.status
                                                      .toString(),
                                                  widget.viaje.confirmado
                                                      .toString()),
                                              style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w500,
                                                  color: _colorFromHex(
                                                      Widgets.colorWhite)),
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
                            )
                          : SizedBox(),
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
                          Strings.labelTripId,
                          widget.viaje.idViaje,
                          Strings.labelTripStatus,
                          setStatusTrip(widget.viaje.status.toString(),
                              widget.viaje.confirmado.toString()),
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
                                    _colorFromHex(Widgets.colorPrimary),
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
                                  color: _colorFromHex(Widgets.colorWhite),
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
                          headerColor: _colorFromHex(Widgets.colorPrimary),
                          headerRadius: 5.0,
                          headerPadding: const EdgeInsets.all(10),
                          headerSplashColor:
                              _colorFromHex(Widgets.colorPrimary),
                          contentBackgroundColor: Colors.transparent,
                          contentPadding: const EdgeInsets.all(0),
                          contentRadius: 2.0,
                        ),
                        controller: _controller!,
                        title: Text(
                          Strings.labelTripItinerario,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _colorFromHex(Widgets.colorWhite),
                            fontSize: 17,
                          ),
                        ),
                        content: SingleChildScrollView(
                          physics: const ScrollPhysics(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Card(
                                    color: _colorFromHex(Widgets.colorPrimary),
                                    child: ListTile(
                                      leading: Container(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Parada " +
                                                  (index + 1).toString(),
                                              style: TextStyle(
                                                  color: _colorFromHex(
                                                      Widgets.colorWhite),
                                                  fontSize: 14),
                                            ),
                                            Icon(
                                              Icons.room_outlined,
                                              size: 16,
                                              color: _colorFromHex(
                                                  Widgets.colorWhite),
                                            ),
                                            if (validateNullOrEmptyString(
                                                    rutaViajes[index].hora) !=
                                                null) ...[
                                              Text(
                                                "Hora " +
                                                    rutaViajes[index].hora,
                                                style: TextStyle(
                                                    color: _colorFromHex(
                                                        Widgets.colorWhite),
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ],
                                        ),
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
                                                  rutaViajes[index]
                                                      .personaNombre,
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 5),
                                          if (validateNullOrEmptyString(
                                                  rutaViajes[index].parada1) !=
                                              null) ...[
                                            Text(
                                              "Pertenece " +
                                                  rutaViajes[index]
                                                      .nombreEmpresa,
                                              style: TextStyle(
                                                  color: _colorFromHex(
                                                      Widgets.colorWhite),
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(height: 5),
                                          ] else ...[
                                            Text(
                                              "Pertenece " +
                                                  rutaViajes[index]
                                                      .nombreSucursal,
                                              style: TextStyle(
                                                  color: _colorFromHex(
                                                      Widgets.colorWhite),
                                                  fontSize: 12),
                                            ),
                                            const SizedBox(),
                                          ],
                                          Text(
                                            "Domicilio " +
                                                rutaViajes[index].direccion,
                                            style: TextStyle(
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                fontSize: 12),
                                          ),
                                          const SizedBox(height: 5),
                                          if ( validateNullOrEmptyString(rutaViajes[index]
                                                      .tipoDestino) != "SUC" &&  validateNullOrEmptyString(rutaViajes[index]
                                                      .tipoDestino) != null)
                                              ...[
                                            Text(
                                              "Contacto " +
                                                  rutaViajes[index]
                                                      .personaTelefono,
                                              style: TextStyle(
                                                  color: _colorFromHex(
                                                      Widgets.colorWhite),
                                                  fontSize: 12),
                                            ),
                                          ],
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              validateNullOrEmptyString(rutaViajes[index]
                                                      .tipoDestino) != "SUC" &&  validateNullOrEmptyString(rutaViajes[index]
                                                      .tipoDestino) != null ?
                                              IconButton(
                                                icon: const Icon(Icons.phone),
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                onPressed:
                                                    validateNullOrEmptyString(
                                                                rutaViajes[
                                                                        index]
                                                                    .personaTelefono) !=
                                                            null
                                                        ? () async {
                                                            Uri link = Uri(
                                                              scheme: 'tel',
                                                              path: rutaViajes[
                                                                      index]
                                                                  .personaTelefono,
                                                            );

                                                            try {
                                                              if (await canLaunchUrl(
                                                                  link)) {
                                                                await launchUrl(
                                                                    link,
                                                                    mode: LaunchMode
                                                                        .externalApplication);
                                                              } else {
                                                                MotionToast.error(
                                                                        title: const Text(
                                                                            "Error"),
                                                                        description:
                                                                            const Text(
                                                                                "No se puede abrir el enlace"))
                                                                    .show(
                                                                        context);
                                                              }
                                                            } catch (error) {
                                                              print("AKIII");
                                                              print(error);
                                                              MotionToast.error(
                                                                      title: const Text(
                                                                          "Error"),
                                                                      description:
                                                                          const Text(
                                                                              "Error No se puede abrir el enlace"))
                                                                  .show(
                                                                      context);
                                                            }
                                                          }
                                                        : null,
                                              )
                                              : SizedBox(),
                                              
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.alt_route_outlined),
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                onPressed: validateNullOrEmptyString(
                                                                rutaViajes[
                                                                        index]
                                                                    .latitud) !=
                                                            null &&
                                                        validateNullOrEmptyString(
                                                                rutaViajes[
                                                                        index]
                                                                    .longitud) !=
                                                            null
                                                    ? () async {
                                                        double lat =
                                                            rutaViajes[index]
                                                                .latitud;
                                                        double lng =
                                                            rutaViajes[index]
                                                                .longitud;

                                                        Uri url = Uri.parse(
                                                            'geo:${lat},${lng}?q=${lat},${lng}');

                                                        try {
                                                          if (await canLaunchUrl(
                                                              url)) {
                                                            await launchUrl(url,
                                                                mode: LaunchMode
                                                                    .externalApplication);
                                                          } else {
                                                            MotionToast.error(
                                                                    title: const Text(
                                                                        "Error"),
                                                                    description:
                                                                        const Text(
                                                                            "No se puede abrir el enlace"))
                                                                .show(context);
                                                          }
                                                        } catch (error) {
                                                          print("AKIII");
                                                          print(error);
                                                          MotionToast.error(
                                                                  title: const Text(
                                                                      "Error"),
                                                                  description:
                                                                      const Text(
                                                                          "Error No se puede abrir el enlace"))
                                                              .show(context);
                                                        }
                                                      }
                                                    : null,
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.message),
                                                color: _colorFromHex(
                                                    Widgets.colorWhite),
                                                onPressed:
                                                    validateNullOrEmptyString(
                                                                rutaViajes[
                                                                        index]
                                                                    .personaTelefono) !=
                                                            null
                                                        ? () async {
                                                            try {
                                                              String appUrl;
                                                              String phone =
                                                                  rutaViajes[
                                                                          index]
                                                                      .personaTelefono;

                                                              String hour =
                                                                  rutaViajes[
                                                                          index]
                                                                      .hora;

                                                              String message =
                                                                  'Que tal soy su driver que pasará por usted a su domicilio en el horario de {$hour}, para llevarle a su trabajo. ';
                                                              if (Platform
                                                                  .isAndroid) {
                                                                appUrl =
                                                                    "whatsapp://send?phone=$phone&text=${Uri.encodeComponent(message)}";
                                                              } else {
                                                                appUrl =
                                                                    "https://api.whatsapp.com/send?phone=$phone=${Uri.encodeComponent(message)}";
                                                              }

                                                              if (await canLaunchUrl(
                                                                  Uri.parse(
                                                                      appUrl))) {
                                                                await launchUrl(
                                                                    Uri.parse(
                                                                        appUrl));
                                                              } else {
                                                                MotionToast.error(
                                                                        title: const Text(
                                                                            "Error"),
                                                                        description:
                                                                            const Text(
                                                                                "Error No se puede abrir WhatsApp"))
                                                                    .show(
                                                                        context);
                                                              }
                                                            } catch (error) {
                                                              print("AKIII");
                                                              print(error);
                                                              MotionToast.error(
                                                                      title: const Text(
                                                                          "Error"),
                                                                      description:
                                                                          const Text(
                                                                              "Error No se puede abrir el enlace"))
                                                                  .show(
                                                                      context);
                                                            }
                                                          }
                                                        : null,
                                              ),
                                              validateNullOrEmptyString(
                                                          rutaViajes[index]
                                                              .evidencia) ==
                                                      null
                                                  ? IconButton(
                                                      icon: const Icon(
                                                          Icons.image),
                                                      color: _colorFromHex(
                                                          Widgets.colorWhite),
                                                      onPressed: () {
                                                        _handleShowCamara(
                                                            rutaViajes[index]);
                                                      },
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
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

                      //INCIDENCIAS
                      widget.viaje.status == 3 || widget.viaje.status == 6
                          ? ExpandedTile(
                              theme: ExpandedTileThemeData(
                                headerColor:
                                    _colorFromHex(Widgets.colorPrimary),
                                headerRadius: 5.0,
                                headerPadding: const EdgeInsets.all(10),
                                headerSplashColor:
                                    _colorFromHex(Widgets.colorPrimary),
                                contentBackgroundColor: Colors.transparent,
                                contentPadding: const EdgeInsets.all(0),
                                contentRadius: 2.0,
                              ),
                              controller: _controllerIncidencia!,
                              title: Text(
                                "Incidencias",
                                style: TextStyle(
                                  color: _colorFromHex(Widgets.colorWhite),
                                  fontSize: 16,
                                ),
                              ),
                              content: SingleChildScrollView(
                                  physics: const ScrollPhysics(),
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Card(
                                              child: validateNullOrEmptyString(
                                                          widget.viaje
                                                              .incidencias) !=
                                                      null
                                                  ? Text(
                                                      widget.viaje.incidencias,
                                                      style: TextStyle(
                                                          color: _colorFromHex(
                                                              Widgets
                                                                  .colorPrimary),
                                                          fontSize: 16),
                                                    )
                                                  : SizedBox())
                                        ],
                                      ))),
                            )
                          : SizedBox(),

                      const SizedBox(
                        height: 13,
                      ),

                      validateNullOrEmptyString(widget.viaje.descripcion) !=
                              null
                          ? ExpandedTile(
                              theme: ExpandedTileThemeData(
                                headerColor:
                                    _colorFromHex(Widgets.colorPrimary),
                                headerRadius: 5.0,
                                headerPadding: const EdgeInsets.all(10),
                                headerSplashColor:
                                    _colorFromHex(Widgets.colorPrimary),
                                contentBackgroundColor: Colors.transparent,
                                contentPadding: const EdgeInsets.all(0),
                                contentRadius: 2.0,
                              ),
                              controller: _controllerNota!,
                              title: Text(
                                "Nota",
                                style: TextStyle(
                                  color: _colorFromHex(Widgets.colorWhite),
                                  fontSize: 16,
                                ),
                              ),
                              content: SingleChildScrollView(
                                  physics: const ScrollPhysics(),
                                  child: Padding(
                                      padding: EdgeInsets.all(10),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Card(
                                              child: validateNullOrEmptyString(
                                                          widget.viaje
                                                              .descripcion) !=
                                                      null
                                                  ? Text(
                                                      widget.viaje.descripcion,
                                                      style: TextStyle(
                                                          color: _colorFromHex(
                                                              Widgets
                                                                  .colorPrimary),
                                                          fontSize: 16),
                                                    )
                                                  : SizedBox())
                                        ],
                                      ))),
                            )
                          : SizedBox(),

                      SizedBox(height: 13),

                      widget.bandCancelTrip
                          ? (widget.viaje.status == 1 ||
                                      widget.viaje.status == 2) &&
                                  widget.panelVisible == true
                              ? longButtons(
                                  "RECHAZAR ASIGNACIÓN", _closeTripAlert,
                                  color: _colorFromHex(Widgets.colorPrimary),
                                  textColor: _colorFromHex(Widgets.colorWhite))
                              : const SizedBox()
                          : const SizedBox(),
                      const SizedBox(
                        height: 13,
                      ),

                      widget.panelVisible
                          ? listaLatLong.isEmpty
                              ? const SizedBox()
                              : SizedBox(
                                  height: 400,
                                  child: GoogleMap(
                                    markers: {
                                      Marker(
                                          markerId: const MarkerId("INICIO"),
                                          infoWindow: const InfoWindow(
                                              title: ("Inicio")),
                                          //icon: BitmapDescriptor.fromBytes(Bit),
                                          position: listaLatLong.first,
                                          onTap: () {}),
                                      Marker(
                                          markerId: const MarkerId("FIN"),
                                          infoWindow:
                                              const InfoWindow(title: ("FIN")),
                                          //icon: BitmapDescriptor.fromBytes(Bit),
                                          position: listaLatLong.last,
                                          onTap: () {})
                                    },
                                    onMapCreated: (c) {
                                      mapController = c;
                                    },
                                    polylines: {
                                      Polyline(
                                        polylineId: const PolylineId('Ruta'),
                                        color: _colorFromHex(
                                            Widgets.colorSecundayLight2),
                                        points: listaLatLong,
                                      ),
                                    },
                                    gestureRecognizers: <
                                        Factory<OneSequenceGestureRecognizer>>{
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
                                    initialCameraPosition: CameraPosition(
                                        target: listaLatLong.last, zoom: 12),
                                    mapType: MapType.normal,
                                  ),
                                )
                          : SizedBox(),
                      widget.panelVisible
                          ? const SizedBox(
                              height: 32,
                            )
                          : SizedBox(),

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
