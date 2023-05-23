import 'package:driver_pls_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_pls_flutter/screens/login_screen.dart';
import 'package:driver_pls_flutter/utils/strings.dart';
import 'package:driver_pls_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}

class _MainState extends State<Main> {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<String> getAgent() async {
    return "login";
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => TaxiTripProvider())],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: Strings.labelAppNameTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<String>(
          future: getAgent(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return buildCircularProgress(context);
              default:
                if (snapshot.hasError) {
                  return const LoginScreen();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return const LoginScreen();
                }
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/login-screen': (context) => const LoginScreen(),
        },
      ),
    );
  }
}

void main() {
  runApp(const Main());
}
