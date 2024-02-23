import 'dart:convert';

import 'package:driver_please_flutter/models/cliente_model.dart';
import 'package:driver_please_flutter/models/user.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/screens/dashboard_screen.dart';
import 'package:driver_please_flutter/screens/login_screen.dart';
import 'package:driver_please_flutter/screens/register_profile.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/shared_preference_cliente.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:drop_down_list/drop_down_list.dart';

class ProviderScreen extends StatefulWidget {
  const ProviderScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<ProviderScreen> {
  final formKey = GlobalKey<FormState>();
  final myController = TextEditingController();
  List<Color> colorListLocal = [];

  var proveedorController = TextEditingController();

  String idCliente = "";

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    setColor();
    proveedorController = TextEditingController();
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
    colorListLocal = List.generate(2, (index) {
      return _colorFromHex(Widgets.colorGrayLight);
    });
  }

  _handleShowProveedor() {
    List<dynamic> sexList = [
      //{"id": "1", "description": "Demo"},
      {"id": "2", "description": "Driver Please"},
    ];
    DropDownState(
      DropDown(
        searchHintText: "Buscar",
        bottomSheetTitle: const Text(
          "Proveedor",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20.0,
          ),
        ),
        submitButtonChild: const Text(
          'Hecho',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        data: [
          for (var val in sexList)
            SelectedListItem(
                name: val["description"],
                value: val["id"].toString(),
                isSelected: false)
        ],
        selectedItems: (List<dynamic> selectedList) {
          setState(() {
            idCliente = selectedList.last.value;
          });

          proveedorController.text = selectedList.last.name;
        },
        enableMultipleSelection: false,
      ),
    ).showModal(context);
  }

  void _handleLoginClick() {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      setState(() {
        isLoading = true;
      });

      _loginResponse(context, idCliente);
    }
  }

  _loginResponse(
    BuildContext context,
    var idCliente,
  ) async {
    Map<String, dynamic> params = {"id_cliente": idCliente};

    params.removeWhere((key, value) => value == null);

    HttpClass.httpData(
            context,
            Uri.parse("https://www.movilistica.com/control/getCliente.php"),
            params,
            {},
            "POST")
        .then((response) {
      _handleLoginResponse(response, context, params);
    });
  }

  _handleLoginResponse(Map<String, dynamic> response, BuildContext context,
      Map<String, dynamic> params) {
    try {
      List<dynamic> datauser = json.decode(response["data"]);
      setState(() {
        isLoading = false;
      });

      if (response["status"] && datauser.isNotEmpty) {
        _loginSuccess(context, json.decode(response["data"]), params);
      } else {
        buidlDefaultFlushBar(context, "Error", "Claves inválidas", 4);
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      buidlDefaultFlushBar(context, "Error", "Claves inválidas", 4);
    }
  }

  _loginSuccess(
      BuildContext context, List<dynamic> data, Map<String, dynamic> params) {
    Map<String, dynamic> dataInsert = {};
    dataInsert.addAll(data[0]);
    dataInsert.addAll(params);

    print("DATOS SESION");
    print(dataInsert);

    Cliente autCliente = Cliente.fromJson(dataInsert);
    Provider.of<ClienteProvider>(context, listen: false).setCliente(autCliente);
    ClientePreferences().saveCliente(autCliente);

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => LoginScreen(
                  dataMap: dataInsert,
                )));
  }

  @override
  Widget build(BuildContext context) {
    Color color1 = _colorFromHex("#fff");
    Color color2 = _colorFromHex("#fff");

    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
            body: Center(
              child: Container(
                padding: EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    top: MediaQuery.of(context).size.height * 0.1),
                child: Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                         Image.asset(
                          'assets/images/movilisticaLogoTrans.png',
                          width: 350,
                          //height: 335,
                          fit: BoxFit.fitHeight,
                        ),
                        
                        SizedBox(
                            //height: 48,
                            child: TextFormField(
                                autofocus: false,
                                readOnly: true,
                                validator: (value) =>
                                    validateField(value.toString()),
                                onTap: () {
                                  _handleShowProveedor();
                                },
                                controller: proveedorController,
                                decoration: InputDecoration(
                                  prefixIcon: Icon(Icons.home,
                                      color: colorListLocal[0]),
                                  hintText: Strings.hintLoginProvider,
                                  hintStyle: GoogleFonts.poppins(
                                      fontSize: 17,
                                      color: colorListLocal[0]),
                                  filled: true,
                                  fillColor: _colorFromHex(Widgets.colorWhite),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(4.0),
                                    borderSide: BorderSide(
                                      color: colorListLocal[0],
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.circular(4.0),
                                    borderSide: BorderSide(
                                      color: colorListLocal[0],
                                      width: 2.0,
                                    ),
                                  ),
                                  border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(4.0))),
                                  errorStyle: GoogleFonts.poppins(
                                      color: Colors.red),
                                ),
                                style: GoogleFonts.poppins(
                                    color: colorListLocal[0]))),
                        const SizedBox(
                          height: 13.0,
                        ),
                        isLoading
                            ? buildCircularProgress(context)
                            : longButtons(Strings.labelLoginProviderBtn,
                                _handleLoginClick,
                                color: _colorFromHex(Widgets.colorPrimary)),
                        const SizedBox(
                          height: 5.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )));
  }

  Future<bool> showExitPopup() async {
    return await showDialog(
          //show confirm dialogue
          //the return value will be from "Yes" or "No" options
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
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Si",
                      style:
                          TextStyle(color: _colorFromHex(Widgets.colorGray)))),
            ],
          ),
        ) ??
        false;
  }
}
