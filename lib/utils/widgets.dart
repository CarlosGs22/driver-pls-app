import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
    content: Text(message),
    backgroundColor:Widgets._colorFromHex2(Widgets.colorPrimary),
    
    duration:  Duration(seconds: duration),
    action: SnackBarAction(
      textColor: Colors.white,
      onPressed: () {},
      label: tittle,
    ),
  ));
}
