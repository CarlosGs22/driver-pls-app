import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/screens/map/google_map.dart';
import 'package:driver_please_flutter/screens/taximeter_screen.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';

import 'drawer/main_drawer.dart';

class TripDetailScreen extends StatefulWidget {
  final ViajeModel viaje;

  const TripDetailScreen({Key? key, required this.viaje}) : super(key: key);

  @override
  _TripDetailScreenState createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  bool openDrawer = false;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  bool showPassword = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      onDrawerChanged: (isOpened) {
        if (isOpened) {
          setState(() {
            openDrawer = true;
          });
        }
      },
      appBar: AppBar(
        title: const Text(Strings.labelDetailTrip),
        elevation: 0.1,
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.location_pin),
            onPressed: () {
              Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                             WidgetGoogleMap()));
            },
          )
        ],
      ),
      drawer: const MainDrawer(0),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
             
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 130,
                        height: 119,
                        child: CircleAvatar(
                            backgroundColor:
                                _colorFromHex(Widgets.colorPrimary),
                            radius: 16,
                            child: IconButton(
                              iconSize: 66,
                              // remove default padding here
                              padding: EdgeInsets.zero,
                              icon: const Icon(
                                Icons.directions,
                              ),
                              color: Colors.white,
                              onPressed: () {
                                
                              },
                            ))),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              buildDetailform(Strings.labelTripDate, widget.viaje.fechaViaje,
                  Strings.labelTripHour, widget.viaje.horaViaje),
              buildDetailform(
                  Strings.labelTripLocation,
                  widget.viaje.nombreSucursal,
                  Strings.labelTripCompany,
                  widget.viaje.nombreEmpresa),
              buildDetailform(
                  Strings.labelTripType,
                  widget.viaje.tipo,
                  Strings.labelTripOccupants,
                  widget.viaje.ocupantes.toString()),
              const SizedBox(
                height: 35,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
