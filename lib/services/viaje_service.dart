import 'dart:convert';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:flutter/cupertino.dart';

class ViajeService {
  static Future<List<ViajeModel>> getViajes(BuildContext context,
          {required int pageNumber,
          required int pageSize,
          required String idUser,
          var status,
          required String order}) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getViajesGeneral.php?pageNumber=$pageNumber&pageSize=$pageSize&idUser=$idUser&tripStatus=$status&order=$order"),
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
                fechaFin: element["fecha_fin"] ?? "",
                confirmado: element["confirmado"] ?? "",
                incidencias: element["percances"] ?? "",
                poligono: element["poligono"] ?? "",
                subtotal: double.tryParse((validateNullOrEmptyString(element["subtotal"].toString()) ?? 0.0).toString()) ?? 0.0,
                descripcion: element["descripcion"] ?? "",
                idRuta: element["id_ruta"] ?? "",
              ));
          }

          return auxViajeList;
        } else {
          return [];
        }
      });


      static Future<List<ViajeModel>> getHistorialTripList(BuildContext context,
          {required int pageNumber,
          required int pageSize,
          required String idUser,
          var status,
          required String order,
          required inicialDate,
          required endDate}) async =>
      HttpClass.httpData(
              context,
              Uri.parse(
                  "https://www.driverplease.net/aplicacion/getViajesHistorial.php?pageNumber=$pageNumber&pageSize=$pageSize&idCon=$idUser&tripStatus=$status&order=$order&inicialDate=$inicialDate&endDate=$endDate"),
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
                fechaFin: element["fecha_fin"] ?? "",
                confirmado: element["confirmado"] ?? "",
                incidencias: element["percances"] ?? "",
                poligono: element["poligono"] ?? "",
                subtotal: double.tryParse((validateNullOrEmptyNumber(element["subtotal"].toString()) ?? "0").toString()) ?? 0.0,
                descripcion: element["descripcion"] ?? "",
                idRuta: element["id_ruta"] ?? "",
              ));

          }

          return auxViajeList;
        } else {
          return [];
        }
      });

}
