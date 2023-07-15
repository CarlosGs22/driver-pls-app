import 'package:driver_please_flutter/screens/dashboard_screen.dart';
import 'package:driver_please_flutter/screens/gain_screen.dart';
import 'package:driver_please_flutter/screens/help_screen.dart';
import 'package:driver_please_flutter/screens/login_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_assigned_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_finished_screen.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MainDrawer extends StatelessWidget {
  const MainDrawer(this._selectedDestination, {Key? key}) : super(key: key);

  final int _selectedDestination;

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
            color: _selectedDestination == 0
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.home),
                title: Text("Inicio",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 0,
                onTap: () => {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Dashboard()))
                    }),
          ),
          Ink(
            color: _selectedDestination == 1
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.trending_up_rounded),
                title: Text("Viajes asignados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 1,
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TripListAssignedScreen()))
                    }),
          ),
          Ink(
            color: _selectedDestination == 2
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.trending_down_rounded),
                title: Text("Viajes finalizados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 2,
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const TripListFinishedScreen()))
                    }),
          ),
          Ink(
            color: _selectedDestination == 3
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.contact_support_rounded),
                title: Text("Contacto",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 3,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HelpScreen()));
                }),
          ),
          Ink(
            color: _selectedDestination == 4
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.attach_money_outlined),
                title: Text("Mis ganancias",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 4,
                onTap: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => GainScreen(mapGanancias: const {})));
                }),
          ),
          Ink(
            color: _selectedDestination == 5
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: Text("Cerrar sesión",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 5,
                onTap: () {
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
