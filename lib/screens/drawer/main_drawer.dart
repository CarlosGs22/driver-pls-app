import 'package:driver_please_flutter/screens/dashboard_screen.dart';
import 'package:driver_please_flutter/screens/gain_screen.dart';
import 'package:driver_please_flutter/screens/help_screen.dart';
import 'package:driver_please_flutter/screens/historial_trip_list_screen.dart';
import 'package:driver_please_flutter/screens/login_screen.dart';
import 'package:driver_please_flutter/screens/my_car_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_assigned_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_finished_screen.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainDrawer extends StatefulWidget {
  int _selectedDestination = 0;
  MainDrawer(this._selectedDestination, {Key? key}) : super(key: key);

  @override
  State<MainDrawer> createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          Container(
            color: _colorFromHex(Widgets.colorPrimary),
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/images/logoAppTransparente.png",
                  width: 175,
                  height: 175,
                ),
              ],
            ),
          ),
          Ink(
            color: widget._selectedDestination == 0
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.home),
                title: Text("Inicio",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 0,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Dashboard()));
                }),
          ),
          Ink(
            color: widget._selectedDestination == 1
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.trending_up_rounded),
                title: Text("Viajes asignados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 1,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const TripListAssignedScreen()));
                }),
          ),
          Ink(
            color: widget._selectedDestination == 2
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.trending_down_rounded),
                title: Text("Viajes finalizados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 2,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const TripListFinishedScreen()));
                }),
          ),
          // Ink(
          //   color: widget._selectedDestination == 3
          //       ? _colorFromHex(Widgets.colorSecundayLight)
          //       : Colors.transparent,
          //   child: ListTile(
          //       leading: const Icon(Icons.contact_support_rounded),
          //       title: Text("Contacto",
          //           style: GoogleFonts.poppins(
          //               fontSize: 15,
          //               color: _colorFromHex(Widgets.colorGray),
          //               fontWeight: FontWeight.w500)),
          //       selected: widget._selectedDestination == 3,
          //       onTap: () {
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => HelpScreen()));
          //       }),
          // ),

          Ink(
            color: widget._selectedDestination == 5
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.history),
                title: Text("Historial de viajes",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 5,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => HistorialTripListScreen()));
                }),
          ),
          Ink(
            color: widget._selectedDestination == 4
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: Text("Mis ganancias",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 4,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const GainScreen()));
                }),
          ),

          Ink(
            color: widget._selectedDestination == 7
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.car_repair),
                title: Text("Mis autos",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 7,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyCarScreen()));
                }),
          ),

          Ink(
            color: widget._selectedDestination == 6
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: Text("Cerrar sesión",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 5,
                onTap: () {
                  Navigator.pop(context);
                  UserPreferences().removeUser();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false);
                }),
          ),
          const Divider(
            height: 1,
            thickness: 1,
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "V " + Strings.labelVersion,
            ),
          ),
        ],
      ),
    );
  }
}
