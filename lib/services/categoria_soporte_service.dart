import 'dart:convert';
import 'package:driver_please_flutter/models/categoria_soporte_model.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class CategoriaSoporteService {
  static Future<List<CategoriaSoporteModel>> getCategoriaSoporte(
          BuildContext context) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getCategoriaSoporte.php"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200) {
          List jsonResponse = json.decode(response["data"]);

          return jsonResponse
              .map((viaje) => CategoriaSoporteModel.fromJson(viaje))
              .toList();
        } else {
          return [];
        }
      });
}
