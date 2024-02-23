import 'dart:io';

import 'package:driver_please_flutter/models/categoria_soporte_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/services/categoria_soporte_service.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:motion_toast/motion_toast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  _SupportState createState() => _SupportState();
}

class _SupportState extends State<SupportScreen> {
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

  _setWhatsAppMessage(
      String number, String message, BuildContext context) async {
    try {
      var whatsapp = "+52" + number;
      var whatsappURl_android = "whatsapp://send?phone=" +
          whatsapp +
          "&text=" +
          Uri.encodeComponent(message);

      var whatappURL_ios =
          "https://wa.me/$whatsapp?text=${Uri.encodeComponent(message)}";

      if (Platform.isIOS) {
        if (await canLaunch(whatappURL_ios)) {
          _descriptionController.text = "";
          await launch(whatappURL_ios, forceSafariVC: false);
        } else {
          MotionToast.error(
                  title: const Text("Error"),
                  description: const Text("WhatsApp no instalado"))
              .show(context);
        }
      } else {
        if (await canLaunch(whatsappURl_android)) {
          _descriptionController.text = "";

          await launch(whatsappURl_android);
        } else {
          MotionToast.error(
                  title: const Text("Error"),
                  description: const Text("WhatsApp no instalado"))
              .show(context);
        }
      }
    } catch (e) {
      print("OCURRI�� UN ERROR PERRUCHO");
      print(e.toString());
      MotionToast.error(
              title: const Text("Error"),
              description: const Text("Ocurrió un error interno"))
          .show(context);
    }
  }

  void _handleSupportClick() {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      final cliente =
          Provider.of<ClienteProvider>(context, listen: false).cliente;

      var msj = "Hola tengo una incidencia: \n \n";

      msj += "***** $type *****";

      msj += "\n \n " + _descriptionController.text;

      _setWhatsAppMessage((cliente.whatsapp), msj, context);
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
        body: Center(
          child: Container(
            padding: EdgeInsets.only(left: 18.0, right: 18.0, top: 10),
            child: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.support_agent_rounded,
                      size: 140,
                      color: _colorFromHex(Widgets.colorPrimary),
                    ),
                    buildText(
                        Strings.hintSupportTitlePanel,
                        19,
                        _colorFromHex(Widgets.colorPrimary),
                        0.16,
                        "popins",
                        false,
                        19,
                        TextAlign.center,
                        FontWeight.normal,
                        Colors.transparent),

                    const SizedBox(
                      height: 12.0,
                    ),
                    SizedBox(
                      child: DropdownSearch<String>(
                        showSearchBox: true,
                        validator: (value) => validateField(value.toString()),
                        dropdownSearchDecoration: InputDecoration(
                          labelText: Strings.hintSupportType,
                          labelStyle: GoogleFonts.poppins(
                              fontSize: 17,
                              color: _colorFromHex(Widgets.colorGrayLight)),
                          helperStyle: GoogleFonts.poppins(
                              fontSize: 17,
                              color: _colorFromHex(Widgets.colorGrayLight)),
                          filled: true,
                          fillColor: _colorFromHex(Widgets.colorWhite),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: colorListLocal[0],
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(4.0),
                            borderSide: BorderSide(
                              color: colorListLocal[0],
                              width: 1.3,
                            ),
                          ),
                          border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0))),
                          errorStyle: GoogleFonts.poppins(color: Colors.red),
                        ),
                        items: listaCategoriaSoporte,
                        onChanged: (value) => _setStateColor(value, 0),
                        onSaved: (value) => type = value.toString(),
                        selectedItem: "",
                      ),
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
                              onChanged: (value) => _setStateColor(value, 1),
                              decoration: InputDecoration(
                                labelText: Strings.hintSupportDescription,
                                filled: true,
                                fillColor: _colorFromHex(Widgets.colorWhite),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: colorListLocal[1],
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(4.0),
                                  borderSide: BorderSide(
                                    color: colorListLocal[1],
                                    width: 1.3,
                                  ),
                                ),
                                border: const OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(10.0))),
                                errorStyle:
                                    GoogleFonts.poppins(color: Colors.red),
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
                        : longButtons(
                            Strings.labelSupportWhatsApp, _handleSupportClick,
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
