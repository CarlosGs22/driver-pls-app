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
  String confirmado;
  String poligono;
  String incidencias;
  double subtotal;
  String descripcion;

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
      required this.fechaFin,
      required this.confirmado,
      required this.incidencias,
      required this.poligono,
      required this.subtotal,
      required this.descripcion});

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
      confirmado: json['confirmado'],
      incidencias: json['percances'],
      poligono: json['poligono'],
      subtotal: double.tryParse(json['subtotal']) ?? 0,
      descripcion: json["descripcion"] ?? "",
    );
  }
}
