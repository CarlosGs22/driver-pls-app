import 'package:driver_please_flutter/utils/validator.dart';

class ViajeModel {
    int idViaje;
    int ocupantes;
    String nombreEmpresa;
    int? idEmp;
    String nombreSucursal;
    int? idSuc;
    String tipo;
    String fechaViaje;
    String horaViaje;
    int totalPages;

  ViajeModel({
    required this.idViaje,
    required this.ocupantes,
    required this.nombreEmpresa,
    required this.idEmp,
    required this.nombreSucursal,
    required this.idSuc,
    required this.tipo,
    required this.fechaViaje,
    required this.horaViaje,
    required this.totalPages,
  });

  factory ViajeModel.fromJson(Map<String, dynamic> json) {


    return ViajeModel(
      idViaje: validateNullOrEmptyNumber(int.tryParse(json['id_viaje'])),
      ocupantes: json['ocupantes'] != null ? int.parse(json['ocupantes']) : 0, //que no salga cuando no tiene pasajeros
      nombreEmpresa: json['nombre_emp'],
      idEmp: json['id_emp'] != null ? int.parse(json['id_emp']) : null,
      nombreSucursal: json['nombre'],
      idSuc: json['id_suc'] != null ? int.parse(json['id_suc']) : null,
      tipo: json['tipo'],
      fechaViaje: json['fecha_viaje'],
      horaViaje: json['hora_viaje'],
      totalPages: json['total_pages'] ?? 1,
    );
  }
}
