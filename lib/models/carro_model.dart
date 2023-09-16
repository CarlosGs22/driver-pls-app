class CarroModel {
  int idCar;
  String propiedad;
  String marca;
  String tipo;
  String modelo;
  String color;
  String placas;
  int estatus;
  int idCon;

  CarroModel({
    required this.idCar,
    required this.propiedad,
    required this.marca,
    required this.tipo,
    required this.modelo,
    required this.color,
    required this.placas,
    required this.estatus,
    required this.idCon,
  });

  factory CarroModel.fromJson(Map<String, dynamic> map) {
    return CarroModel(
      idCar: int.tryParse(map['id_car']) ?? 0,
      propiedad: map['propiedad'] ?? '',
      marca: map['marca'] ?? '',
      tipo: map['tipo'] ?? '',
      modelo: map['modelo'] ?? '',
      color: map['color'] ?? '',
      placas: map['placas'] ?? '',
      estatus: int.tryParse(map['estatus']) ?? 0,
      idCon: int.tryParse(map['id_con']) ?? 0
    );
  }
}
