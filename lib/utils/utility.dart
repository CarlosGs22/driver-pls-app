import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart'; //for date format
import 'package:intl/date_symbol_data_local.dart';

import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Utility {
  static const String googleMapAPiKey =
      "AIzaSyDp86KOchjHALKYuRNmEBVUXP0vMrOMf-o";

  static printWrapped(String text) {
    final pattern = RegExp('.{1,800}');
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  static Future<bool> requestLocationPermission() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied || status.isRestricted) {
      return false;
    } else {
      return false;
    }
  }

  static double calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static getCurrentDate() {
    return DateFormat('yyyy-MM-dd kk:mm').format(DateTime.now());
  }

  static setStatusTrip(var status) {
    print(status);
    var res = "";
    switch (status) {
      case "1":
        res = "Por realizar";
        break;
      case "2":
        res = "Iniciado";
        break;
      case "3":
        res = "Realizado";
        break;
      case "6":
        res = "Cancelado";
        break;
      default:
        res = "NA";
    }

    return res;
  }
}

getFormattedDateFromFormattedString(var value) {
  try {
    return DateFormat.yMMMMEEEEd().format(DateTime.parse(value));
  } catch (e) {
    return value;
  }
}

setFormatDatetime(String originalDateTime) {
  try {
    DateTime dateTime = DateTime.parse(originalDateTime);
    String formattedDate = DateFormat('dd MMMM y HH:mm:ss').format(dateTime);

    return formattedDate;
  } catch (e) {
    return originalDateTime;
  }
}

setFormatDate(String originalDate) {
  try {
    DateTime date = DateTime.parse(originalDate);
    String formattedDate = DateFormat('dd MMMM y', 'es').format(date);
    return formattedDate;
  } catch (e) {
    return originalDate;
  }
}

String formatTimeSeconds(int seconds) {
  int hours = seconds ~/ 3600;
  int minutes = (seconds ~/ 60) % 60;
  int remainingSeconds = seconds % 60;

  String hoursStr = (hours < 10) ? '0$hours' : '$hours';
  String minutesStr = (minutes < 10) ? '0$minutes' : '$minutes';
  String secondsStr =
      (remainingSeconds < 10) ? '0$remainingSeconds' : '$remainingSeconds';

  return '$hoursStr:$minutesStr:$secondsStr';
}

String formatTimeMinutes(double totalMinutes) {
  print("34344" + totalMinutes.toString());

  int horas = totalMinutes ~/ 60;
  int minutos = (totalMinutes % 60).toInt();
  int segundos = ((totalMinutes * 60) % 60).toInt();

  String horasStr = (horas < 10) ? '0$horas' : '$horas';
  String minutosStr = (minutos < 10) ? '0$minutos' : '$minutos';
  String segundosStr = (segundos < 10) ? '0$segundos' : '$segundos';

  return '$horasStr:$minutosStr:$segundosStr';
}

_setBelongTo(var option){

}
