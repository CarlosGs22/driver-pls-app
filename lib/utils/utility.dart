import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart'; //for date format
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Utility {
  static const String googleMapAPiKey =
      "AIzaSyDp86KOchjHALKYuRNmEBVUXP0vMrOMf-o";

  static printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    } else {
      return false;
    }
  }

  static String convertirAFormatoHoraMinutoSegundo(double valorDecimal) {
    // Obtener la parte entera y decimal del valor
    int horas = valorDecimal.toInt();
    double minutosDecimal = (valorDecimal - horas) * 60;
    int minutos = minutosDecimal.toInt();
    int segundos = ((minutosDecimal - minutos) * 60).toInt();

    // Formatear el tiempo en una cadena en el formato HH:mm:ss
    String tiempoFormateado =
        '${horas.toString().padLeft(2, '0')}:${minutos.toString().padLeft(2, '0')}:${segundos.toString().padLeft(2, '0')}';

    return tiempoFormateado;
  }

  static String convertirMinutosAHorasYSegundos(double minutos) {
    // Calcular horas, minutos y segundos
    int horas = minutos.floor();
    int minutosRestantes = ((minutos - horas) * 60).floor();
    int segundos = ((minutos - horas) * 3600 % 60).round();

    // Formatear la salida
    String resultado = '$horas horas ';
    if (minutosRestantes > 0) {
      resultado += '$minutosRestantes minutos ';
    }
    if (segundos > 0) {
      resultado += '$segundos segundos';
    }

    return resultado;
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static getCurrentDate() {
    return DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  static setStatusTrip(var status) {
    print(status);
    var res = "";
    switch (status) {
      case "1":
        res = "Por realizar";
        break;
      case "2":
        res = "Iniciado";
        break;
      case "3":
        res = "Realizado";
        break;
      case "6":
        res = "Cancelado";
        break;
      default:
        res = "NA";
    }

    return res;
  }
}

getFormattedDateFromFormattedString(var value) {
  try {
    return DateFormat.yMMMMEEEEd().format(DateTime.parse(value));
  } catch (e) {
    return value;
  }
}

setFormatDatetime(String originalDateTime) {
  try {
    DateTime dateTime = DateTime.parse(originalDateTime);
    String formattedDate = DateFormat('dd MMMM y HH:mm:ss').format(dateTime);

    return formattedDate;
  } catch (e) {
    return originalDateTime;
  }
}

setFormatDate(String originalDate) {
  try {
    DateTime date = DateTime.parse(originalDate);
    String formattedDate = DateFormat('dd MMMM y', 'es').format(date);
    return formattedDate;
  } catch (e) {
    return originalDate;
  }
}

String formatTimeSeconds(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds ~/ 60) % 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = (hours < 10) ? '0$hours' : '$hours';
  String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
  String secondsStr =
      (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';

  return '$hoursStr:$minutesStr:$secondsStr';
}

String formatTimeMinutes(double totalMinutes) {
  print("34344" + totalMinutes.toString());

  int horas = totalMinutes ~/ 60;
  int minutos = (totalMinutes % 60).toInt();
  int segundos = ((totalMinutes * 60) % 60).toInt();

  String horasStr = (horas < 10) ? '0$horas' : '$horas';
  String minutosStr = (minutos < 10) ? '0$minutos' : '$minutos';
  String segundosStr = (segundos < 10) ? '0$segundos' : '$segundos';

  return '$horasStr:$minutosStr:$segundosStr';
}

sendRequestTrip(var idViaje, BuildContext context) {
  final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;

  var formParams = {
    "id_viaje": idViaje,
  };
  HttpClass.httpData(
          context,
          Uri.parse(cliente.path + "aplicacion/startViaje.php"),
          formParams,
          {},
          "POST")
      .then((response) {
    print("CAMBIO DE STATUS DE VIAJE");
    print(response);
  });
}

double calcularDistanciaTotal(List<LatLng> polylineCoordinates) {
  double distanciaTotal = 0.0;

  for (int i = 0; i < polylineCoordinates.length - 1; i++) {
    LatLng puntoActual = polylineCoordinates[i];
    LatLng siguientePunto = polylineCoordinates[i + 1];

    double distanciaEntrePuntos = _calcularDistanciaEntreDosPuntos(
        puntoActual.latitude,
        puntoActual.longitude,
        siguientePunto.latitude,
        siguientePunto.longitude);

    distanciaTotal += distanciaEntrePuntos;
  }

  return distanciaTotal;
}

double _calcularDistanciaEntreDosPuntos(
    double lat1, double lon1, double lat2, double lon2) {
  const radioTierra = 6371.0; // Radio de la Tierra en kilómetros

  double dLat = _gradosARadianes(lat2 - lat1);
  double dLon = _gradosARadianes(lon2 - lon1);

  double a = sin(dLat / 2) * sin(dLat / 2) +
      cos(_gradosARadianes(lat1)) *
          cos(_gradosARadianes(lat2)) *
          sin(dLon / 2) *
          sin(dLon / 2);

  double c = 2 * atan2(sqrt(a), sqrt(1 - a));

  double distancia = radioTierra * c;

  return distancia;
}

double _gradosARadianes(double grados) {
  return grados * pi / 180.0;
}

List<LatLng> decodePolyline(String polylineString) {
  List<LatLng> polylineCoordinates = [];
  if (validateNullOrEmptyString(polylineString) == null) {
    print("VACIOOO");
    return polylineCoordinates;
  }

  List<dynamic> data = json.decode(polylineString);

  for (var element in data) {
    if (element.length == 2) {
      try {
        double lat = element[0].toDouble();
        double lng = element[1].toDouble();
        polylineCoordinates.add(LatLng(lat, lng));
      } catch (e) {
        print('ERRORRRR al convertir coordenadas a double: $e');
      }
    } else {
      print(
          'ERRORRRR Formato incorrecto de coordenadas en la cadena de polilínea.');
    }
  }

  return polylineCoordinates;
}

Future<dynamic> insertTripNetwork(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile) {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("TRIPDATA") != null) {
      Map<String, dynamic> data = json.decode(prefs.getString("TRIPDATA")!);

      if (data.isNotEmpty) {
        var cliente = prefs.getString("path_cliente");

        data.addAll({"TRIPDATA" : "1"});

        var response = HttpClass.httpData(
            context,
            Uri.parse(cliente! + "aplicacion/insertviajes.php"),
            json.encode(data),
            {"content-type": "application/json"},
            "POST");

        response.then((value) {
          if (value["code"] == 200) {
            prefs.remove("TRIPDATA");
          }
        });

        return response;
      } else {
        return {"code": 998};
      }
    } else {
      return {"code": 999};
    }
  }
  return {"code": 100};
}

void finishTripNetwork(Map<String, dynamic> response, BuildContext context) {
  Map<String, dynamic> getDataInserted = response["data"];

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

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
                                color: _colorFromHex((Widgets.colorPrimary)),
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
                                color: _colorFromHex((Widgets.colorPrimary)),
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
                                color: _colorFromHex((Widgets.colorPrimary)),
                                fontWeight: FontWeight.w500,
                              )),
                          Text(
                            validateNullOrEmptyString(
                                        getDataInserted["subtotal"]) !=
                                    null
                                ? '\$ ' + getDataInserted["subtotal"].toString()
                                : "\$0.00",
                            style: GoogleFonts.poppins(
                              fontSize: 31,
                              color: _colorFromHex((Widgets.colorPrimary)),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3),
                              child: longButtons("Guardar", () {
                                Navigator.pop(context);
                              }, color: _colorFromHex(Widgets.colorPrimary)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ));
    },
  );
}

Future<dynamic> insertIncidenceNetwork(BuildContext context) async {
  var connectivityResult = await Connectivity().checkConnectivity();

  if (connectivityResult == ConnectivityResult.wifi ||
      connectivityResult == ConnectivityResult.mobile) {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString("TRIPINCIDENCE") != null) {
      Map<String, dynamic> data =
          json.decode(prefs.getString("TRIPINCIDENCE")!);

      if (data.isNotEmpty) {
        var cliente = prefs.getString("path_cliente");

        var response = HttpClass.httpData(
            context,
            Uri.parse(cliente! + "aplicacion/saveIncidence.php"),
            json.encode(data),
            {"content-type": "application/json"},
            "POST");

        response.then((value) {
          if (value["code"] == 200) {
            prefs.remove("TRIPINCIDENCE");
          }
        });

        return response;
      } else {
        return {"code": 998};
      }
    } else {
      return {"code": 999};
    }
  }
  return {"code": 100};
}

String convertirSegundosAHora(int segundos) {
  int horas = segundos ~/ 3600;
  int minutos = (segundos % 3600) ~/ 60;
  int segundosRestantes = segundos % 60;

  String formatoHora =
      '${_agregarCero(horas)}:${_agregarCero(minutos)}:${_agregarCero(segundosRestantes)}';

  return formatoHora;
}

String _agregarCero(int valor) {
  return valor < 10 ? '0$valor' : '$valor';
}

bool puedeIniciarViaje(String fechaInicio, String horaProgramada) {
  List<String> partesFecha = fechaInicio.split('-');
  int year = int.parse(partesFecha[0]);
  int month = int.parse(partesFecha[1]);
  int day = int.parse(partesFecha[2]);

  // Parsear la hora
  List<String> partesHora = horaProgramada.split(':');
  int hour = int.parse(partesHora[0]);
  int minute = int.parse(partesHora[1]);

  // Crear el objeto DateTime combinando la fecha y la hora
  DateTime horaProgramadaTimeOfDay = DateTime(
    year,
    month,
    day,
    hour,
    minute,
  );

  DateTime horaActual = DateTime.now();

  // Calcular la diferencia de tiempo en minutos usando la clase Duration
  Duration diferencia = horaProgramadaTimeOfDay.difference(horaActual);
  int diferenciaEnMinutos = diferencia.inMinutes;

  print("Actual: $horaActual");
  print("Programada: $horaProgramadaTimeOfDay");
  print(diferenciaEnMinutos <= 10);
  print(diferenciaEnMinutos);

  return diferenciaEnMinutos <= 10;
}

DateTime convertirHoraStringADateTime(String horaString) {
  List<String> partes = horaString.split(':');
  int horas = int.parse(partes[0]);
  int minutos = int.parse(partes[1]);
  int segundos = int.parse(partes[2]);
  return DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day,
      horas, minutos, segundos);
}

// Método para validar si se puede presionar el botón hasta 5 minutos antes de la hora programada
bool validarABordo(String horaProgramadaString) {
  DateTime horaProgramada = convertirHoraStringADateTime(horaProgramadaString);
  DateTime horaActual = DateTime.now();

  print(horaProgramada);
  print(horaActual);

  // Verificar si la hora actual está dentro de los 5 minutos antes o después de la hora programada
  return horaProgramada.difference(horaActual).inMinutes.abs() <= 4;
}
