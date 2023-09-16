import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:driver_please_flutter/models/carro_model.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/screens/drawer/main_drawer.dart';
import 'package:driver_please_flutter/services/carro_service.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/validator.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyCarScreen extends StatefulWidget {
  MyCarScreen({Key? key}) : super(key: key);

  @override
  State<MyCarScreen> createState() => _MyCarScreenState();
}

class _MyCarScreenState extends State<MyCarScreen> {
  List<CarroModel> carList = [];

  Color _colorFromHex(String hexColor) {
    final hexCode = hexColor.replaceAll('#', '');
    return Color(int.parse('FF$hexCode', radix: 16));
  }

  bool openDrawer = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    final user = Provider.of<UserProvider>(context, listen: false).user;
    CarroService.getCarroConductor(context, user.id).then((value) {
      setState(() {
        carList = value;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    // return WillPopScope(
    //     onWillPop: showExitPopup,
    //     child: 
    return Scaffold(
          //resizeToAvoidBottomInset: false,
          onDrawerChanged: (isOpened) {
            if (isOpened) {
              setState(() {
                openDrawer = true;
              });
            }
          },
          appBar: AppBar(
            titleTextStyle: GoogleFonts.poppins(
                fontSize: 19, color: Colors.white, fontWeight: FontWeight.w500),
            title: Text(Strings.labelMyCarLabel),
            elevation: 0.1,
            backgroundColor: _colorFromHex(Widgets.colorPrimary),
          ),
          drawer:  MainDrawer(7),
          body: isLoading
              ? buildCircularProgress(context)
              : ListView.builder(
                  itemCount: carList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = carList[index];
                    return InkWell(
                        onTap: () {},
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          child: Column(children: <Widget>[
                            ListTile(
                              title: Text(
                                  validateNullOrEmptyString(item.marca) ??
                                      "NA"),
                              subtitle: Text(
                                validateNullOrEmptyString(item.modelo) ?? "NA",
                                style: TextStyle(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Icon(Icons.directions_car,size: 70,),
                            // CachedNetworkImage(
                            //   imageUrl:
                            //       "https://acnews.blob.core.windows.net/imgnews/extralarge/NAZ_339be1c306fb40fbb9de02ba7722f528.jpg",
                            //   placeholder: (context, url) =>
                            //       CircularProgressIndicator(),
                            //   errorWidget: (context, url, error) =>
                            //       Icon(Icons.error),
                            // ),
                            Row(
                              //Divider line
                              children: <Widget>[
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20.0,
                                        right: 20.0,
                                        top: 10.0,
                                        bottom: 10.0),
                                    child: Divider(color: Colors.green),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: 10.0, left: 20.0, right: 20.0),
                              child: Row(
                                children: <Widget>[
                                  Expanded(
                                    flex: 7,
                                    child: Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Icon(Icons.car_repair),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            validateNullOrEmptyString(
                                                    item.color) ??
                                                "NA",
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Icon(
                                            Icons.car_repair,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            validateNullOrEmptyString(
                                                    item.tipo) ??
                                                "NA",
                                            textAlign: TextAlign.left,
                                          ),
                                          SizedBox(
                                            width: 5.0,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Container(
                                          // padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            validateNullOrEmptyString(
                                                    item.placas) ??
                                                "NA",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                                fontSize: 22.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Container(
                                          //color: Colors.red,
                                          // padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            validateNullOrEmptyString(
                                                    item.propiedad) ??
                                                "NA",
                                            textAlign: TextAlign.right,
                                            style: TextStyle(
                                              color: Colors.red,
                                              fontSize: 14.0,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ]),
                        ));
                  },
                ),
        );
  }

  Future<bool> showExitPopup() async {
    if (openDrawer) {
      setState(() {
        openDrawer = false;
      });
      Navigator.of(context).pop(false);
      return false;
    } else {
      return await showDialog(
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
                    onPressed: () {
                      if (Platform.isIOS) {
                        exit(0);
                      } else {
                        SystemNavigator.pop();
                      }
                    },
                    child: Text("Si",
                        style: TextStyle(
                            color: _colorFromHex(Widgets.colorPrimary)))),
              ],
            ),
          ) ??
          false;
    }
  }
}
