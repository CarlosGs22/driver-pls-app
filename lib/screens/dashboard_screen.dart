import 'package:driver_please_flutter/screens/MapPage.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/screens/support_screen.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Dashboard extends StatefulWidget {
  Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  bool openDrawer = false;

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
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
              title: const Text(Strings.labelDashboard),
              elevation: 0.1,
              backgroundColor: _colorFromHex(Widgets.colorPrimary),
              actions: [
                IconButton(onPressed: (){
                  Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                   MapPage()));

                }, icon: Icon(Icons.ac_unit))
              ],
             
            ),
            drawer: const MainDrawer(0),
            body: Center(
              /** Card Widget **/
              child: Card(
                elevation: 50,
                shadowColor: Colors.black,
                color: _colorFromHex(Widgets.colorSecundayLight),
                child: SizedBox(
                    width: 350,
                    height: 500,
                    child: Center(
                      child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset(
                                  "assets/images/logoApp.png",
                                  width: 170,
                                  height: 170,
                                ), //CircleAvatar
                                const SizedBox(
                                  height: 10,
                                ), //SizedBox
                                Text(
                                  Strings.labelAppNameTitle,
                                  style: TextStyle(
                                    fontSize: 30,
                                    color: Colors.green[900],
                                    fontWeight: FontWeight.w500,
                                  ), //Textstyle
                                ), //Text
                                const SizedBox(
                                  height: 10,
                                ), //SizedBox
                                Text(
                                  'Si tienes dudas y/o aclaraciones no dudes en usar la opción de soporte',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: _colorFromHex(Widgets.colorPrimary),
                                  ), //Textstyle
                                ), //Text
                                const SizedBox(
                                  height: 10,
                                ), //SizedBox
                                SizedBox(
                                  width: 115,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const SupportScreen()));
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                _colorFromHex(
                                                    Widgets.colorPrimary))),
                                    child: Padding(
                                      padding: const EdgeInsets.all(7),
                                      child: Row(
                                        children: const [
                                          Icon(Icons.touch_app),
                                          Text('Visitar')
                                        ],
                                      ),
                                    ),
                                  ),
                                  // RaisedButton is deprecated and should not be used
                                  // Use ElevatedButton instead

                                  // child: RaisedButton(
                                  //   onPressed: () => null,
                                  //   color: Colors.green,
                                  //   child: Padding(
                                  //     padding: const EdgeInsets.all(4.0),
                                  //     child: Row(
                                  //       children: const [
                                  //         Icon(Icons.touch_app),
                                  //         Text('Visit'),
                                  //       ],
                                  //     ), //Row
                                  //   ), //Padding
                                  // ), //RaisedButton
                                ) //SizedBox
                              ],
                            ), //Column
                          )), //Padding
                    )), //SizedBox
              ), //Card
            )));
  }
}
