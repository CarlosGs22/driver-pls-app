import 'dart:io';
import 'dart:ui';

import 'package:driver_please_flutter/models/categoria_soporte_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/services/categoria_soporte_service.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentScreen extends StatefulWidget {
  ViajeModel viaje;
  var redirectTo;
  CommentScreen({
    Key? key,
    required this.viaje,
    required this.redirectTo,
  }) : super(key: key);

  @override
  _CommentState createState() => _CommentState();
}

class _CommentState extends State<CommentScreen> {
  final formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  List<Color> colorListLocal = [];

  String type = "";

  final TextEditingController _descriptionController = TextEditingController();

  bool isLoading = false;

  List<String> listaCategoriaSoporte = [];

  _getCategoriaSoporte() async {
    final user = Provider.of<UserProvider>(context, listen: false).user;
    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    List<CategoriaSoporteModel> auxCategoriaSoporte =
        await CategoriaSoporteService.getCategoriaSoporte(context, user.id,
            path: cliente.path);

    List<String> auxLista = [];

    if (auxCategoriaSoporte.isNotEmpty) {
      for (var element in auxCategoriaSoporte) {
        auxLista.add(element.descripcion);
      }
    }

    setState(() {
      listaCategoriaSoporte = auxLista;
    });
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  _setStateColor(value, int indexColor) {
    if (value != null && value.toString().trim().isNotEmpty) {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    } else {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorGrayLight);
      });
    }
  }

  setColor() {
    colorListLocal = List.generate(3, (index) {
      return _colorFromHex(Widgets.colorGrayLight);
    });
  }

  Future<void> _handleCommentClick() async {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      setState(() {
        isLoading = true;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();

      Map<String, dynamic> params = {
        "idViaje": widget.viaje.idViaje,
        "comentario": _descriptionController.text
      };

      HttpClass.httpData(
              context,
              Uri.parse(prefs.getString("path_cliente").toString() +
                  "aplicacion/registerComentario.php"),
              params,
              {},
              "POST")
          .then((response) {
        setState(() {
          isLoading = false;
        });

        if (response["status"] && response["code"] == 200) {
          MotionToast.success(
                  title: const Text(""),
                  dismissable: false,
                  onClose: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => widget.redirectTo),
                      (Route<dynamic> route) => false,
                    );
                  },
                  description: Text(response["data"]))
              .show(context);
        } else {
          MotionToast.warning(
                  title: const Text("Error"),
                  description: const Text("Ocurrió un error interno"))
              .show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(Strings.hintSupportTitle),
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
        ),
        backgroundColor: _colorFromHex(Widgets.colorGrayBackground),
        body: isLoading
            ? buildCircularProgress(context)
            : Center(
                child: Container(
                  padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 10),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          buildText(
                              Strings.hintCommentTitlePanel,
                              19,
                              _colorFromHex(Widgets.colorWhite),
                              0.16,
                              "popins",
                              false,
                              19,
                              TextAlign.center,
                              FontWeight.normal,
                              Colors.transparent),

                          buildDetailform(
                              Strings.labelTripDate,
                              getFormattedDateFromFormattedString(
                                  widget.viaje.fechaViaje),
                              Strings.labelTripHour,
                              widget.viaje.horaViaje,
                              "1"),
                          buildDetailform(
                              Strings.labelTripLocation,
                              widget.viaje.nombreSucursal,
                              Strings.labelTripCompany,
                              widget.viaje.nombreEmpresa,
                              "2"),
                          buildDetailform(
                              Strings.labelTripType,
                              widget.viaje.tipo,
                              Strings.labelTripOccupants,
                              widget.viaje.ocupantes.toString(),
                              "3"),
                          buildDetailform(
                              Strings.labelTripId,
                              widget.viaje.idViaje,
                              Strings.labelTripStatus,
                              setStatusTrip(widget.viaje.status.toString(),
                                  widget.viaje.confirmado.toString()),
                              "4"),
                          const SizedBox(
                            height: 13,
                          ),
                          buildDetailform(
                              Strings.labelTripInicialDate,
                              widget.viaje.fechaInicio,
                              Strings.labelTripEndDate,
                              widget.viaje.fechaFin,
                              "5"),
                          const SizedBox(
                            height: 13,
                          ),

                          const SizedBox(
                            height: 12.0,
                          ),

                          SizedBox(
                            //height: 48,
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: <Widget>[
                                TextFormField(
                                    maxLines: 7,
                                    controller: _descriptionController,
                                    autofocus: false,
                                    validator: (value) =>
                                        validateField(value.toString()),
                                    onChanged: (value) =>
                                        _setStateColor(value, 1),
                                    decoration: InputDecoration(
                                      labelStyle: TextStyle(
                                          color:
                                              _colorFromHex(Widgets.colorGray)),
                                      labelText: Strings.hintSupportDescription,
                                      filled: true,
                                      fillColor:
                                          _colorFromHex(Widgets.colorWhite),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        borderSide: BorderSide(
                                          color: colorListLocal[1],
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        borderSide: BorderSide(
                                          color: colorListLocal[1],
                                          width: 1.3,
                                        ),
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0))),
                                      errorStyle: GoogleFonts.poppins(
                                          color: Colors.red),
                                    ),
                                    style: GoogleFonts.poppins(
                                        color: colorListLocal[1])),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 17.0,
                          ),
                          isLoading
                              ? buildCircularProgress(context)
                              : longButtons(Strings.labelSupportWhatsApp,
                                  _handleCommentClick,
                                  color: _colorFromHex(Widgets.colorPrimary)),
                          const SizedBox(
                            height: 5.0,
                          ),
                          //buildDivider(),
                          /*Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //_setGoogleAuth(),
                                   // _setFacebookAuth()
                                  ],
                                )
                              ],
                            ),*/
                          //forgotLabel,
                          //registerLabel
                        ],
                      ),
                    ),
                  ),
                ),
              ));
  }

  @override
  void initState() {
    super.initState();
    setColor();
    _getCategoriaSoporte();
  }
}
