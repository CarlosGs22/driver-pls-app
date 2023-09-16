class User {
  String TAG = "User";
  String id = "";
  String name = "";
  String lastName = "";
  String email = "";
  String mobile = "";
  String country = "";
  String state = "";
  String city = "";
  String status = "";
  String comission = "";
  String rateKm = "";
  String rateM = "";
  String password = "";
  String pass = "";
  String marca = "";
  String tipo = "";
  String modelo = "";
  String color = "";
  String placas = "";

  User(
      {required this.id,
      required this.name,
      required this.lastName,
      required this.email,
      required this.mobile,
      required this.country,
      required this.state,
      required this.city,
      required this.status,
      required this.comission,
      required this.rateKm,
      required this.rateM,
      required this.password,
      required this.pass,
      required this.marca,
      required this.tipo,
      required this.modelo,
      required this.color,
      required this.placas});

  factory User.fromJson(Map<String, dynamic> responseData) {
    return User(
        id: responseData['id_con'] ?? '',
        name: responseData['nombre'] ?? '',
        lastName: responseData['apellido'] ?? '',
        email: responseData['email'] ?? '',
        mobile: responseData['telefono'] ?? '',
        country: responseData['pais'] ?? '',
        state: responseData['estado'] ?? '',
        city: responseData['ciudad'] ?? '',
        status: responseData['estatus'] ?? '',
        comission: responseData['comision'] ?? '',
        rateKm: responseData['tarifakm'] ?? '',
        rateM: responseData['tarifam'] ?? '',
        password: responseData['password'] ?? '',
        pass: responseData['pass'] ?? '',
        marca: responseData['marca'] ?? '',
        tipo: responseData['tipo'] ?? '',
        modelo: responseData['modelo'] ?? '',
        color: responseData['color'] ?? '',
        placas: responseData['placas'] ?? ''
      );
  }

  User.agent();
}
