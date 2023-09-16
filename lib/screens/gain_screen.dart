import 'dart:convert';
import 'dart:io';

import 'package:driver_please_flutter/providers/agent_provider.dart';
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

class GainScreen extends StatefulWidget {
  Map<String, dynamic> mapGanancias = {};

  GainScreen({Key? key, required this.mapGanancias}) : super(key: key);

  @override
  State<GainScreen> createState() => _GainScreenState();
}

Color _colorFromHex(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

class _GainScreenState extends State<GainScreen> {
  TextEditingController dateInicialController = TextEditingController();
  TextEditingController dateFinalController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  bool openDrawer = false;

  bool isLoading = false;

  bool loadData = false;

  @override
  void initState() {
     final DateTime now = DateTime.now();
  final DateFormat formatter = DateFormat('yyyy-MM-dd');


    dateInicialController.text =  formatter.format(now);
    dateFinalController.text =  formatter.format(now);
    
    super.initState();

    if (validateNullOrEmptyString(widget.mapGanancias["fecha_inicial"]) !=
        null) {
      dateInicialController.text = widget.mapGanancias["fecha_inicial"];
    }

    if (validateNullOrEmptyString(widget.mapGanancias["fecha_final"]) != null) {
      dateFinalController.text = widget.mapGanancias["fecha_final"];
    }

    if (widget.mapGanancias["option"] == null) {
      _handleInicial(context);
    }
  }

  _handleInicial(BuildContext context) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    var idConductor = user.id;
    setState(() {
      isLoading = true;
       loadData = true;
    });

    HttpClass.httpData(
            context,
            Uri.parse(
                "https://www.driverplease.net/aplicacion/getGanancias.php?fecha_inicial=&fecha_final=&id_conductor=$idConductor"),
            {},
            {},
            "POST")
        .then((response) {
      Utility.printWrapped(response.toString());
      setState(() {
        isLoading = false;
       
      });

      if (!response["status"] ||
          response["data"] == null ||
          (response["data"] as List).isEmpty) {
        MotionToast.error(
                title: const Text("Error"),
                description: const Text("No hay datos que mostrar"))
            .show(context);
        return;
      }

      Map<String, dynamic> mapGanancias =
          json.decode(json.encode(response["data"][0]));

      if (mapGanancias.isNotEmpty) {
        widget.mapGanancias = mapGanancias;
      }
    });
  }

  _filterResponse(BuildContext context, var option) {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    var txtFechaInicial = dateInicialController.text;
    var txtFechaFinal = dateFinalController.text;
    var idConductor = user.id;

    HttpClass.httpData(
            context,
            Uri.parse(
                "https://www.driverplease.net/aplicacion/getGanancias.php?fecha_inicial=$txtFechaInicial&fecha_final=$txtFechaFinal&id_conductor=$idConductor"),
            {},
            {},
            "GET")
        .then((response) {
      Utility.printWrapped(response.toString());
      setState(() {
        isLoading = false;
        loadData = true;
      });

      if (!response["status"] ||
          response["data"] == null ||
          (response["data"] as List).isEmpty) {
        setState(() {
          widget.mapGanancias = {};
        });
        MotionToast.error(
                title: const Text("Error"),
                description: const Text("No hay datos que mostrar"))
            .show(context);
        return;
      }

      Map<String, dynamic> mapGanancias =
          json.decode(json.encode(response["data"][0]));

      if (mapGanancias.isNotEmpty) {
        if (option == "INICIAL") {
          widget.mapGanancias = mapGanancias;
        } else {
          mapGanancias.addAll({"option" : "SEARCH"});
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      GainScreen(mapGanancias: mapGanancias)));
        }
      } else {
        widget.mapGanancias = {};
      }
    });
  }

  void _handleFilterClick() {
    final form = formKey.currentState;

    setState(() {
      isLoading = true;
    });

    if (validateNullOrEmptyString(dateInicialController.text) == null ||
        validateNullOrEmptyString(dateFinalController.text) == null) {
      setState(() {
        isLoading = false;
      });

      MotionToast.error(
              title: const Text("Error"),
              description: const Text("Complete el formulario"))
          .show(context);

      return;
    }

    if (form!.validate()) {
      form.save();
      _filterResponse(context, "FORM");
    }
  }

  Widget getCardItem(var titleGanancia, var textGanancia, var titleViaje,
      var textViaje, var titlePeriodo, var textPeriodo, double size) {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Card(
          margin: EdgeInsets.all(10),
          color: Colors.white,
          shadowColor: _colorFromHex(Widgets.colorPrimary),
          elevation: 10,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                width: MediaQuery.of(context).size.width,
                color: _colorFromHex(Widgets.colorSecundayLight),
                child: buildText(
                    "Resultado",
                    size,
                    _colorFromHex(Widgets.colorPrimary),
                    0,
                    "poppins",
                    false,
                    0,
                    TextAlign.center,
                    FontWeight.normal,
                    Colors.transparent),
              ),
              buildText(
                  textGanancia,
                  size,
                  _colorFromHex(Widgets.colorPrimary),
                  0,
                  "poppins",
                  false,
                  0,
                  TextAlign.start,
                  FontWeight.normal,
                  Colors.transparent),
              Container(
                child: buildText(
                    titleGanancia,
                    size,
                    _colorFromHex(Widgets.colorPrimary),
                    0,
                    "poppins",
                    false,
                    0,
                    TextAlign.start,
                    FontWeight.normal,
                    Colors.transparent),
              ),
              SizedBox(
                height: 20,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  buildText(
                      textViaje,
                      size,
                      _colorFromHex(Widgets.colorPrimary),
                      0,
                      "poppins",
                      false,
                      0,
                      TextAlign.start,
                      FontWeight.normal,
                      Colors.transparent),
                  buildText(
                      titleViaje,
                      size,
                      _colorFromHex(Widgets.colorPrimary),
                      0,
                      "poppins",
                      false,
                      0,
                      TextAlign.start,
                      FontWeight.normal,
                      Colors.transparent),
                  SizedBox(
                    height: 20,
                  ),
                  buildText(
                      textPeriodo,
                      size,
                      _colorFromHex(Widgets.colorPrimary),
                      0,
                      "poppins",
                      false,
                      0,
                      TextAlign.start,
                      FontWeight.normal,
                      Colors.transparent),
                  buildText(
                      titlePeriodo,
                      size,
                      _colorFromHex(Widgets.colorPrimary),
                      0,
                      "poppins",
                      false,
                      0,
                      TextAlign.start,
                      FontWeight.normal,
                      Colors.transparent),
                ],
              ),
            ],
          ),
        ));
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
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
              title: const Text(Strings.labelTripGain),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
            ),
            drawer:  MainDrawer(4),
            body: isLoading
                ? buildCircularProgress(context)
                : Column(
                    children: [
                      Card(
                          color: Colors.white,
                          elevation: 6.0,
                          margin: EdgeInsets.all(15),
                          child: Form(
                              key: formKey,
                              child: Column(
                                children: <Widget>[
                                  ListTile(
                                    leading: const Icon(
                                        Icons.calendar_today_outlined),
                                    title: TextFormField(
                                      readOnly: true,
                                      controller: dateInicialController,
                                      decoration: const InputDecoration(
                                        hintText: 'Selecciona fecha inicial',
                                        labelText: 'Fecha inicial',
                                      ),
                                      validator: (value) =>
                                          validateField(value.toString()),
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                               locale:  const Locale('es', 'MX'),
                                                context: context,
                                                initialDate: DateTime
                                                    .now(), 
                                                firstDate: DateTime(
                                                    2000), 
                                                lastDate: DateTime(2101));

                                        if (pickedDate != null) {
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);

                                          setState(() {
                                            dateInicialController.text =
                                                formattedDate;
                                          });
                                        }
                                      },
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  ListTile(
                                    leading: const Icon(
                                        Icons.calendar_today_outlined),
                                    title: TextFormField(
                                         readOnly: true,
                                      controller: dateFinalController,
                                      decoration: const InputDecoration(
                                        hintText: 'Selecciona fecha final',
                                        labelText: 'Fecha final',
                                      ),
                                      validator: (value) =>
                                          validateField(value.toString()),
                                      onTap: () async {
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                              locale:  const Locale('es', 'MX'),
                                              
                                                context: context,
                                                initialDate: DateTime
                                                    .now(), 
                                                firstDate: DateTime(
                                                    2000), 
                                                lastDate: DateTime(2101));

                                        if (pickedDate != null) {
                                          print(pickedDate);
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                          print(formattedDate);

                                          setState(() {
                                            dateFinalController.text =
                                                formattedDate;
                                          });
                                        } else {
                                          print("Date is not selected");
                                        }
                                      },
                                      keyboardType: TextInputType.datetime,
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Padding(
                                    padding:
                                        EdgeInsets.only(left: 40, right: 40),
                                    child: longButtons(
                                        "Filtrar", _handleFilterClick,
                                        color: _colorFromHex(
                                            Widgets.colorPrimary)),
                                  ),
                                  SizedBox(height: 15),
                                ],
                              ))),
                      widget.mapGanancias.isNotEmpty
                          ? Column(
                              children: [
                                Row(
                                  children: <Widget>[
                                    Expanded(
                                      flex: 10,
                                      child: Column(
                                        children: [
                                          getCardItem(
                                              "Total",
                                              ("\$" +
                                                  (validateNullOrEmptyString(
                                                          widget.mapGanancias[
                                                              "ganancias"]) ??
                                                      "0")),
                                              "Viajes",
                                              widget
                                                  .mapGanancias["total_viajes"],
                                              "Periodo",
                                              (widget.mapGanancias["periodo"]),
                                              23),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : const SizedBox()
                    ],
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
