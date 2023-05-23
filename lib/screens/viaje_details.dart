import 'package:driver_pls_flutter/models/viaje_model.dart';
import 'package:flutter/material.dart';


class ViajeDetailsScreen extends StatelessWidget {
  final ViajeModel viaje;

  const ViajeDetailsScreen({Key? key, required this.viaje}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del viaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${viaje.fechaViaje}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Empresa: ${viaje.nombreEmpresa}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Sucursal: ${viaje.nombreSucursal}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text('Tipo de viaje: ${viaje.tipo}',
                style: const TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}
