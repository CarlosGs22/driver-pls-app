import 'dart:convert';

class ViajeResumenModel {
  String idCon;
  String distancia;
  String bandera;
  String tiempo;
  String costoDistancia;
  String costoTiempo;
  String subtotal;
  String porcentajeComision;
  String costoComision;
  String totalGanancia;
  String ivaTranslado;
  String costoIvaTranslado;
  String totalGananciaIva;
  String idViaje;

  ViajeResumenModel({
    required this.idCon,
    required this.distancia,
    required this.bandera,
    required this.tiempo,
    required this.costoDistancia,
    required this.costoTiempo,
    required this.subtotal,
    required this.porcentajeComision,
    required this.costoComision,
    required this.totalGanancia,
    required this.ivaTranslado,
    required this.costoIvaTranslado,
    required this.totalGananciaIva,
    required this.idViaje,
  });

  factory ViajeResumenModel.fromJson(Map<String, dynamic> json) {
    return ViajeResumenModel(
        idCon: json["id_con"],
        distancia: json["distancia"],
        bandera: json["bandera"],
        tiempo: json["tiempo"],
        costoDistancia: json["costo_distancia"],
        costoTiempo: json["costo_tiempo"],
        subtotal: json["subtotal"],
        porcentajeComision: json["porcentaje_comision"],
        costoComision: json["costo_comision"],
        totalGanancia: json["total_ganancia"],
        ivaTranslado: json["iva_traslado"],
        costoIvaTranslado: json["costo_iva_traslado"],
        totalGananciaIva: json["total_ganancia_iva"],
        idViaje: json["id_viaje"]);
  }
}
