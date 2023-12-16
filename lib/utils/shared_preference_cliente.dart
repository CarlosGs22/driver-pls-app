import 'package:driver_please_flutter/models/cliente_model.dart';
import 'package:driver_please_flutter/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ClientePreferences {
  Future<bool> saveCliente(Cliente cliente) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setString('id_cliente', cliente.idCliente);
    prefs.setString('nombre_cliente', cliente.nombre);
    prefs.setString('correo_cliente', cliente.correo);
    prefs.setString('telefono_cliente', cliente.telefono);
    prefs.setString('vigencia_cliente', cliente.vigencia);
    prefs.setString('subscripcion_cliente', cliente.vigencia);
    prefs.setString('promocion_cliente', cliente.promocion);
    prefs.setString('estatus_cliente', cliente.estatus);
    prefs.setString('path_cliente', cliente.path);


    return prefs.commit();
  }

  Future<Cliente> getCliente() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String clienteId = prefs.getString("id_cliente").toString();
    String nombre = prefs.getString("nombre_cliente").toString();
    String correo = prefs.getString("correo_cliente").toString();
    String telefono = prefs.getString("telefono_cliente").toString();
    String vigencia = prefs.getString("vigencia_cliente").toString();
    String subscripcion = prefs.getString("subscripcion_cliente").toString();
    String promocion = prefs.getString("promocion_cliente").toString();
    String estatus = prefs.getString("estatus_cliente").toString();
    String path = prefs.getString("path_cliente").toString();

    var cliente = Cliente(
        idCliente: clienteId,
        nombre: nombre,
        correo: correo,
        telefono: telefono,
        vigencia: vigencia,
        suscripcion: subscripcion,
        promocion: promocion,
        estatus: estatus,
        path: path);
    return cliente;
  }

  void removeCliente() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<bool> saveValueUser(var key, var value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, "");
    return prefs.commit();
  }
}
