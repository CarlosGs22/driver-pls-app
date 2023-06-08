import 'dart:async';
import 'dart:io';

import 'package:driver_please_flutter/utils/utility.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';

class HttpClass {
  static Future httpData(BuildContext context, Uri url, var params,
      Map<String, String> headers, var method) async {
    try {
      if (method == "GET") {
        
        return await get(url, headers: headers)
            .timeout(const Duration(seconds: 10))
            .then((value) {
              
          Utility.printWrapped("**************API-URL -> " + url.toString());

          Utility.printWrapped("************PARAMS -> " + params.toString());

          Utility.printWrapped( "************RESPONSE -> " + value.statusCode.toString());

          Utility.printWrapped( "************RESPONSE -> " + value.body.toString());

          return {
            'status': true,
            'message': "OK",
            'data': value.body,
            'extra': null,
            'code': value.statusCode
          };
        });
      } else {
        return await post(url, body: params, headers: headers)
            .timeout(const Duration(seconds: 10))
            .then((value) {
          Utility.printWrapped("**************API-URL -> " + url.toString());

          Utility.printWrapped("************PARAMS -> " + params.toString());

          Utility.printWrapped("************RESPONSE -> " + value.body);

          return {
            'status': true,
            'message': "OK",
            'data': value.body,
            'extra': null,
            'code': value.statusCode
          };
        });
      }
    } on TimeoutException catch (e) {
      print(e);
      return {
        'status': false,
        'message': 'Tiempo excedido',
        'data': null,
        'extra': null,
        'code': 502
      };
    } on SocketException catch (e) {
      print(e);
      return {
        'status': false,
        'message': 'No hay conexión a internet',
        'data': null,
        'extra': null,
        'code': 503
      };
    } on Error catch (e) {
      print(e);
      return {
        'status': false,
        'message': 'Ocurrió un error',
        'data': null,
        'extra': null,
        'code': 504
      };
    }
  }
}
