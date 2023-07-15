import 'dart:convert';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_resumen_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class ViajeResumenService {
  static Future<Map<String, dynamic>> getViajeResumen(
          BuildContext context, var idViaje) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getViajeResumen.php?id_viaje=$idViaje"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200 && (response["data"] as List).isNotEmpty) {
          return json.decode(json.encode(response["data"][0]));
        } else {
          return {};
        }
      });
}
