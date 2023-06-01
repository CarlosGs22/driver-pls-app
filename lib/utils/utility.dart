import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:ui' as ui;

class Utility {
  static const String googleMapAPiKey =
      "AIzaSyDp86KOchjHALKYuRNmEBVUXP0vMrOMf-o";

  static printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
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
    ui.Codec codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List(), targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!.buffer.asUint8List();
   }
}
