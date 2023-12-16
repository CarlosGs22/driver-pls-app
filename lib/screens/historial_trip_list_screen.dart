import 'dart:convert';
import 'dart:io';

import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/screens/support_screen.dart';

import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/services/viaje_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialTripListScreen extends StatefulWidget {
  const HistorialTripListScreen({Key? key}) : super(key: key);

  @override
  _TripListState createState() => _TripListState();
}

class _TripListState extends State<HistorialTripListScreen> {
  final int _pageSize = 10;
  int _pageNumber = 1;
  int _totalPages = 1;
  List<ViajeModel> _viajes = [];
 

  bool openDrawer = false;

  bool isLoading = false;

  TextEditingController dateInicialController = TextEditingController();
  TextEditingController dateFinalController = TextEditingController();

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _getViajes("","");

    dateInicialController.text = "";
    dateFinalController.text = "";

  }

  _getViajes(var inicialDate, var endDate) async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;


    var txtFechaInicial = dateInicialController.text;
    var txtFechaFinal = dateFinalController.text;

    
    setState(() {
      isLoading = true;
    });

    List<ViajeModel> viajes = await ViajeService.getHistorialTripList(context,
        pageNumber: _pageNumber,
        pageSize: _pageSize,
        idUser: user.id,
        status: "0",
        order: "2",
        inicialDate: inicialDate,
        endDate: endDate,
        path: cliente.path);
    if (viajes.isNotEmpty) {
      setState(() {
        _viajes = viajes;
        _totalPages = viajes.first.totalPages;
        isLoading = false;
      });

    } else {
      setState(() {
        isLoading = false;
      });
      MotionToast.error(
              title: const Text("Error"),
              description: const Text("No hay datos que mostrar"))
          .show(context);
      return;
    }
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  _handleFilterClick() {
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
     _getViajes(dateInicialController.text,dateFinalController.text);
    }
  }

  _handleCleanFilter(){
    _getViajes("", "");
  }

  @override
  Widget build(BuildContext context) {

 final user = Provider.of<UserProvider>(context, listen: false).user;


    // return WillPopScope(
    //     onWillPop: showExitPopup,
    //     child: 
    return Scaffold(
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
            title: const Text(Strings.labelHistorialListTrip),
            elevation: 0.1,
            backgroundColor: _colorFromHex(Widgets.colorPrimary),
            actions: [
              IconButton(
                  icon: const Icon(Icons.support_agent_rounded),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SupportScreen()));
                  })
            ],
          ),
          drawer:  MainDrawer(2),
          body: isLoading ? buildCircularProgress(context) :
          
          Column(
            children: [
              Card(
                  color: Colors.white,
                  elevation: 6.0,
                  margin:
                      EdgeInsets.only(top: 15, bottom: 15, left: 5, right: 5),
                  child: Form(
                      key: formKey,
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined),
                            title: TextFormField(
                              controller: dateInicialController,
                              decoration: const InputDecoration(
                                hintText: 'Selecciona fecha inicial',
                                labelText: 'Fecha inicial',
                              ),
                              validator: (value) =>
                                  validateField(value.toString()),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        DateTime.now(), //get today's date
                                    firstDate: DateTime(
                                        2000),
                                    lastDate: DateTime(2101));

                                if (pickedDate != null) {
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);

                                  setState(() {
                                    dateInicialController.text = formattedDate;
                                  });
                                }
                              },
                              keyboardType: TextInputType.datetime,
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.calendar_today_outlined),
                            title: TextFormField(
                              controller: dateFinalController,
                              decoration: const InputDecoration(
                                hintText: 'Selecciona fecha final',
                                labelText: 'Fecha final',
                              ),
                              validator: (value) =>
                                  validateField(value.toString()),
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate:
                                        DateTime.now(), //get today's date
                                    firstDate: DateTime(
                                        2000), //DateTime.now() - not to allow to choose before today.
                                    lastDate: DateTime(2101));

                                if (pickedDate != null) {
                                  print(pickedDate);
                                  String formattedDate =
                                      DateFormat('yyyy-MM-dd')
                                          .format(pickedDate);
                                  print(formattedDate);

                                  setState(() {
                                    dateFinalController.text = formattedDate;
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
                            padding: EdgeInsets.only(left: 40, right: 40),
                            child: longButtons("Filtrar", _handleFilterClick,
                                color: _colorFromHex(Widgets.colorPrimary)),
                          ),
                          SizedBox(height: 5),
                    
                           Padding(
                            padding: EdgeInsets.only(left: 40, right: 40),
                            child: IconButton(onPressed: (){
                              setState(() {
                              dateInicialController.text = "";
                              dateFinalController.text = "";
                              });
                              _getViajes("", "");

                            }, icon: Icon(Icons.close))
                          ),
                        ],
                      ))),
              Expanded(
                child: ListView.builder(
                  itemCount: _viajes.length,
                  itemBuilder: (BuildContext context, int index) {
                    ViajeModel viaje = _viajes[index];

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
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 2, bottom: 2),
                                      alignment: Alignment.topLeft,
                                      child: Text(
                                        setFormatDatetime(
                                            viaje.fechaInicio.toString()),
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: _colorFromHex(
                                                Widgets.colorSecundayLight),
                                            fontSize: 16),
                                      ),
                                    ),
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
                                    buildBubblePadding(
                                        Icons.circle,
                                        _colorFromHex(Widgets.colorPrimary),
                                        "Costo del viaje: \$${viaje.subtotal}",
                                        _colorFromHex(
                                            Widgets.colorSecundayLight),
                                        8),
                                  ],
                                ),
                                leading: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      color: Colors.transparent,
                                      child: Text(
                                        "ID",
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: _colorFromHex(
                                                Widgets.colorSecundayLight),
                                            fontSize: 20),
                                      ),
                                    ),
                                    Container(
                                      color: Colors.transparent,
                                      child: Text(
                                        viaje.idViaje,
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic,
                                            color: _colorFromHex(
                                                Widgets.colorSecundayLight),
                                            fontSize: 20),
                                      ),
                                    ),
                                  ],
                                ))));
                  },
                ),
              ),
              ],
          ),
        );
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
