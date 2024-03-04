import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/network/dio_client.dart';
import 'package:food_delivery/services/storage_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final SecureStorageService _storageService = SecureStorageService();

  final TextEditingController _identifierController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var dioClient = DioClient();

      try {
        var response = await dioClient.dio.post(
          "/auth/login",
          data: {
            "identifier": _identifierController.text,
            "password": _passwordController.text,
          },
        );

        if (response.statusCode == 200) {
          await _storageService.set(
              "username", response.data["data"]["user"]["username"]);
          await _storageService.set(
              "role", response.data["data"]["user"]["role"]);
          await _storageService.set(
              "accessToken", response.data["data"]["tokens"]["access"]);
          await _storageService.set(
              "refreshToken", response.data["data"]["tokens"]["refresh"]);

          if (!mounted) return;
          snackbarKey.currentState?.showSnackBar(
            SnackBar(
              content: const Text("Login successful"),
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
            ),
          );

          Navigator.of(context).pushNamedAndRemoveUntil(
            "/restaurant-list",
            (_) => false,
          );
        }
      } on DioException catch (e) {
        if (e.response != null && e.response!.statusCode == 400) {
          var errors = e.response!.data["errors"];

          if (!mounted) return;
          snackbarKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(errors["non_field_errors"].first),
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
            ),
          );
        } else {
          if (!mounted) return;
          snackbarKey.currentState?.showSnackBar(
            SnackBar(
              content: const Text("Unknown error"),
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
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Welcome to",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),
              const Image(
                image: AssetImage("assets/images/logo_text.png"),
                width: 200,
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _identifierField(),
                      const SizedBox(height: 20),
                      _passwordField(),
                      const SizedBox(height: 20),
                      TextButton(
                          onPressed: _submitForm,
                          style: TextButton.styleFrom(
                              minimumSize: const Size.fromHeight(50),
                              backgroundColor:
                                  const Color.fromARGB(255, 4, 202, 138),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w700),
                          )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  TextFormField _buildTextField({
    required String label,
    required String hint,
    required FormFieldValidator<String> validator,
    required TextEditingController controller,
    bool isPassword = false,
    bool isPhoneNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhoneNumber ? TextInputType.number : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 4, 202, 138),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 255, 130, 2),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20),
      ),
      obscureText: isPassword,
      validator: validator,
    );
  }

  TextFormField _passwordField() {
    return _buildTextField(
      controller: _passwordController,
      label: "Password",
      hint: "Enter your password",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Password is required";
        }
        return null;
      },
      isPassword: true,
    );
  }

  TextFormField _identifierField() {
    return _buildTextField(
      controller: _identifierController,
      label: "Username/Email/Phone Number",
      hint: "Enter your identifier",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Identifier is required";
        }
        return null;
      },
    );
  }
}
