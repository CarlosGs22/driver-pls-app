import 'package:driver_please_flutter/utils/http_class.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Widgets {
  static const String colorPrimary = "#000000";
  static const String colorSecundary = "#2B2B99";
  static const String colorSecundayLight2 = "#4466BA";
  static const String colorSecundayLight = "#A8359F";
  static const String colorGray = "#9b9c9e";
  static const String colorGrayLight = "#9b9c9e2";
  static const String colorWhite = "#FFFFFF";
  static const String colorGrayBackground = "#313237";

  static Color _colorFromHex2(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }
}

Color buildColor(String hexColor) {
  final hexCode = hexColor.replaceAll('#', '');
  return Color(int.parse('FF$hexCode', radix: 16));
}

buildText(
    String text,
    double size,
    Color color,
    double letterspace,
    String fontFamyli,
    bool underline,
    double height,
    TextAlign textAlign,
    FontWeight fonttWeight,
    Color backgroundColor) {
  return Text(text,
      //maxLines: 2,
      style: GoogleFonts.poppins(
          fontSize: size,
          color: color,
          fontWeight: fonttWeight,
          letterSpacing: letterspace,
          decoration:
              underline ? TextDecoration.underline : TextDecoration.none,
          backgroundColor: backgroundColor),
      textAlign: textAlign);
}

InputDecoration buildInputDecoration(
    String hintText, IconData icon, Color colorFill) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: Widgets._colorFromHex2(Widgets.colorWhite)),
    hintText: hintText,
    hintStyle: GoogleFonts.poppins(
        fontSize: 16, color: Widgets._colorFromHex2(Widgets.colorWhite)),
    filled: true,
    fillColor: colorFill,
    border: InputBorder.none,
    errorStyle: GoogleFonts.poppins(color: Colors.red),
  );
}

buildCircularProgress(BuildContext context) {
  return Center(
    child: CircularProgressIndicator(
      backgroundColor: Widgets._colorFromHex2(Widgets.colorPrimary),
      valueColor: AlwaysStoppedAnimation<Color>(
          Widgets._colorFromHex2(Widgets.colorGray)),
    ),
  );
}

MaterialButton longButtons(String title, Function fun,
    {Color color = Colors.blue, Color textColor = Colors.white}) {
  return MaterialButton(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(4.0),
    ),
    textColor: textColor,
    color: color,
    child: SizedBox(
      width: double.infinity,
      child: Text(
        title,
        textAlign: TextAlign.center,
        style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w400),
      ),
    ),
    height: 56,
    minWidth: 600,
    onPressed: () {
      fun();
    },
  );
}

Widget buildDivider() {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: <Widget>[
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 1,
              color: Widgets._colorFromHex2(Widgets.colorSecundary),
            ),
          ),
        ),
        Text('o',
            style: TextStyle(
                color: Widgets._colorFromHex2(Widgets.colorSecundary))),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Divider(
              thickness: 1,
              color: Widgets._colorFromHex2(Widgets.colorSecundary),
            ),
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    ),
  );
}

buildTextFormField(Widget widget, double widht, double height,
    Color borderColor, Color shadowColor) {
  return Container(
      width: widht,
      height: height,
      decoration: BoxDecoration(
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
                color: shadowColor, blurRadius: 10, offset: const Offset(1, 1)),
          ],
          color: Widgets._colorFromHex2(Widgets.colorWhite),
          borderRadius: const BorderRadius.all(Radius.circular(20))),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(child: widget),
        ],
      ));
}

buidlDefaultFlushBar(
    BuildContext context, String tittle, String message, int duration) {
  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Widgets._colorFromHex2(Widgets.colorPrimary),
    duration: Duration(seconds: duration),
    action: SnackBarAction(
      textColor: Widgets._colorFromHex2(Widgets.colorWhite),
      onPressed: () {},
      label: tittle,
    ),
  ));
}

buildBubblePadding(
    IconData icon, Color colorIcon, var tittle, Color colorTitle, double size) {
  return Padding(
    //padding: EdgeInsets.all,
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      children: [
        Icon(
          icon,
          color: colorIcon,
          size: size,
        ),
        Flexible(
          child: buildText(tittle ?? "NA", 16, colorTitle, 0, "poppins", false,
              0, TextAlign.start, FontWeight.normal, Colors.transparent),
        )
      ],
    ),
  );
}

Widget buildTextField(
    String labelText, String placeholder, bool isPasswordTextField) {
  return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: TextField(
        enabled: false,
        decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(bottom: 3),
            labelText:
                validateNullOrEmptyNumber(labelText) != "" ? labelText : "-",
            border: InputBorder.none,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            hintText: validateNullOrEmptyNumber(placeholder) != ""
                ? placeholder
                : "-",
            hintStyle: GoogleFonts.poppins(
              color: Colors.black,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            labelStyle: GoogleFonts.poppins(
              color: Widgets._colorFromHex2(Widgets.colorGrayLight),
              fontWeight: FontWeight.w500,
              fontSize: 16,
            )),
      ));
}

buildDetailform(String textTittle1, String textValue1, String textTittle2,
    String textValue2, String key) {
  Key k = Key(key);
  return Row(
    key: k,
    mainAxisAlignment: MainAxisAlignment.start,
    children: <Widget>[
      validateNullOrEmptyString(textValue1) != null
          ? Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 7, right: 15, bottom: 0, left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textTittle1.isNotEmpty ? textTittle1 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Widgets._colorFromHex2(Widgets.colorWhite),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(textValue1.isNotEmpty ? textValue1 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Widgets._colorFromHex2(Widgets.colorGrayLight),
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ))
          : const SizedBox(height: 0),
      validateNullOrEmptyString(textValue2) != null
          ? Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 7, right: 15, bottom: 0, left: 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textTittle2.isNotEmpty ? textTittle2 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: Widgets._colorFromHex2(Widgets.colorWhite),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(textValue2.isNotEmpty ? textValue2 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Widgets._colorFromHex2(Widgets.colorGrayLight),
                          fontWeight: FontWeight.w500,
                        ))
                  ],
                ),
              ))
          : const SizedBox(height: 0),
    ],
  );
}

staticbuildBottomSheet(BuildContext context, Widget widget) {
  return showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    isDismissible: false,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return widget;
    },
  );
}

bool validateTimeFormat(String timeString) {
  // Expresión regular para validar el formato de tiempo (hh:mm)
  RegExp regex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9]$');
  return regex.hasMatch(timeString);
}



setStatusTrip(String stat, String confirm) {
  print("DATOS");

  int status = int.parse(stat);
  int confirmado = int.parse(confirm);

  var res = "NA";
  switch (status) {
    case 1:
      if (confirmado == 1) {
        res = "ACEPTAR";
      } else {
        if (confirmado == 2) {
          res = "CONTINUAR";
        }
      }
      break;
    case 2:
      if (confirmado == 1) {
        res = "ACEPTAR";
      } else {
        if (confirmado == 2) {
          res = "CONTINUAR";
        }
      }
      break;
    case 3:
      res = "FINALIZADO";
      break;
    case 6:
      res = "CANCELADO";
      break;
  }

  return res;
}

setConfirmadoTrip(var confirmado) {
  var res = "NA";
  switch (confirmado) {
    case "1":
      res = "PENDIENTE";
      break;
    case "2":
      res = "CONFIRMADO";
      break;
    case "3":
      res = "RECHAZADO";
      break;
  }

  return res;
}

List<Widget> listWidget(Map<String, dynamic> mapData) {
  List<Widget> chips = [];

  mapData.removeWhere((key, value) => key == "id_con");

  mapData.forEach((key, value) {
    Widget wid = Text(key.replaceAll("_", " ") + " " + value,
        style: TextStyle(
          fontSize: 15,
          color: Widgets._colorFromHex2(Widgets.colorPrimary),
        ));

    chips.add(wid);

    chips.add(const SizedBox(
      height: 12,
    ));
  });

  return chips;
}

void modalWaitTime(BuildContext context, Map<String, dynamic> response) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

      return AlertDialog(
        title: Center(
          child: Text(
            'Atención',
            style: TextStyle(
              fontSize: 24.0,
              color: Widgets._colorFromHex2(Widgets.colorPrimary),
            ),
          ),
        ),
        content: Container(
            width: double.maxFinite,
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height - keyboardHeight),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    response["message"] ?? "NA",
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Widgets._colorFromHex2(Widgets.colorPrimary),
                    ),
                  ),
                  const SizedBox(height: 10),

                  //  Text(
                  //   response["tolerancia"] ?? "NA",
                  //   style: TextStyle(
                  //     fontSize: 17.0,
                  //     color:  Widgets._colorFromHex2(Widgets.colorPrimary),
                  //   ),
                  // ),
                  Column(
                    children: [
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text("Hora \nprogramada",
                      //         style: GoogleFonts.poppins(
                      //           fontSize: 21,
                      //           color:
                      //               Widgets._colorFromHex2((Widgets.colorPrimary)),
                      //           fontWeight: FontWeight.w500,
                      //         )),
                      //     Text(
                      //      response["hora_programada"] ?? "NA",
                      //       style: GoogleFonts.poppins(
                      //         fontSize: 21,
                      //         color: Widgets._colorFromHex2((Widgets.colorPrimary)),
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      // SizedBox(height: 10,),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //   crossAxisAlignment: CrossAxisAlignment.start,
                      //   children: [
                      //     Text("Hora \nactual",
                      //         style: GoogleFonts.poppins(
                      //           fontSize: 21,
                      //           color:
                      //              Widgets._colorFromHex2((Widgets.colorPrimary)),
                      //           fontWeight: FontWeight.w500,
                      //         )),
                      //     Text(
                      //        response["hora_actual"] ?? "NA",
                      //       style: GoogleFonts.poppins(
                      //         fontSize: 21,
                      //         color:    Widgets._colorFromHex2((Widgets.colorPrimary)),
                      //         fontWeight: FontWeight.w500,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      //   SizedBox(height: 10,),

                      Row(
                        children: [
                          Expanded(
                            flex: 10,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 3, right: 3),
                              child: longButtons("Enterado", () {
                                Navigator.pop(context);
                              },
                                  color: Widgets._colorFromHex2(
                                      Widgets.colorPrimary)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            )),
      );
    },
  );
}

 Future<bool> getActualAddress(
    BuildContext context, var path,var params) async {
  var response =
      await HttpClass.httpData(context, Uri.parse(path), params, {}, "POST");

  if (response["code"] == 200) {
    return true;
  } else {
    return false;
  }
}


