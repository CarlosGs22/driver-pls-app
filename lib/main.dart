import 'package:driver_please_flutter/models/user.dart';
import 'package:driver_please_flutter/providers/agent_provider.dart';
import 'package:driver_please_flutter/providers/taxi_trip_provider.dart';
import 'package:driver_please_flutter/screens/taximeter_screen.dart';
import 'package:driver_please_flutter/screens/login_screen.dart';
import 'package:driver_please_flutter/screens/trip_list_screen.dart';
import 'package:driver_please_flutter/utils/shared_preference.dart';
import 'package:driver_please_flutter/utils/strings.dart';
import 'package:driver_please_flutter/utils/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Main extends StatefulWidget {
  const Main({Key? key}) : super(key: key);

  @override
  State<Main> createState() => _MainState();
}


void main() {
  runApp(const Main());
}

class _MainState extends State<Main> {
  Future<User> getUserData() => UserPreferences().getUser();

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaxiTripProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider())
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: Strings.labelAppNameTitle,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: FutureBuilder<User>(
          future: getUserData(),
          builder: (context, snapshot) {
            String userId = snapshot.data?.id ?? "";

            switch (snapshot.connectionState) {
              case ConnectionState.none:
              case ConnectionState.waiting:
                return buildCircularProgress(context);
              default:
                if (snapshot.hasError) {
                  return const LoginScreen();
                } else if (userId == "null" || userId == "") {
                  return const LoginScreen();
                } else if (snapshot.connectionState == ConnectionState.done) {
                  return const TripListScreen();
                }
            }
            return const LoginScreen();
          },
        ),
        routes: {
          '/login-screen': (context) => const LoginScreen(),
          '/viajes-listado-screen': (context) => const TripListScreen(),
          '/home-screen': (context) => const TaximeterScreen(),
        },
      ),
    );
  }
}

