import 'dart:convert';
import 'package:driver_please_flutter/models/carro_model.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:flutter/cupertino.dart';

class CarroService {
  static Future<List<CarroModel>> getCarroConductor(
          BuildContext context,var idCon,{required String path}) async =>
     
     
      HttpClass.httpData(
              context,
              Uri.parse(
                 path +  "aplicacion/getCarroConductor.php?idCon=$idCon"),
              {},
              {},
              "GET")
          .then((response) {
        if (response["status"] && response["code"] == 200) {
          List jsonResponse = json.decode(response["data"]);

          return jsonResponse.map((carro) => CarroModel.fromJson(carro)).toList();
        } else {
          return [];
        }
      });
}
