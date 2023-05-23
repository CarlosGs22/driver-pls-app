import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import '../models/viaje_model.dart';

class ViajeService {
  static Future<List<ViajeModel>> getViajes(
      {required int pageNumber, required int pageSize}) async {
    final response = await http.get(Uri.parse(
        'https://www.driverplease.net/aplicacion/getviajesP.php?pageNumber=$pageNumber&pageSize=$pageSize'));
    log(response
        .body); // Agrega esta línea para ver la respuesta en la consola de depuración
    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((viaje) => ViajeModel.fromJson(viaje)).toList();
    } else {
      throw Exception('Error al cargar los viajes');
    }
  }
}
