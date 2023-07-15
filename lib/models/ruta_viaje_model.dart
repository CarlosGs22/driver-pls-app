import 'package:flutter/material.dart';

class RutaViajeModel {
  String idRuta;
  String idViaje;
  String idDir;
  String tipo;
  String orden;
  String idDestino;
  String tipoDestino;
  String idSuc;
  String hora;
  String estatus;
  String retraso;
  String horaReal;
  String horaBajada;
  double latitud;
  double longitud;
  String direccion;
  String personaNombre;
  String personaTelefono;
  String fechaInicio;
  String fechaFin;
   String nombreSucursal;

  RutaViajeModel(
      {required this.idRuta,
      required this.idViaje,
      required this.idDir,
      required this.tipo,
      required this.orden,
      required this.idDestino,
      required this.tipoDestino,
      required this.idSuc,
      required this.hora,
      required this.estatus,
      required this.retraso,
      required this.horaReal,
      required this.horaBajada,
      required this.latitud,
      required this.longitud,
      required this.direccion,
      required this.personaNombre,
      required this.personaTelefono,
      required this.fechaInicio,
      required this.fechaFin,
      required this.nombreSucursal});

  factory RutaViajeModel.fromJson(Map<String, dynamic> json) {
    return RutaViajeModel(
      idRuta: json['id_ruta'],
      idViaje: json['id_viaje'],
      idDir: json['id_dir'],
      tipo: json['tipo'],
      orden: json['orden'],
      idDestino: json['id_destino'],
      tipoDestino: json['tipo_destino'],
      idSuc: json['id_suc'],
      hora: json['hora'],
      estatus: json['estatus'],
      retraso: json['retraso'],
      horaReal: json['hora_real'],
      horaBajada: json['hora_bajada'],
      latitud: double.tryParse(json['latitud']) ?? 0,
      longitud: double.tryParse(json['longitud']) ?? 0,
      direccion: json['direccion'],
      personaNombre: json['personaNombre'] ?? "",
      personaTelefono: json['personaTelefono'] ?? "",
      fechaInicio: json['fecha_inicio'] ?? "",
      fechaFin: json['fecha_fin'] ?? "",
      nombreSucursal: json['nombreSucursal'] ?? ""
    );
  }
}
