class CategoriaSoporteModel {
  int id;
  String descripcion;
  int status;
  
  CategoriaSoporteModel({
    required this.id,
    required this.descripcion,
    required this.status,
  });

  factory CategoriaSoporteModel.fromJson(Map<String, dynamic> map) {
    return CategoriaSoporteModel(
      id: int.tryParse(map['id']) ?? 0,
      descripcion: map['descripcion'] ?? '',
      status: int.tryParse(map['status']) ?? 0,
    );
  }

}
