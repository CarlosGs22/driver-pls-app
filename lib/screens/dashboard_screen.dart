import 'dart:convert';

import 'package:driver_please_flutter/models/cliente_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/screens/support_screen.dart';
import 'package:driver_please_flutter/screens/trip_detail_screen.dart';
import 'package:driver_please_flutter/screens/update_profile.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin? flutterNotificationPlugin;

  bool openDrawer = false;

  bool isLoading = false;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  _checkFirebaseToken(String idAgent) {
    if (validateNullOrEmptyString(idAgent) == null) {
      return;
    }

    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    final token = _firebaseMessaging.getToken().then((value) =>
        sendRegistrationToServer(value.toString(), idAgent, cliente.path));
  }

  _redirectNotification(Map<String, dynamic> params) {
    try {
      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      setState(() {
        isLoading = true;
      });

      HttpClass.httpData(
              context,
              Uri.parse(cliente.path + "aplicacion/getViaje.php"),
              params,
              {},
              "POST")
          .then((response) {
        Map<String, dynamic> mapData = response["data"];

        List<dynamic> jsonResponse = mapData["viaje"];

        List<ViajeModel> auxViajeList = [];

        for (var element in jsonResponse) {
          auxViajeList.add(ViajeModel(
            idViaje: element["id_viaje"].toString(),
            ocupantes: int.tryParse(element["ocupantes"]) ?? 0,
            nombreEmpresa: element["nombre_empresa"],
            idEmp: int.tryParse(element["id_emp"]) ?? 0,
            nombreSucursal: element["nombre_sucursal"],
            idSuc: int.tryParse(element["id_suc"]) ?? 0,
            tipo: element["tipo"],
            fechaViaje: element["fecha"],
            horaViaje: element["hora"],
            totalPages: 0,
            status: int.tryParse(element["estatus"]) ?? 0,
            fechaInicio: element["fecha_inicio"] ?? "",
            fechaFin: element["fecha_fin"] ?? "",
            confirmado: element["confirmado"] ?? "",
            incidencias: element["percances"] ?? "",
            poligono: element["poligono"] ?? "",
            subtotal: double.tryParse((validateNullOrEmptyString(
                            element["subtotal"].toString()) ??
                        0.0)
                    .toString()) ??
                0.0,
            descripcion: element["descripcion"] ?? "",
            idRuta: element["id_ruta"] ?? "",
            comentario: element["comentario"] ?? "",
          ));
        }

        setState(() {
          isLoading = false;
        });

        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => TripDetailScreen(
                      viaje: auxViajeList[0],
                      redirect: null,
                      panelVisible: true,
                      bandCancelTrip: false,
                      bandItinerario: false,
                    )));
      });
    } catch (e) {
      print(e.toString());

      setState(() {
        isLoading = false;
      });
    }
  }

  sendRegistrationToServer(String token, String id, String path) {
    Map<String, dynamic> params = {"idCon": id, "token": token};

    HttpClass.httpData(context, Uri.parse(path + "aplicacion/updateToken.php"),
            params, {}, "POST")
        .then((response) {
      print("TOKEN");
      Utility.printWrapped(response.toString());
    });
  }

  @override
  void initState() {
    super.initState();
    openDrawer = false;

    _firebaseMessaging = FirebaseMessaging.instance;

    _configureFirebaseMessaging();
    _configureLocalNotifications();

    insertTripNetwork(context).then((value) {
      if (value["code"] == 200) {
        finishTripNetwork(value, context);
      } else {
        if (value["code"] == 500) {
          MotionToast.error(
                  title: const Text("Error"),
                  description: Text(value["payload"] ??
                      "Ocurrió un error al registrar viaje"))
              .show(context);
        }
      }
    });

    insertIncidenceNetwork(context).then((value) {
      if (value["code"] == 200) {
        MotionToast.success(
                title: const Text("Registro exitoso"),
                description: Text("Se registro la incidencia correctamente"))
            .show(context);
      } else {
        if (value["code"] == 500) {
          MotionToast.error(
                  title: const Text("Error"),
                  description: Text(value["payload"] ??
                      "Ocurrió un error al registrar viaje"))
              .show(context);
        }
      }
    });
  }

  void _configureFirebaseMessaging() {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("TAP SOBRE NOTIFICACION BACKGROUND ");
      print(message.data.toString());
      if (message.data.isEmpty) {
        return;
      }
      _redirectNotification(message.data);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print(
          'Notificación recibida en primer plano: ${message.notification?.body}');

      print("DATOS" + message.data.toString());

      if (message.data.isEmpty) {
        return;
      }

      _createNotification(message.data);
    });

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message?.data == null) {
        return;
      }

      if (message!.data.isEmpty) {
        return;
      }
      _redirectNotification(message.data);
    });
  }

  void _configureLocalNotifications() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      await _firebaseMessaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      var initializationSettingsAndroid =
          const AndroidInitializationSettings('app_icon');
      var initializationSettingsIOS = const IOSInitializationSettings();
      var initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      flutterNotificationPlugin = FlutterLocalNotificationsPlugin();
      flutterNotificationPlugin?.initialize(
        initializationSettings,
        onSelectNotification: (payload) {
          print("TAP SOBRE NOTIFICACION LOCAL");

          Map<String, dynamic> dataNotification =
              jsonDecode(payload.toString());
          print(dataNotification);

          _redirectNotification(dataNotification);
        },
      );
    } else {
      print('User declined or has not accepted permission');
    }
  }

  void _createNotification(Map<String, dynamic> data) async {
    var androidPlatformChannelSpecifics = const AndroidNotificationDetails(
      'mychannel',
      'title',
      importance: Importance.max,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    var iOSPlatformChannelSpecifics = const IOSNotificationDetails(
      presentSound: true,
      presentBadge: true,
    );

    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    print("33545435354");
    print(data);

    flutterNotificationPlugin?.show(
      0,
      data["title"],
      data["descripcion"],
      platformChannelSpecifics,
      payload: jsonEncode(data),
    );
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);
    _checkFirebaseToken(user.user.id);

    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
            onDrawerChanged: (isOpened) {
              if (isOpened) {
                setState(() {
                  openDrawer = true;
                });
              } else {
                setState(() {
                  openDrawer = false;
                });
              }
            },
            appBar: AppBar(
              titleTextStyle: GoogleFonts.poppins(
                  fontSize: 19,
                  color: _colorFromHex(Widgets.colorWhite),
                  fontWeight: FontWeight.w500),
              title: const Text(Strings.labelDashboard),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
              actions: [
                // IconButton(
                //     onPressed: () {
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => MapPage()));
                //     },
                //     icon: Icon(Icons.ac_unit))
              ],
            ),
            drawer: MainDrawer(0),
            body: isLoading
                ? buildCircularProgress(context)
                : Container(
                    color: _colorFromHex(Widgets.colorWhite),
                    child: Column(children: [
                      SizedBox(height: 20),
                      Card(
                        elevation: 50,
                        shadowColor: Colors.black,
                        //color: _colorFromHex(Widgets.colorSecundayLight),
                        child: SizedBox(
                            width: 350,
                            height: 299,
                            child: Center(
                              child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          color: Colors.transparent,
                                          height: 115,
                                          width: 115,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: AssetImage(
                                                "assets/images/user.png"),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "Driver",
                                          style: TextStyle(
                                            fontSize: 24,
                                            color: Colors.green[900],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          user.user.name +
                                              " " +
                                              user.user.lastName,
                                          style: TextStyle(
                                            fontSize: 20,
                                            color: Colors.green[900],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        SizedBox(
                                          width: 200,
                                          child: ElevatedButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            UpdateProfile()));
                                              },
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          _colorFromHex(Widgets
                                                              .colorPrimary))),
                                              child: const Text('Mis datos')),
                                        ),
                                      ],
                                    ),
                                  )),
                            )),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: FlatButton(
                          padding: EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          color: Color(0xFFF5F6F9),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const SupportScreen()));
                          },
                          child: Row(
                            children: [
                              SizedBox(width: 20),
                              Expanded(
                                  child: Text(
                                "Dudas y aclaraciones",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _colorFromHex(Widgets.colorPrimary),
                                  fontWeight: FontWeight.w600,
                                ),
                              )),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: _colorFromHex(Widgets.colorPrimary),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]))));
  }

  Future<bool> showExitPopup() async {
    if (openDrawer) {
      setState(() {
        openDrawer = false;
      });

      Navigator.pop(context);

      return false;
    }
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
                    Navigator.of(context).pop(true);
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
