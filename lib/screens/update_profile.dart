import 'dart:convert';

import 'package:driver_please_flutter/main.dart';
import 'package:driver_please_flutter/models/user.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  _UpdateProfileState createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  var emailcontroller = TextEditingController();
  var namecontroller = TextEditingController();
  var lastNamecontroller = TextEditingController();
  var mobilecontroller = TextEditingController();
  var marcacontroller = TextEditingController();
  var tipocontroller = TextEditingController();
  var modelocontroller = TextEditingController();
  var colorcontroller = TextEditingController();
  var placascontroller = TextEditingController();

  List<Color> colorListLocal = [];

  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();

    final user = Provider.of<UserProvider>(context, listen: false).user;

    emailcontroller = TextEditingController(text: user.email);
    namecontroller = TextEditingController(text: user.name);
    lastNamecontroller = TextEditingController(text: user.lastName);
    mobilecontroller = TextEditingController(text: user.mobile);
    marcacontroller = TextEditingController(text: user.marca);
    tipocontroller = TextEditingController(text: user.tipo);
    modelocontroller = TextEditingController(text: user.modelo);
    colorcontroller = TextEditingController(text: user.color);
    placascontroller = TextEditingController(text: user.placas);

    setColor();
  }

  _setStateColor(value, int indexColor) {
    if (value != null && value.toString().trim().isNotEmpty) {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    } else {
      setState(() {
        colorListLocal[indexColor] = _colorFromHex(Widgets.colorPrimary);
      });
    }
  }

  setColor() {
    colorListLocal = List.generate(10, (index) {
      return _colorFromHex(Widgets.colorPrimary);
    });
  }

  _handleLoginClick() {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();
      _handleUpdateUser();
    }
  }

  _handleUpdateUser() {
    final user = Provider.of<UserProvider>(context, listen: false).user;

    var formParams = {
      "idCon": user.id,
      "email": emailcontroller.text,
      "nombre": namecontroller.text,
      "apellido": lastNamecontroller.text,
      "telefono": mobilecontroller.text
    };

    final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;


    HttpClass.httpData(
            context,
            Uri.parse(
               cliente.path  + "aplicacion/updatePerfil.php"),
            formParams,
            {},
            "POST")
        .then((response) {
      if (response["status"] && response["code"] == 200) {
        List<dynamic> datauser = json.decode(response["data"]);

        Map<String, dynamic> dataInsert = {};
        dataInsert.addAll(datauser[0]);
        dataInsert.addAll({"password": user.password});

        print("DATOS SESION");
        print(dataInsert);

        User authUser = User.fromJson(dataInsert);
        Provider.of<UserProvider>(context, listen: false).setUser(authUser);
        UserPreferences().saveUser(authUser);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Main()),
          (Route<dynamic> route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ocurrió un error al actualizar datos'),
          ),
        );
      }
    });
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Widget build(BuildContext context) {
    final emailField = TextFormField(
       enabled: false,
        maxLength: 100,
        controller: emailcontroller,
        autofocus: false,
        validator: (value) {
          if (validateField(value.toString()) == null) {
            if (!EmailValidator.validate(value.toString())) {
              return "Correo inválido";
            }
          }
        },
        keyboardType: TextInputType.emailAddress,
        onChanged: (value) => _setStateColor(value, 3),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.email, color: colorListLocal[4]),
          hintText: "Ingresa tu correo",
          counterText: "",
          hintStyle:
              GoogleFonts.poppins(fontSize: 17, color: colorListLocal[4]),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: colorListLocal[4],
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: colorListLocal[4],
              width: 2.0,
            ),
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          errorStyle: GoogleFonts.poppins(color: Colors.red),
        ),
        style: GoogleFonts.poppins(color: colorListLocal[4]));

    final name = TextFormField(
        enabled: false,
        maxLength: 100,
        keyboardType: TextInputType.name,
        controller: namecontroller,
        autofocus: false,
        validator: (value) => validateField(value.toString()),
        onChanged: (value) => _setStateColor(value, 0),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: colorListLocal[0]),
          counterText: "",
          hintText: "Ingresa tu nombre",
          hintStyle:
              GoogleFonts.poppins(fontSize: 17, color: colorListLocal[0]),
          filled: true,
          fillColor: Colors.white,
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
              width: 2.0,
            ),
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          errorStyle: GoogleFonts.poppins(color: Colors.red),
        ),
        style: GoogleFonts.poppins(color: colorListLocal[0]));

    final lastName = TextFormField(
        enabled: false,
        maxLength: 100,
        keyboardType: TextInputType.name,
        controller: lastNamecontroller,
        autofocus: false,
        validator: (value) => validateField(value.toString()),
        onChanged: (value) => _setStateColor(value, 1),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.person, color: colorListLocal[0]),
          hintText: "Ingresa tus apellidos",
          counterText: "",
          hintStyle:
              GoogleFonts.poppins(fontSize: 17, color: colorListLocal[1]),
          filled: true,
          fillColor: Colors.white,
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
              width: 2.0,
            ),
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          errorStyle: GoogleFonts.poppins(color: Colors.red),
        ),
        style: GoogleFonts.poppins(color: colorListLocal[1]));

    final mobile = TextFormField(
        enabled: false,
        keyboardType: TextInputType.phone,
        controller: mobilecontroller,
        autofocus: false,
        validator: (value) {
          if (validateField(value.toString()) == null) {
            if (value!.trim().length != 10) {
              return "Teléfono debe de tener 10 digitos";
            }
          }
        },
        maxLength: 10,
        onChanged: (value) => _setStateColor(value, 2),
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.phone, color: colorListLocal[0]),
          hintText: "Ingresa tu número celular",
          counterText: "",
          hintStyle:
              GoogleFonts.poppins(fontSize: 17, color: colorListLocal[2]),
          filled: true,
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: colorListLocal[2],
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4.0),
            borderSide: BorderSide(
              color: colorListLocal[2],
              width: 2.0,
            ),
          ),
          border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(4.0))),
          errorStyle: GoogleFonts.poppins(color: Colors.red),
        ),
        style: GoogleFonts.poppins(color: colorListLocal[2]));


    final loginButon = longButtons(
        Strings.labelUpdateProfileBtn, _handleLoginClick,
        color: _colorFromHex(Widgets.colorPrimary));

    return Scaffold(
      appBar: AppBar(
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
        title: const Text(Strings.labelUpdateProfile),
        elevation: 0.1,
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        actions: [],
      ),
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: SingleChildScrollView(
                  child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 115,
                      width: 115,
                      child: Stack(
                        fit: StackFit.expand,
                        overflow: Overflow.visible,
                        children: [
                          const CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/images/logoApp.png"),
                          ),
                          Positioned(
                            right: -16,
                            bottom: 0,
                            child: SizedBox(
                              height: 46,
                              width: 46,
                              child: FlatButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                  side: BorderSide(color: Colors.white),
                                ),
                                color: Color(0xFFF5F6F9),
                                onPressed: () {},
                                child: Image.asset("assets/images/logoApp.png"),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    SizedBox(height: 45.0),
                    emailField,
                    SizedBox(height: 25.0),
                    name,
                    SizedBox(height: 25.0),
                    lastName,
                    SizedBox(height: 25.0),
                    mobile,
                    /*SizedBox(height: 25.0),
                    loginButon,*/
                    SizedBox(
                      height: 15.0,
                    ),
                  ],
                ),
              ))),
        ),
      ),
    );
  }
}
