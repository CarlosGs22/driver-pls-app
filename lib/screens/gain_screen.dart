import 'dart:convert';
import 'dart:io';

import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

class GainScreen extends StatefulWidget {
  const GainScreen({Key? key}) : super(key: key);

  @override
  State<GainScreen> createState() => _GainScreenState();
}

Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

class _GainScreenState extends State<GainScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  final formKey = GlobalKey<FormState>();

  CurrencyTextInputFormatter _formatter = CurrencyTextInputFormatter();

  bool openDrawer = false;

  bool isLoading = false;

  bool loadData = false;

  List<dynamic> mapGanancias = [];
  List<dynamic> mapInicialGanancias = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _filterResponse(context);

    _inicialFilterResponse(context, {});
  }

  _filterResponse(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;


    var txtFechaInicial = _selectedDay.toIso8601String().split('T')[0];
    var txtFechaFinal = _selectedDay.toIso8601String().split('T')[0];
    var idConductor = user.id;


    HttpClass.httpData(
            context,
            Uri.parse(
               cliente.path +  "aplicacion/getGanancias.php?fecha_inicial=$txtFechaInicial&fecha_final=$txtFechaFinal&id_conductor=$idConductor"),
            {},
            {},
            "GET")
        .then((response) {
      //Utility.printWrapped(response.toString());
      setState(() {
        isLoading = false;
        loadData = true;
      });

      if (!response["status"] ||
          response["data"] == null ||
          (response["data"] as List).isEmpty) {
        setState(() {
          mapGanancias = [];
        });

        return;
      }

      setState(() {
        mapGanancias = json.decode(json.encode(response["data"]));
      });
    });
  }

  _inicialFilterResponse(BuildContext context, Map weekOnCurse) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    setState(() {
      isLoading = true;
    });

    var txtFechaInicial = "";
    var txtFechaFinal = "";
    var idConductor = user.id;

    if (weekOnCurse.isNotEmpty) {
      txtFechaInicial = weekOnCurse["txtFechaInicial"];
      txtFechaFinal = weekOnCurse["txtFechaFinal"];
    } else {
      DateTime now = DateTime.now();
      int currentDayOfWeek = now.weekday;
      DateTime startOfWeek = now.subtract(Duration(days: currentDayOfWeek - 1));
      DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
      startOfWeek = DateTime(
          startOfWeek.year, startOfWeek.month, startOfWeek.day, 0, 0, 0);
      endOfWeek =
          DateTime(endOfWeek.year, endOfWeek.month, endOfWeek.day, 23, 59, 59);

      txtFechaInicial = startOfWeek.toIso8601String().split('T')[0];
      txtFechaFinal = endOfWeek.toIso8601String().split('T')[0];
    }

    final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;


    HttpClass.httpData(
            context,
            Uri.parse(
              cliente.path + "aplicacion/getGanancias.php?fecha_inicial=$txtFechaInicial&fecha_final=$txtFechaFinal&id_conductor=$idConductor"),
            {},
            {},
            "GET")
        .then((response) {
      setState(() {
        isLoading = false;
        loadData = true;
      });

      if (!response["status"] ||
          response["data"] == null ||
          (response["data"] as List).isEmpty) {
        setState(() {
          mapInicialGanancias = [];
        });

        return;
      }

      setState(() {
        mapInicialGanancias = json.decode(json.encode(response["data"]));
      });
    });
  }

  _setGanancias(List<dynamic> mapGanancias) {
    List<Widget> listWidget = [];

    if (mapGanancias.length < 1) {
      return [SizedBox()];
    }

    for (var i = 1; i < mapGanancias.length; i++) {
      double total_viaje = 0;
      double totalGanancia = 0;

      if (validateNullOrEmptyNumber(mapGanancias[i]["subtotal"]) != 0) {
        total_viaje = double.parse(mapGanancias[i]["subtotal"].toString());
      }

      if (validateNullOrEmptyNumber(mapGanancias[i]["costo_comision"]) != 0) {
        totalGanancia += (total_viaje -
            double.parse(mapGanancias[i]["costo_comision"].toString()));
      }

      DateTime dateTime =
          DateTime.parse(mapGanancias[i]["fecha_inicio"].toString());

      String horaViaje =
          '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';

      Widget wid = Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
          child: Container(
              width: MediaQuery.of(context).size.width,
              color: Colors.white,
              height: 100,
              child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        border: Border(
                          left: BorderSide(
                            color: _colorFromHex(Widgets.colorPrimary),
                            width: 5.0,
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Flexible(
                            flex: 6,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            15, 0, 15, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        buildText(
                                            (horaViaje) + " Hrs",
                                            15,
                                            _colorFromHex(
                                                Widgets.colorGrayLight),
                                            0.16,
                                            "popins",
                                            false,
                                            19,
                                            TextAlign.center,
                                            FontWeight.w500,
                                            Colors.transparent),
                                        buildText(
                                            mapGanancias[i]["id_viaje"] ?? "NA",
                                            18,
                                            _colorFromHex(
                                                Widgets.colorSecundary),
                                            0.16,
                                            "popins",
                                            false,
                                            19,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            Colors.transparent),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Flexible(
                            flex: 6,
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsetsDirectional.fromSTEB(
                                            15, 0, 15, 0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.max,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        buildText(
                                            "MXN \$" +
                                                (totalGanancia)
                                                    .toStringAsFixed(2),
                                            18,
                                            _colorFromHex(
                                                Widgets.colorSecundary),
                                            0.16,
                                            "popins",
                                            false,
                                            19,
                                            TextAlign.center,
                                            FontWeight.bold,
                                            Colors.transparent),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ])));

      listWidget.add(wid);
    }

    return listWidget;
  }

  _setInicialGanancias(List<dynamic> mapInicialGanancias) {
    List<Widget> listWidget = [];

    if (mapInicialGanancias.length < 1) {
      return [SizedBox()];
    }

    double total_viaje = 0;
    double totalGanancia = 0;
    int totalSumaViajes = 0;

    for (var i = 1; i < mapInicialGanancias.length; i++) {
      totalSumaViajes++;

      if (validateNullOrEmptyNumber(mapInicialGanancias[i]["subtotal"]) != 0) {
        total_viaje =
            double.parse(mapInicialGanancias[i]["subtotal"].toString());
      }

      if (validateNullOrEmptyNumber(mapInicialGanancias[i]["costo_comision"]) !=
          0) {
        totalGanancia += (total_viaje -
            double.parse(mapInicialGanancias[i]["costo_comision"].toString()));
      }
    }

    Widget wid = Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(10, 10, 10, 10),
        child: Container(
            width: MediaQuery.of(context).size.width,
            color: Colors.white,
            child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    //height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border(
                        left: BorderSide(
                          color: _colorFromHex(Widgets.colorPrimary),
                          width: 5.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 6,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: buildText(
                                  "Total ganancias de la semana",
                                  15,
                                  _colorFromHex(Widgets.colorGrayLight),
                                  0.16,
                                  "popins",
                                  false,
                                  19,
                                  TextAlign.center,
                                  FontWeight.w500,
                                  Colors.transparent)),
                        ),
                        Flexible(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: buildText(
                                  "\$" +
                                      (_formatter.format(
                                              totalGanancia.toStringAsFixed(2)))
                                          .replaceAll("USD", ""),
                                  15,
                                  _colorFromHex(Widgets.colorSecundary),
                                  0.16,
                                  "popins",
                                  false,
                                  19,
                                  TextAlign.center,
                                  FontWeight.bold,
                                  Colors.transparent),
                            ))
                      ],
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    //height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      border: Border(
                        left: BorderSide(
                          color: _colorFromHex(Widgets.colorPrimary),
                          width: 5.0,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 6,
                          child: Padding(
                              padding: EdgeInsets.all(10),
                              child: buildText(
                                  "Total viajes de la semana",
                                  15,
                                  _colorFromHex(Widgets.colorGrayLight),
                                  0.16,
                                  "popins",
                                  false,
                                  19,
                                  TextAlign.center,
                                  FontWeight.w500,
                                  Colors.transparent)),
                        ),
                        Flexible(
                            flex: 6,
                            child: Padding(
                              padding: EdgeInsets.all(10),
                              child: buildText(
                                  totalSumaViajes.toString(),
                                  15,
                                  _colorFromHex(Widgets.colorSecundary),
                                  0.16,
                                  "popins",
                                  false,
                                  19,
                                  TextAlign.center,
                                  FontWeight.bold,
                                  Colors.transparent),
                            ))
                      ],
                    ),
                  ),
                ])));

    listWidget.add(wid);

    return listWidget;
  }

  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //     onWillPop: showExitPopup,
    return Scaffold(
        resizeToAvoidBottomInset: false,
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
          title: const Text(Strings.labelTripGain),
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
        ),
        drawer: MainDrawer(4),
        body: isLoading
            ? buildCircularProgress(context)
            : SingleChildScrollView(
                child: Column(children: [
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: Column(
                      children: _setInicialGanancias(mapInicialGanancias)),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 5, bottom: 5),
                  child: TableCalendar(
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    availableCalendarFormats: {
                      CalendarFormat.week: "Mes",
                      CalendarFormat.month: "Semana",
                      //CalendarFormat.twoWeeks: "Semana"
                    },
                    locale: 'es_MX',
                    calendarFormat: _calendarFormat,
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    firstDay: DateTime.utc(2023, 06, 01),
                    lastDay: DateTime.now(),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) {
                      return isSameDay(_selectedDay, day);
                    },
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });

                      DateTime startOfWeek = focusedDay
                          .subtract(Duration(days: focusedDay.weekday - 1));
                      DateTime endOfWeek = focusedDay
                          .add(Duration(days: 7 - focusedDay.weekday));

                      Map filterWeek = {
                        "txtFechaInicial":
                            DateFormat('yyyy/MM/dd').format(startOfWeek),
                        "txtFechaFinal":
                            DateFormat('yyyy/MM/dd').format(endOfWeek)
                      };

                      _inicialFilterResponse(context, filterWeek);

                      _filterResponse(context);
                    },
                    onPageChanged: (focusedDay) {
                      DateTime startOfWeek = focusedDay
                          .subtract(Duration(days: focusedDay.weekday - 1));
                      DateTime endOfWeek = focusedDay
                          .add(Duration(days: 7 - focusedDay.weekday));

                      Map filterWeek = {
                        "txtFechaInicial":
                            DateFormat('yyyy/MM/dd').format(startOfWeek),
                        "txtFechaFinal":
                            DateFormat('yyyy/MM/dd').format(endOfWeek)
                      };

                      setState(() {
                        _selectedDay = startOfWeek;
                        _focusedDay = focusedDay;
                      });

                      _inicialFilterResponse(context, filterWeek);

                      _filterResponse(context);
                    },
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                mapGanancias.isNotEmpty
                    ? Column(mainAxisSize: MainAxisSize.max, children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: const BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Container(
                                color: Colors.white,
                                width: MediaQuery.of(context).size.width,
                                height: 100,
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Flexible(
                                      flex: 6,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                buildText(
                                                    "Ganancias Totales\n del día",
                                                    15,
                                                    _colorFromHex(
                                                        Widgets.colorGrayLight),
                                                    0.16,
                                                    "popins",
                                                    false,
                                                    19,
                                                    TextAlign.center,
                                                    FontWeight.w500,
                                                    Colors.transparent),
                                                buildText(
                                                    "\$" +
                                                        (mapGanancias[0]
                                                                ["ganancias"] ??
                                                            "0"),
                                                    18,
                                                    _colorFromHex(
                                                        Widgets.colorSecundary),
                                                    0.16,
                                                    "popins",
                                                    false,
                                                    19,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    Colors.transparent),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Flexible(
                                      flex: 6,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Expanded(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                buildText(
                                                    "Viajes Totales \n del día",
                                                    15,
                                                    _colorFromHex(
                                                        Widgets.colorGrayLight),
                                                    0.16,
                                                    "popins",
                                                    false,
                                                    19,
                                                    TextAlign.center,
                                                    FontWeight.w500,
                                                    Colors.transparent),
                                                buildText(
                                                    (mapGanancias[0]
                                                            ["total_viajes"] ??
                                                        "0"),
                                                    18,
                                                    _colorFromHex(
                                                        Widgets.colorSecundary),
                                                    0.16,
                                                    "popins",
                                                    false,
                                                    19,
                                                    TextAlign.center,
                                                    FontWeight.bold,
                                                    Colors.transparent),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(children: _setGanancias(mapGanancias)),
                      ])
                    : Card(
                        color: _colorFromHex(Widgets.colorPrimary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: EdgeInsets.all(10),
                        elevation: 3,
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.all(10),
                              child: Text(
                                "No hay resultados",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: _colorFromHex(
                                        Widgets.colorSecundayLight)),
                              ),
                            )
                          ],
                        ),
                      )
              ])));
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
