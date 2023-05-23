import 'dart:convert';

import 'package:driver_pls_flutter/screens/home_screen.dart';
import 'package:driver_pls_flutter/utils/http_class.dart';
import 'package:driver_pls_flutter/utils/strings.dart';
import 'package:driver_pls_flutter/utils/validator.dart';
import 'package:driver_pls_flutter/utils/widgets.dart';
// ignore: unnecessary_import
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();
  bool _passwordVisible = true;
  final myController = TextEditingController();
  List<Color> colorListLocal = [];

  String email = "";
  String password = "";

  bool isLoading = false;

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

  void _handleLoginClick() {
    final form = formKey.currentState;

    if (form!.validate()) {
      form.save();

      email = email.toLowerCase();
      email = email.replaceAll(" ", "");
      email = email.trim();

      _loginResponse(
        context,
        email,
        password,
      );
    }
  }

  _loginResponse(
    BuildContext context,
    var email,
    var password,
  ) async {
    Map<String, dynamic> params = {"username": email, "password": password};

    params.removeWhere((key, value) => value == null);

    HttpClass.httpData(
            context,
            Uri.parse("https://www.driverplease.net/aplicacion/login.php"),
            params,
            {},
            "POST")
        .then((response) {
      _handleLoginResponse(response, context);
    });
  }

  _handleLoginResponse(Map<String, dynamic> response, BuildContext context) {
    List<dynamic> datauser = json.decode(response["data"]);

    if (response["status"] && datauser.isNotEmpty) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
        (Route<dynamic> route) => false,
      );
    } else {
      buidlDefaultFlushBar(context, "Error", "Claves inválidas", 4);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color color1 = _colorFromHex("#fff");
    Color color2 = _colorFromHex("#fff");

    final forgotLabel = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: buildText(
              Strings.labelLoginLostPassword,
              16,
              _colorFromHex(Widgets.colorSecundary),
              0.16,
              "popins",
              true,
              19,
              TextAlign.center,
              FontWeight.normal,
              Colors.transparent),
          onPressed: () {},
        ),
      ],
    );

    final registerLabel = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        TextButton(
          child: buildText(
              Strings.labelLoginCreateAccount,
              16,
              _colorFromHex(Widgets.colorSecundary),
              0.16,
              "popins",
              true,
              19,
              TextAlign.center,
              FontWeight.normal,
              Colors.transparent),
          onPressed: () {},
        ),
      ],
    );

    return WillPopScope(
        onWillPop: showExitPopup,
        child: Scaffold(
            body: Container(
                decoration: BoxDecoration(
                    gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [color1, color2],
                )),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.only(
                        left: 18.0,
                        right: 18.0,
                        top: MediaQuery.of(context).size.height * 0.1),
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/logoApp.png',
                              width: 120,
                              height: 110,
                              fit: BoxFit.fitHeight,
                            ),
                            buildText(
                                Strings.labelAppNameTitle,
                                44,
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
                                //height: 48,
                                child: TextFormField(
                                    initialValue: "joseph",
                                    autofocus: false,
                                    validator: (value) =>
                                        validateField(value.toString()),
                                    onChanged: (value) =>
                                        _setStateColor(value, 0),
                                    onSaved: (value) =>
                                        email = value.toString(),
                                    decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.email,
                                          color: colorListLocal[0]),
                                      hintText: Strings.hintLoginEmail,
                                      hintStyle: GoogleFonts.poppins(
                                          fontSize: 17,
                                          color: colorListLocal[0]),
                                      filled: true,
                                      fillColor: Colors.white,
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
                            SizedBox(
                              //height: 48,
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: <Widget>[
                                  TextFormField(
                                      initialValue: "admin",
                                      autofocus: false,
                                      obscureText: !_passwordVisible,
                                      validator: (value) =>
                                          validateField(value.toString()),
                                      onChanged: (value) =>
                                          _setStateColor(value, 1),
                                      onSaved: (value) =>
                                          password = value.toString(),
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                          child: Icon(_passwordVisible
                                              ? Icons.remove_red_eye
                                              : Icons.remove_red_eye_outlined),
                                        ),
                                        prefixIcon: Icon(Icons.lock,
                                            color: colorListLocal[1]),
                                        hintText: Strings.hintLoginPassword,
                                        hintStyle: GoogleFonts.poppins(
                                            fontSize: 17,
                                            color: colorListLocal[1]),
                                        filled: true,
                                        fillColor: Colors.white,
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
                                : longButtons(
                                    Strings.labelLoginbtn, _handleLoginClick,
                                    color: _colorFromHex(Widgets.colorPrimary)),
                            const SizedBox(
                              height: 5.0,
                            ),
                            buildDivider(),
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
                            forgotLabel,
                            registerLabel
                          ],
                        ),
                      ),
                    ),
                  ),
                ))));
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
        false; //if showDialouge had returned null, then return false
  }

  @override
  void initState() {
    super.initState();
    setColor();
  }
}
