import 'dart:convert';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class ViajeService {
  static Future<List<ViajeModel>> getViajes(BuildContext context,
          {required int pageNumber,
          required int pageSize,
          required String idUser,
          var status}) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getViajesGeneral.php?pageNumber=$pageNumber&pageSize=$pageSize&idUser=$idUser&tripStatus=$status"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200) {
          Map<String, dynamic> mapData = response["data"];

          List<dynamic> jsonResponse = mapData["viajes"];

          List<ViajeModel> auxViajeList = [];

          for (var element in jsonResponse) {
            auxViajeList.add(ViajeModel(
                idViaje: element["id_viaje"].toString(),
                ocupantes: int.tryParse(element["ocupantes"]) ?? 0,
                nombreEmpresa: element["nombre_empresa"],
                idEmp: int.tryParse(element["id_emp"]) ?? 0,
                nombreSucursal: element["nombre_sucursal"],
                idSuc: int.tryParse(element["id_suc"]) ?? 0,
                tipo: element["tipo"],
                fechaViaje: element["fecha"],
                horaViaje: element["hora"],
                totalPages: mapData["total_pages"],
                status: int.tryParse(element["estatus"]) ?? 0,
                fechaInicio: element["fecha_inicio"] ?? "",
                fechaFin: element["fecha_fin"] ?? ""
              ));
          }

          return auxViajeList;
        } else {
          return [];
        }
      });
}
