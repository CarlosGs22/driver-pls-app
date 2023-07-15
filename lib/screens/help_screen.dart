import 'dart:io';

import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpScreen extends StatefulWidget {
  static const routeName = '/ayuda-screen';

  @override
  _HelpScreentState createState() => _HelpScreentState();
}

class _HelpScreentState extends State<HelpScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isLoading = false;
  bool openDrawer = false;

  @override
  void initState() {
    super.initState();
  }

  List<Widget> setPaddingCard() {
    List<Widget> generalList = [];

    List<dynamic> mapData = [];

    mapData.add({
      "id": "Correo",
      "url": "aclaraciones-drivers@appdriverplease.com",
      "index": 0
    });
    mapData.add({"id": "Celular", "url": "6863464658", "index": 1});

    for (var val in mapData) {
      Uri link;
      var message = "Hola buen día, tengo una duda sobre";
      var valor = val["url"];
      var cont = val["index"];
      var label = val["id"];
      Widget item = Padding(
        padding: const EdgeInsetsDirectional.all(8),
        child: Container(
          width: MediaQuery.of(context).size.width * .95,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                blurRadius: 5,
                color: Color(0x3416202A),
                offset: Offset(0, 2),
              )
            ],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 8),
            child: InkWell(
              onTap: () async {
                Uri link = Uri();
                switch (cont) {
                  case 0:
                    link = Uri(
                      scheme: 'mailto',
                      path: valor,
                      query: 'body=$message&subject=Driver Please',
                    );
                    break;
                  case 1:
                    link = Uri(
                      scheme: 'tel',
                      path: valor,
                    );
                    break;
                }

                try {
                  if (await canLaunchUrl(link)) {
                    await launchUrl(link, mode: LaunchMode.externalApplication);
                  } else {
                    MotionToast.error(
                            title: const Text("Error"),
                            description:
                                const Text("No se puede abrir el enlace"))
                        .show(context);
                  }
                } catch (error) {
                  print("AKIII");
                  print(error);
                  MotionToast.error(
                          title: const Text("Error"),
                          description:
                              const Text("Error No se puede abrir el enlace"))
                      .show(context);
                }
              },
              child: Row(
                children: [
                  setIcon(cont),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                    child: Text(
                      label,
                      style:
                          TextStyle(color: _colorFromHex(Widgets.colorPrimary)),
                    ),
                  ),
                  Expanded(
                    child: Align(
                      alignment: const AlignmentDirectional(0.9, 0),
                      child: Icon(
                        Icons.arrow_forward_ios,
                        color: _colorFromHex(Widgets.colorPrimary),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      generalList.add(item);
    }

    return generalList;
  }

  IconButton setIcon(int index) {
    switch (index) {
      case 0:
        return  IconButton(
          // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
          icon: FaIcon(
            FontAwesomeIcons.envelope,
            size: 24,
            color: _colorFromHex(Widgets.colorPrimary),
          ),
          onPressed: null,
        );
      case 1:
        return  IconButton(
          // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
          icon: FaIcon(
            FontAwesomeIcons.phone,
            size: 24,
            color: _colorFromHex(Widgets.colorPrimary),
          ),
          onPressed: null,
        );
      default:
        return  IconButton(
          // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
          icon: FaIcon(
            FontAwesomeIcons.xmark,
            size: 24,
            color:_colorFromHex(Widgets.colorPrimary),
          ),
          onPressed: null,
        );
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
                  fontSize: 19,
                  color: Colors.white,
                  fontWeight: FontWeight.w500),
              title: const Text(Strings.labelContact),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
            ),
            drawer: const MainDrawer(3),
            backgroundColor: Colors.white,
            body: Center(
                child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Image(
                    image: AssetImage('assets/images/logoApp.png'),
                    height: 140,
                  ),
                  Padding(
                      padding: const EdgeInsets.only(
                          bottom: 20, top: 20, right: 8, left: 8),
                      child: Text(
                          "Si tienes algun problema \n no dudes en contactarnos",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: _colorFromHex(Widgets.colorPrimary),
                              fontSize: 24))),
                  Wrap(direction: Axis.vertical, children: setPaddingCard())
                ],
              ),
            ))));
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
