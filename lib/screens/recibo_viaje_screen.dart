import 'package:driver_please_flutter/providers/cliente_provider.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/utility.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ReciboViajeScreen extends StatefulWidget {
  Map<String, dynamic> viajeResumen = {};

  ReciboViajeScreen({Key? key, required this.viajeResumen});

  @override
  _ReciboViajeScreenState createState() => _ReciboViajeScreenState();
}

class _ReciboViajeScreenState extends State<ReciboViajeScreen>
    with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    int segundos = (validateNullOrEmptyNumber(
            int.tryParse(widget.viajeResumen["segundos_espera"]) ?? 0) ??
        0);
    String resultadoSegundosEspera = convertirSegundosAHora(segundos);

    double total_viaje = (double.parse(
        (validateNullOrEmptyNumber(widget.viajeResumen["subtotal"]) ?? 0)));

        //   double costEspera = (double.parse(
        // (validateNullOrEmptyNumber(widget.viajeResumen["costo_espera"]) ?? 0).toString()));

        // total_viaje = total_viaje + costEspera;

    

    double totalGanancia = (total_viaje -
        ((validateNullOrEmptyString(double.parse(
                widget.viajeResumen["costo_comision"].toString())) ??
            0)));

    final cliente =
        Provider.of<ClienteProvider>(context, listen: false).cliente;

    String nombreCliente = cliente.nombre;

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: const Text(Strings.labelReciboviaje),
          elevation: 0.1,
          backgroundColor: _colorFromHex(Widgets.colorPrimary),
        ),
        body: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(15, 15, 15, 15),
              child: SingleChildScrollView(
                  child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'Recorrido del viaje',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                const Text(
                                  'Distancia',
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                  ),
                                ),
                                Text(
                                  (validateNullOrEmptyString(widget
                                              .viajeResumen["distancia"]) ??
                                          "00") +
                                      " km",
                                  style: TextStyle(
                                    fontFamily: 'Open Sans',
                                    fontSize: 15,
                                  ),
                                ),
                              ])),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Tiempo',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              (validateNullOrEmptyString(
                                          widget.viajeResumen["formatoHora"]) ??
                                      "") +
                                  " Hrs",
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Tiempo de espera',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              ((validateNullOrEmptyString(convertirSegundosAHora(int.tryParse(widget.viajeResumen["segundos_espera"]) ?? 0))
                                      ) ?? "00:00:00"),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFC50F0F),
                      ),
                      const Text(
                        'Costo del viaje',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Total del viaje',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "\$ " + (total_viaje.toStringAsFixed(2)),
                              style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Banderazo',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " +
                                  (validateNullOrEmptyString(
                                          widget.viajeResumen["bandera"]) ??
                                      "0"),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Costo de distancia',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " +
                                  (validateNullOrEmptyString(widget
                                          .viajeResumen["costo_distancia"]) ??
                                      "0"),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Costo de tiempo',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " +
                                  (validateNullOrEmptyString(widget
                                          .viajeResumen["costo_tiempo"]) ??
                                      ""),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Costo de tiempo \nde espera',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " + ((validateNullOrEmptyString(double.parse(widget
                                          .viajeResumen["costo_espera"]
                                          .toString())
                                      .toString()) ??
                                  "0")),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFC50F0F),
                      ),
                      Text(
                        "Servicio de Logística Móvil",
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Tasa de servicio de LM',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "% " +
                                  (validateNullOrEmptyString(double.parse(widget
                                                  .viajeResumen[
                                                      "porcentaje_comision"]
                                                  .toString()) *
                                              100) ??
                                          0)
                                      .toString()
                                      .replaceAll(".", "")
                                      .replaceAll("0", ""),
                              style: const TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Costo de tasa de servicio LM',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " +
                                  (validateNullOrEmptyString(widget
                                          .viajeResumen["costo_comision"]) ??
                                      "NA"),
                              style: const TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFC50F0F),
                      ),
                      const Text(
                        'Ganancias del conductor',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'Total de ganancias del conductor',
                              style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "\$ " + (totalGanancia.toStringAsFixed(2)),
                              style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Total del viaje',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ " +
                                  (validateNullOrEmptyString(
                                              total_viaje.toStringAsFixed(2)) ??
                                          "NA")
                                      .toString(),
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              'Costo de tasa de servicio LM',
                              style: TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "\$ -" +
                                  (validateNullOrEmptyString(widget
                                          .viajeResumen["costo_comision"]) ??
                                      "NA"),
                              style: const TextStyle(
                                fontFamily: 'Open Sans',
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),

                      /*Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: const [
                              Text(
                                'Costo de servicio Driver Please',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'Hello World',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),*/
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFC50F0F),
                      ),
                      const Text(
                        'Facturación',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: const [
                          Flexible(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                              child: Text(
                                'La cantidad correspondiente a \"Total de ganancias del conductor\" se sumará a todos los viajes realizados en el periodo semanal\ncorrespondiente y con base en el resultado total se deberá de emitir la factura correspondiente.\n',
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Divider(
                        thickness: 1,
                        indent: 20,
                        endIndent: 20,
                        color: Color(0xFFC50F0F),
                      ),
                      const Text(
                        'Registro',
                        style: TextStyle(
                          fontFamily: 'Open Sans',
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Flexible(
                            child: Padding(
                              padding:
                                  EdgeInsetsDirectional.fromSTEB(0, 7, 0, 7),
                              child: Text(
                                (validateNullOrEmptyString(widget
                                        .viajeResumen["fecha_registro"]) ??
                                    "NA"),
                                style: TextStyle(
                                  fontFamily: 'Open Sans',
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              )),
            )));
  }
}
