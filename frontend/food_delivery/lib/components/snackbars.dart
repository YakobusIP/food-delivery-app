import 'package:flutter/material.dart';
import 'package:food_delivery/main.dart';

SnackBar showValidSnackbar(String text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: const Color.fromARGB(255, 4, 202, 138),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: "Dismiss",
      onPressed: () {
        snackbarKey.currentState?.hideCurrentSnackBar();
      },
      textColor: Colors.white,
    ),
  );
}

SnackBar showInvalidSnackbar(String text) {
  return SnackBar(
    content: Text(text),
    backgroundColor: const Color.fromARGB(255, 255, 130, 2),
    behavior: SnackBarBehavior.floating,
    duration: const Duration(seconds: 5),
    action: SnackBarAction(
      label: "Dismiss",
      onPressed: () {
        snackbarKey.currentState?.hideCurrentSnackBar();
      },
      textColor: Colors.white,
    ),
  );
}
