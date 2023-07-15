import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_file.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

import 'package:intl/intl.dart';  //for date format
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
    return DateFormat.yMMMEd().format(DateTime.parse(value));
  } catch (e) {
    return value;
  }
}
