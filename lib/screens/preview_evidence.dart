import 'dart:io';

import 'package:camera/camera.dart';
import 'package:driver_please_flutter/models/ruta_viaje_model.dart';
import 'package:driver_please_flutter/models/viaje_model.dart';
import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  RutaViajeModel viaje;

  CameraScreen({Key? key, required this.viaje}) : super(key: key);
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  List<CameraDescription>? cameras;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    final firstCamera = cameras!.first;

    _controller = CameraController(
      firstCamera,
      ResolutionPreset.ultraHigh,
    );

    await _controller.initialize();

    if (mounted) {
      setState(() {});
    }
  }

  _handleCondition(File evidence) {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "¿Estás seguro de enviar esta evidencia?",
      closeIcon: const SizedBox(),
      closeFunction: () {},
      desc: "Esta opción no se puede restablecer",
      buttons: [
        DialogButton(
          child: const Text(
            "Cancelar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            _controller.resumePreview();
            Navigator.pop(context);
          },
          color: _colorFromHex(Widgets.colorSecundary),
        ),
        DialogButton(
          child: const Text(
            "Aceptar",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          onPressed: () {
            _handleSendEvidence(evidence);
          },
          color: _colorFromHex(Widgets.colorPrimary),
        ),
      ],
    ).show();
  }

  _handleSendEvidence(File evidence) async {
     final cliente = Provider.of<ClienteProvider>(context, listen: false).cliente;
    var request = http.MultipartRequest('POST',
        Uri.parse(cliente.path + "aplicacion/evidencia.php"));

    request.files
        .add(await http.MultipartFile.fromPath('evidencia', evidence.path));

    request.fields['idRuta'] = widget.viaje.idRuta;
    request.fields['idViaje'] = widget.viaje.idViaje;

    var response = await request.send();

    if (response.statusCode == 200) {
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Evidencia cargada con éxito'),
        ),
      );

      print("42342432423");
      print(evidence.path);
      print(widget.viaje.idViaje);
      print(widget.viaje.idRuta);


      setState(() {
        widget.viaje.evidencia = evidence.path;
      });
    } else {
      Navigator.pop(context);
      _controller.resumePreview();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir imagen'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  Future<File> _takePicture() async {
    if (!_controller.value.isInitialized) {
      return File("");
    }

    try {
      final XFile imageFile = await _controller.takePicture();
      File capturedImage = File(imageFile.path);
      return capturedImage;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al subir evidencia'),
        ),
      );
      return File("");
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_controller.value.isInitialized) {
    //   return buildCircularProgress(context);
    // }

    return Scaffold(
      appBar: AppBar(
        title: Text("Evidencia"),
        titleTextStyle: GoogleFonts.poppins(
            fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
        elevation: 0.1,
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        actions: [],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          CameraPreview(_controller),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Fecha: ${DateTime.now().toString()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Ubicación: Tu ubicación aquí',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: _colorFromHex(Widgets.colorPrimary),
        onPressed: () async {
          File evidence = await _takePicture();
          _controller.pausePreview();

          if (evidence.existsSync() && evidence.readAsBytesSync().isNotEmpty) {
            _handleCondition(evidence);
          }
        },
        child: Icon(Icons.camera, color: Colors.white),
      ),
    );
  }
}
