import 'package:driver_please_flutter/models/cliente_model.dart';
import 'package:driver_please_flutter/models/user.dart';
import 'package:flutter/cupertino.dart';

class ClienteProvider extends ChangeNotifier {
  Cliente _cliente = Cliente.cliente();

  Cliente get cliente => _cliente;

  void setCliente(Cliente cliente) async {
    _cliente = cliente;
    notifyListeners();
  }
}
