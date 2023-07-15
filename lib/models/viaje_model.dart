import 'package:driver_please_flutter/utils/validator.dart';

class ViajeModel {
  String idViaje;
  int ocupantes;
  String nombreEmpresa;
  int? idEmp;
  String nombreSucursal;
  int? idSuc;
  String tipo;
  String fechaViaje;
  String horaViaje;
  int totalPages;
  int status;
  String fechaInicio;
  String fechaFin;

  ViajeModel(
      {required this.idViaje,
      required this.ocupantes,
      required this.nombreEmpresa,
      required this.idEmp,
      required this.nombreSucursal,
      required this.idSuc,
      required this.tipo,
      required this.fechaViaje,
      required this.horaViaje,
      required this.totalPages,
      required this.status,
      required this.fechaInicio,
      required this.fechaFin});

  factory ViajeModel.fromJson(Map<String, dynamic> json) {
    return ViajeModel(
      idViaje: json['id_viaje'],
      ocupantes: json['ocupantes'] != null ? int.parse(json['ocupantes']) : 0,
      nombreEmpresa: json['nombre_emp'],
      idEmp: json['id_emp'] != null ? int.parse(json['id_emp']) : null,
      nombreSucursal: json['nombre'],
      idSuc: json['id_suc'] != null ? int.parse(json['id_suc']) : null,
      tipo: json['tipo'],
      fechaViaje: json['fecha'],
      horaViaje: json['hora'],
      totalPages: json['total_pages'] ?? 1,
      status: int.parse(json['estatus']),
      fechaInicio: json["fecha_inicio"] ?? "-",
      fechaFin: json['fecha_fin'] ?? "-",
    );
  }
}
