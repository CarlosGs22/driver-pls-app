import 'package:driver_pls_flutter/screens/login_screen.dart';
import 'package:driver_pls_flutter/screens/viajes_list_screen.dart';
import 'package:driver_pls_flutter/utils/strings.dart';
import 'package:driver_pls_flutter/utils/widgets.dart';
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
        // Important: Remove any padding from the ListView.
        //padding: EdgeInsets.zero,
        children: <Widget>[
          SizedBox(
            height: 55.0,
            child: DrawerHeader(
                child: ListTile(
                  contentPadding: const EdgeInsets.only(left: 0.0, right: 0.0),
                  leading: Image.asset(
                    "assets/images/logoApp.png",
                    height: 39,
                    alignment: Alignment.centerLeft,
                  ),
                  title: Text(
                    Strings.labelAppNameTitle,
                    style:
                        GoogleFonts.poppins(fontSize: 24, color: Colors.white),
                  ),
                  //selected: _selectedDestination == 0,
                  onTap: () {},
                ),
                decoration: BoxDecoration(
                  color: _colorFromHex(Widgets.colorPrimary),
                ),
                margin: const EdgeInsets.all(0.0),
                padding: const EdgeInsets.only(top: 0, left: 0)),
          ),
          Ink(
              color: _selectedDestination == 0
                  ? _colorFromHex(Widgets.colorSecundayLight)
                  : Colors.transparent,
              child: ListTile(
                  leading: const Icon(Icons.home_filled),
                  title: Text("Inicio",
                      style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: _colorFromHex(Widgets.colorGray),
                          fontWeight: FontWeight.w500)),
                  selected: _selectedDestination == 0,
                  onTap: () async {})),
          Ink(
            color: _selectedDestination == 1
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.trending_up_rounded),
                title: Text("Listado de viajes",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 1,
                onTap: () => {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ViajesListScreen()))
                    }),
          ),
          Ink(
            color: _selectedDestination == 2
                ? _colorFromHex(Widgets.colorSecundayLight)
                : Colors.transparent,
            child: ListTile(
                leading: const Icon(Icons.exit_to_app_rounded),
                title: Text("Cerrar sesión",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: _colorFromHex(Widgets.colorGray),
                        fontWeight: FontWeight.w500)),
                selected: _selectedDestination == 2,
                onTap: () => {
                      Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                              builder: (context) => const LoginScreen()),
                          (Route<dynamic> route) => false)
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
