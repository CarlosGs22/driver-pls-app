import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/dashboard_screen.dart';
import 'package:driver_please_flutter/screens/gain_screen.dart';
import 'package:driver_please_flutter/screens/help_screen.dart';
import 'package:driver_please_flutter/screens/historial_trip_list_screen.dart';
import 'package:driver_please_flutter/screens/login_screen.dart';
import 'package:driver_please_flutter/screens/my_car_screen.dart';
import 'package:driver_please_flutter/screens/provider_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_assigned_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_finished_screen.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/shared_preference_cliente.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

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
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    return Drawer(
      backgroundColor: _colorFromHex(Widgets.colorGrayBackground),
      child: ListView(
        children: <Widget>[
          Container(
            color: _colorFromHex(Widgets.colorPrimary),
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.network(
                  cliente.logo != null || cliente.logo != ""
                      ? cliente.logo
                      : "assets/images/MovilisticaLogo.png",
                  width: 120,
                  height: 120,
                ),
              ],
            ),
          ),
          Ink(
            color: widget._selectedDestination == 0
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.home,
                    color: widget._selectedDestination == 0
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Inicio",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 0
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
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
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.trending_up,
                    color: widget._selectedDestination == 1
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Viajes asignados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 1
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
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
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.trending_down,
                    color: widget._selectedDestination == 2
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Viajes finalizados",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 2
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
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
          //       ? _colorFromHex(Widgets.colorPrimary)
          //       : Colors.transparent,
          //   child: ListTile(
          //       leading: const Icon(Icons.contact_support_rounded),
          //       title: Text("Contacto",
          //           style: GoogleFonts.poppins(
          //               fontSize: 15,
          //               color: _colorFromHex(Widgets.colorWhite),
          //               fontWeight: FontWeight.w500)),
          //       selected: widget._selectedDestination == 3,
          //       onTap: () {
          //         Navigator.push(context,
          //             MaterialPageRoute(builder: (context) => HelpScreen()));
          //       }),
          // ),

          Ink(
            color: widget._selectedDestination == 5
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.history,
                    color: widget._selectedDestination == 5
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Historial de viajes",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 5
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
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
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.monetization_on,
                    color: widget._selectedDestination == 4
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Mis ganancias",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 4
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 4,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const GainScreen()));
                }),
          ),

          Ink(
            color: widget._selectedDestination == 7
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.car_repair,
                    color: widget._selectedDestination == 7
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Mis autos",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 7
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
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
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.exit_to_app,
                    color: widget._selectedDestination == 6
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Cerrar sesión",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 6
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 5,
                onTap: () {
                  Navigator.pop(context);
                  UserPreferences().removeUser();
                  ClientePreferences().removeCliente();

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProviderScreen()),
                    (Route<dynamic> route) => false,
                  );
                }),
          ),

           Ink(
            color: widget._selectedDestination == 8
                ? _colorFromHex(Widgets.colorPrimary)
                : Colors.transparent,
            child: ListTile(
                leading: Icon(Icons.close,
                    color: widget._selectedDestination == 8
                        ? _colorFromHex(Widgets.colorWhite)
                        : _colorFromHex(Widgets.colorWhite)),
                title: Text("Eliminar cuenta",
                    style: GoogleFonts.poppins(
                        fontSize: 15,
                        color: widget._selectedDestination == 8
                            ? _colorFromHex(Widgets.colorWhite)
                            : _colorFromHex(Widgets.colorWhite),
                        fontWeight: FontWeight.w500)),
                selected: widget._selectedDestination == 8,
                onTap: () async {
                  final cliente =
                      Provider.of<ClienteProvider>(context, listen: false)
                          .cliente;

                 
                       

                  try {
                    if (await canLaunchUrl(
                        Uri.parse(cliente.path + "aplicacion/deleteCuenta.php"))) {
                      launchUrl(Uri.parse(cliente.path + "aplicacion/deleteCuenta.php"));
                    } else {
                      MotionToast.error(
                              title: const Text("Error"),
                              description:
                                  const Text("No se puede abrir el enlace"))
                          .show(context);
                    }
                  } catch (e) {
                    MotionToast.error(
                            title: const Text("Error"),
                            description: const Text("Ocurrió un error"))
                        .show(context);
                  }
                }),
          ),

          
          const Divider(
            height: 1,
            thickness: 1,
          ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context).style,
                children: [
                  TextSpan(
                    text: "Powered by ",
                    style: TextStyle(color: Colors.white),
                  ),
                  TextSpan(
                    text: "MOVILÍSTICA",
                    style: TextStyle(
                        color: _colorFromHex(Widgets.colorSecundayLight2)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
