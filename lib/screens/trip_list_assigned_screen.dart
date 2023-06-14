import 'package:driver_please_flutter/models/user.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';

import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/viaje_service.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TripListAssignedScreen extends StatefulWidget {
  const TripListAssignedScreen({Key? key}) : super(key: key);

  @override
  _TripListState createState() => _TripListState();
}

class _TripListState extends State<TripListAssignedScreen> {
  final int _pageSize = 1;
  int _pageNumber = 1;
  int _totalPages = 1;
  List<ViajeModel> _viajes = [];
  String idAgent = "";

  @override
  void initState() {
    super.initState();
    _getViajes();
  }

  _getViajes() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    List<ViajeModel> viajes = await ViajeService.getViajes(context,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        idUser: prefs.getString('id_con').toString(),
        status: 1);
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
    return Scaffold(
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

                return ChatBubble(
                    clipper: ChatBubbleClipper5(type: BubbleType.sendBubble),
                    margin: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 10, right: 10),
                    backGroundColor: Colors.white,
                    child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripDetailScreen(
                                        viaje: viaje,
                                        redirect: null,
                                      )));
                        },
                        child: ListTile(
                            minLeadingWidth: 0,
                            minVerticalPadding: 0,
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(2),
                                  alignment: Alignment.topRight,
                                  child: Text(
                                    "${viaje.fechaViaje} ${viaje.horaViaje}",
                                    style: TextStyle(
                                        fontStyle: FontStyle.italic,
                                        color: _colorFromHex(Widgets.colorGray),
                                        fontSize: 15),
                                  ),
                                ),
                                /*buildBubblePadding(
                                    Icons.circle,
                                    _colorFromHex(Widgets.colorPrimary),
                                    "Empresa: ${viaje.nombreEmpresa} - Sucursal: ${viaje.nombreSucursal}",
                                    _colorFromHex(Widgets.colorGrayLight),
                                    11),*/
                                buildBubblePadding(
                                    Icons.circle,
                                    _colorFromHex(Widgets.colorPrimary),
                                    "Tipo: ${viaje.tipo}",
                                    _colorFromHex(Widgets.colorGrayLight),
                                    11),
                                buildBubblePadding(
                                    Icons.circle,
                                    _colorFromHex(Widgets.colorPrimary),
                                    "Pasajeros: ${viaje.ocupantes}",
                                    _colorFromHex(Widgets.colorGrayLight),
                                    11),
                              ],
                            ),
                            leading: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  alignment: Alignment.center,
                                  height: 40,
                                  width: 40,
                                  child: FloatingActionButton(
                                    onPressed: null,
                                    backgroundColor:
                                        _colorFromHex(Widgets.colorPrimary),
                                    child: Text(
                                      viaje.idViaje.toString(),
                                      maxLines: 1,
                                      softWrap: false,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        overflow: TextOverflow.clip,
                                      ),
                                    ),
                                  ),
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
                                  status: 1);
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
                                  status: 1);
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
