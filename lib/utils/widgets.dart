import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class Widgets {
  static const String colorPrimary = "#1c4089";
  static const String colorSecundary = "#1477b6";
  static const String colorSecundayLight = "#D4F5F5";
  static const String colorGray = "#9b9c9e";
  static const String colorGrayLight = "#9b9c9e2";

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
    prefixIcon: Icon(icon, color: Colors.white38),
    hintText: hintText,
    hintStyle: GoogleFonts.poppins(fontSize: 16, color: Colors.white38),
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
          color: Colors.white,
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
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    backgroundColor: Widgets._colorFromHex2(Widgets.colorPrimary),
    duration: Duration(seconds: duration),
    action: SnackBarAction(
      textColor: Colors.white,
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
                          color: Widgets._colorFromHex2(Widgets.colorSecundary),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(textValue1.isNotEmpty ? textValue1 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Widgets._colorFromHex2(Widgets.colorGray),
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
                          color: Widgets._colorFromHex2(Widgets.colorSecundary),
                          fontWeight: FontWeight.w500,
                        )),
                    Text(textValue2.isNotEmpty ? textValue2 : "",
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Widgets._colorFromHex2(Widgets.colorGray),
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
