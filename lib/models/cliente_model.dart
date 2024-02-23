class Cliente {
  String idCliente = "";
  String nombre = "";
  String correo = "";
  String telefono = "";
  String vigencia = "";
  String suscripcion = "";
  String promocion = "";
  String estatus = "";
  String path = "";
  String logo = "";
  String whatsapp = "";

  Cliente(
      {required this.path,
      required this.idCliente,
      required this.nombre,
      required this.correo,
      required this.telefono,
      required this.vigencia,
      required this.suscripcion,
      required this.promocion,
      required this.estatus,
      required this.logo,
      required this.whatsapp});

  factory Cliente.fromJson(Map<String, dynamic> responseData) {
    return Cliente(
      idCliente: responseData['id_cliente'] ?? '',
      nombre: responseData['nombre'] ?? '',
      correo: responseData['correo'] ?? '',
      telefono: responseData['telefono'] ?? '',
      vigencia: responseData['vigencia'] ?? '',
      suscripcion: responseData['suscripcion'] ?? '',
      promocion: responseData['promocion'] ?? '',
      estatus: responseData['estatus'] ?? '',
      path: responseData['path'] ?? '',
      logo: responseData['logo'] ?? '',
      whatsapp: responseData['whatsapp'] ?? '',
    );
  }

  Cliente.cliente();
}
