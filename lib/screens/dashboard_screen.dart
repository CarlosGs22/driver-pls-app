import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/screens/support_screen.dart';
import 'package:driver_please_flutter/screens/update_profile.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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

  @override
  void initState() {
    super.initState();
    openDrawer = false;
  }

  @override
  Widget build(BuildContext context) {
    var user = Provider.of<UserProvider>(context);

    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
            onDrawerChanged: (isOpened) {
              if (isOpened) {
                setState(() {
                  openDrawer = true;
                });
              }else{
                  setState(() {
                  openDrawer = false;
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
                // IconButton(
                //     onPressed: () {
                //       Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => MapPage()));
                //     },
                //     icon: Icon(Icons.ac_unit))
              ],
            ),
            drawer: MainDrawer(0),
            body: Container(
                color: Colors.black12,
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
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                      user.user.name + " " + user.user.lastName,
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: FlatButton(
                      padding: EdgeInsets.all(20),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      color: Color(0xFFF5F6F9),
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SupportScreen()));
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
