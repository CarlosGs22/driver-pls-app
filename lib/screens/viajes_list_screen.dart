import 'package:driver_pls_flutter/utils/strings.dart';
import 'package:driver_pls_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/viaje_model.dart';
import '../services/viaje_service.dart';
import 'viaje_details.dart';

class ViajesListScreen extends StatefulWidget {
  const ViajesListScreen({Key? key}) : super(key: key);

  @override
  _ViajesListState createState() => _ViajesListState();
}

class _ViajesListState extends State<ViajesListScreen> {
  final int _pageSize = 5;
  int _pageNumber = 1;
  final int _totalPages = 1;
  List<ViajeModel> _viajes = [];

  @override
  void initState() {
    super.initState();
  }

  /*Future<List<ViajeModel>> _getViajes() async {
    setState(() {
    });

    List<ViajeModel> viajes = await ViajeService.getViajes(
        pageNumber: _pageNumber, pageSize: _pageSize);

    setState(() {
      _viajes = viajes;
      _totalPages = viajes.first.totalPages;
    });

    return viajes;
  }*/

   Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
        title: const Text(Strings.labelListTrip),
        elevation: 0.1,
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.filter_alt_sharp),
            onPressed: () {},
          )
        ],
      ),
    body: Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: _viajes.length,
            itemBuilder: (BuildContext context, int index) {
              ViajeModel viaje = _viajes[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ViajeDetailsScreen(viaje: viaje),
                    ),
                  );
                },
                child: ListTile(
                  title: Text(
                    'Viaje ${viaje.idViaje}',
                    style: const TextStyle(fontSize: 20), // Aumenta el tamaño de letra del título
                  ),
                  subtitle: Text(
                    'Empresa: ${viaje.nombreEmpresa} - Sucursal: ${viaje.nombreSucursal} - Tipo: ${viaje.tipo} - Pasajeros: ${viaje.ocupantes} -  Fecha: ${viaje.fechaViaje} - Hora: ${viaje.horaViaje}',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _pageNumber > 1
                  ? IconButton(
                      onPressed: () async {
                        setState(() {
                          _pageNumber--;
                        });
                        List<ViajeModel> viajes = await ViajeService.getViajes(
                          pageNumber: _pageNumber, pageSize: _pageSize);
                        setState(() {
                          _viajes = viajes;
                        });
                      },
                      icon: const Icon(Icons.arrow_left),
                    )
                  : const SizedBox.shrink(),
              Text('Página $_pageNumber de $_totalPages'),
              _pageNumber < _totalPages
                  ? IconButton(
                      onPressed: () async {
                        setState(() {
                          _pageNumber++;
                        });
                        List<ViajeModel> viajes = await ViajeService.getViajes(
                            pageNumber: _pageNumber, pageSize: _pageSize);
                        setState(() {
                          _viajes = viajes;
                        });
                      },
                      icon: const Icon(Icons.arrow_right),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ],
    ),
  );
}
}