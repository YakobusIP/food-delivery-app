import 'package:flutter/material.dart';
import 'package:food_delivery/pages/login.dart';
import 'package:food_delivery/pages/register.dart';
import 'package:food_delivery/pages/restaurant_list.dart';
import 'package:food_delivery/pages/welcome.dart';

void main() {
  runApp(const MyApp());
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Poppins"),
      initialRoute: "/",
      routes: {
        "/": (context) => WelcomePage(),
        "/register": (context) => const RegisterPage(),
        "/login": (context) => const LoginPage(),
        "/restaurant-list": (context) => const RestaurantListPage(),
      },
    );
  }
}
