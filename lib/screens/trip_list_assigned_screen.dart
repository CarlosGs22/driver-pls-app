import 'dart:io';

import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';

import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/viaje_service.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripListAssignedScreen extends StatefulWidget {
  const TripListAssignedScreen({Key? key}) : super(key: key);

  @override
  _TripListState createState() => _TripListState();
}

class _TripListState extends State<TripListAssignedScreen> {
  final int _pageSize = 10;
  int _pageNumber = 1;
  int _totalPages = 1;
  List<ViajeModel> _viajes = [];
  String idAgent = "";

  bool openDrawer = false;

  @override
  void initState() {
    super.initState();
    _getViajes();

    Intl.defaultLocale = "es_MX";
    initializeDateFormatting();
  }

  _getViajes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<ViajeModel> viajes = await ViajeService.getViajes(context,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        idUser: prefs.getString('id_con').toString(),
        status: 1,
        order : "1");
    if (viajes.isNotEmpty) {
      setState(() {
        idAgent = prefs.getString("id_con").toString();
        _viajes = viajes;
        _totalPages = viajes.first.totalPages;
      });
    }
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              setState(() {
                openDrawer = true;
              });
            }
          },
          appBar: AppBar(
            titleTextStyle: GoogleFonts.poppins(
                fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
            title: const Text(Strings.labelListTripAssigned),
            elevation: 0.1,
            backgroundColor: _colorFromHex(Widgets.colorPrimary),
          ),
          drawer: const MainDrawer(1),
          body: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: _viajes.length,
                  itemBuilder: (BuildContext context, int index) {
                    ViajeModel viaje = _viajes[index];

                    var horaViaje = viaje.horaViaje
                        .substring(0, viaje.horaViaje.lastIndexOf(':') + 1);

                    return ChatBubble(
                        clipper:
                            ChatBubbleClipper5(type: BubbleType.receiverBubble),
                        margin: const EdgeInsets.only(
                            top: 10, bottom: 10, left: 5, right: 5),
                        backGroundColor: _colorFromHex(Widgets.colorPrimary),
                        child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => TripDetailScreen(
                                            viaje: viaje,
                                            redirect: null,
                                            panelVisible: true,
                                          )));
                            },
                            child: ListTile(
                                minLeadingWidth: 0,
                                minVerticalPadding: 0,
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 2, bottom: 2),
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            viaje.idViaje,
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: _colorFromHex(
                                                    Widgets.colorSecundayLight),
                                                fontSize: 13),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.only(
                                              top: 2, bottom: 2),
                                          alignment: Alignment.topRight,
                                          child: Text(
                                            getFormattedDateFromFormattedString(
                                                viaje.fechaViaje
                                                    .replaceAll(" ", "")),
                                            style: TextStyle(
                                                fontStyle: FontStyle.italic,
                                                color: _colorFromHex(
                                                    Widgets.colorSecundayLight),
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                    buildBubblePadding(
                                        Icons.circle,
                                        _colorFromHex(Widgets.colorPrimary),
                                        "Tipo: ${viaje.tipo}",
                                        _colorFromHex(
                                            Widgets.colorSecundayLight),
                                        8),
                                    buildBubblePadding(
                                        Icons.circle,
                                        _colorFromHex(Widgets.colorPrimary),
                                        "Hora: ${horaViaje} Hrs",
                                        _colorFromHex(
                                            Widgets.colorSecundayLight),
                                        8),
                                    if (validateNullOrEmptyString(
                                            viaje.nombreSucursal) !=
                                        null) ...[
                                      buildBubblePadding(
                                          Icons.circle,
                                          _colorFromHex(Widgets.colorPrimary),
                                          "Sucursal: ${viaje.nombreSucursal}",
                                          _colorFromHex(
                                              Widgets.colorSecundayLight),
                                          8),
                                    ],
                                    if (validateNullOrEmptyString(
                                            viaje.nombreEmpresa) !=
                                        null) ...[
                                      buildBubblePadding(
                                          Icons.circle,
                                          _colorFromHex(Widgets.colorPrimary),
                                          "Empresa: ${viaje.nombreEmpresa}",
                                          _colorFromHex(
                                              Widgets.colorSecundayLight),
                                          8),
                                    ],
                                  ],
                                ),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: Icon(Icons.local_taxi_rounded,
                                          size: 50,
                                          color: _colorFromHex(
                                              Widgets.colorSecundayLight)),
                                    ),
                                  ],
                                ))));
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
                              List<ViajeModel> viajes =
                                  await ViajeService.getViajes(context,
                                      pageNumber: _pageNumber,
                                      pageSize: _pageSize,
                                      idUser: idAgent,
                                      status: 1,
                                      order: "1");
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
                              List<ViajeModel> viajes =
                                  await ViajeService.getViajes(context,
                                      pageNumber: _pageNumber,
                                      pageSize: _pageSize,
                                      idUser: idAgent,
                                      status: 1,
                                      order: "1");
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
        ));
  }

  Future<bool> showExitPopup() async {
    if (openDrawer) {
      setState(() {
        openDrawer = false;
      });
      Navigator.of(context).pop(false);
      return false;
    } else {
      return await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Atención'),
              content: const Text('Estas seguro que quieres salir?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text("No",
                        style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary)))),
                TextButton(
                    onPressed: () {
                      if (Platform.isIOS) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                    child: Text("Si",
                        style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary)))),
              ],
            ),
          ) ??
          false;
    }
  }
}
