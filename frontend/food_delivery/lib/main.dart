import 'package:flutter/material.dart';
import 'package:food_delivery/pages/login.dart';
import 'package:food_delivery/pages/register.dart';
import 'package:food_delivery/pages/restaurant_list.dart';
import 'package:food_delivery/pages/welcome.dart';
import 'package:food_delivery/services/storage_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final GlobalKey<ScaffoldMessengerState> snackbarKey =
    GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SecureStorageService storageService = SecureStorageService();

  String? accessToken = await storageService.get("accessToken");

  String initialRoute = accessToken == null ? "" : "restaurant-list";

  runApp(MyApp(initialRoute: initialRoute));
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      scaffoldMessengerKey: snackbarKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Poppins"),
      initialRoute: initialRoute,
      routes: {
        "": (context) => WelcomePage(),
        "register": (context) => const RegisterPage(),
        "login": (context) => const LoginPage(),
        "restaurant-list": (context) => const RestaurantListPage(),
      },
    );
  }
}
