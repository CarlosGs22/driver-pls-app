import 'dart:convert';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class ViajeService {
  static Future<List<ViajeModel>> getViajes(BuildContext context,
          {required int pageNumber, required int pageSize}) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getviajesP.php?pageNumber=$pageNumber&pageSize=$pageSize"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200) {
          List jsonResponse = json.decode(response["data"]);
          return jsonResponse
              .map((viaje) => ViajeModel.fromJson(viaje))
              .toList();
        } else {
          return [];
        }
      });
}
