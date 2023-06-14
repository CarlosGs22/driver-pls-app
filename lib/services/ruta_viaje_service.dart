import 'dart:convert';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class RutaViajeService {
  static Future<List<RutaViajeModel>> getViajes(
          BuildContext context, var idViaje) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getRutaViajes.php?id_viaje=$idViaje"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200) {
          List jsonResponse = json.decode(response["data"]);
          return jsonResponse
              .map((viaje) => RutaViajeModel.fromJson(viaje))
              .toList();
        } else {
          return [];
        }
      });
}
