import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:food_delivery/components/snackbars.dart';
import 'package:food_delivery/main.dart';
import 'package:food_delivery/models/register_role_model.dart';
import 'package:food_delivery/network/dio_client.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final List<RegisterRole> options = [
    RegisterRole(label: "Customer", value: "CUSTOMER"),
    RegisterRole(label: "Delivery", value: "DELIVERY"),
    RegisterRole(label: "Restaurant", value: "RESTAURANT")
  ];

  String? _selectedRole;
  String? _usernameError;
  String? _emailError;
  String? _phoneNumberError;

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();

  void _onUsernameChanged() {
    if (_usernameFocusNode.hasFocus) {
      if (_usernameError != null) {
        setState(() {
          _usernameError = null;
        });
      }
    }
  }

  void _onEmailChanged() {
    if (_emailFocusNode.hasFocus) {
      if (_emailError != null) {
        setState(() {
          _emailError = null;
        });
      }
    }
  }

  void _onPhoneNumberChanged() {
    if (_phoneNumberFocusNode.hasFocus) {
      if (_phoneNumberError != null) {
        setState(() {
          _phoneNumberError = null;
        });
      }
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      var dioClient = DioClient();

      try {
        var response = await dioClient.dio.post(
          "/auth/register",
          data: {
            "username": _usernameController.text,
            "email": _emailController.text,
            "password": _passwordController.text,
            "role": _selectedRole,
            "phone_number": _phoneNumberController.text,
          },
        );

        if (response.statusCode == 201) {
          var message = response.data["message"];

          if (!mounted) return;
          snackbarKey.currentState?.showSnackBar(
            showValidSnackbar(message),
          );

          Navigator.of(context).pushReplacementNamed("/login");
        }
      } on DioException catch (e) {
        if (e.response != null && e.response!.statusCode == 400) {
          var errors = e.response!.data["errors"];

          setState(() {
            _usernameError = errors["username"]?.first;
            _emailError = errors["email"] != null
                ? "A ${errors["email"].first}"
                : errors["email"]?.first;
            _phoneNumberError = errors["phone_number"] != null
                ? "A ${errors["phone_number"].first}"
                : errors["phone_number"]?.first;
          });
        } else {
          if (!mounted) return;
          snackbarKey.currentState?.showSnackBar(
            showInvalidSnackbar("Unknown error"),
          );
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _usernameController.addListener(_onUsernameChanged);
    _emailController.addListener(_onEmailChanged);
    _phoneNumberController.addListener(_onPhoneNumberChanged);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
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
                "Get started with",
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
                      _usernameField(),
                      const SizedBox(height: 20),
                      _emailField(),
                      const SizedBox(height: 20),
                      _passwordField(),
                      const SizedBox(height: 20),
                      _roleDropdown(),
                      const SizedBox(height: 20),
                      _phoneField(),
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
                            "Register",
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
    FocusNode? focusNode,
    String? errorText,
    bool isEmail = false,
    bool isPassword = false,
    bool isPhoneNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: isPhoneNumber
          ? TextInputType.number
          : isEmail
              ? TextInputType.emailAddress
              : null,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
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

  TextFormField _phoneField() {
    return _buildTextField(
      controller: _phoneNumberController,
      focusNode: _phoneNumberFocusNode,
      label: "Phone number",
      hint: "Enter your phone number",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Phone number is required";
        }
        return null;
      },
      isPhoneNumber: true,
      errorText: _phoneNumberError,
    );
  }

  DropdownButtonFormField<String> _roleDropdown() {
    return DropdownButtonFormField(
      decoration: InputDecoration(
        labelText: "Role",
        hintText: "Select a role",
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
      value: _selectedRole,
      items: options.map<DropdownMenuItem<String>>((RegisterRole option) {
        return DropdownMenuItem<String>(
            value: option.value, child: Text(option.label));
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedRole = value;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Please select a role";
        }
        return null;
      },
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
        if (value.length < 8) {
          return "Password must be at least 8 characters long";
        }
        return null;
      },
      isPassword: true,
    );
  }

  TextFormField _emailField() {
    return _buildTextField(
      controller: _emailController,
      focusNode: _emailFocusNode,
      label: "Email",
      hint: "Enter your email",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Email is required";
        }
        return null;
      },
      errorText: _emailError,
      isEmail: true,
    );
  }

  TextFormField _usernameField() {
    return _buildTextField(
      controller: _usernameController,
      focusNode: _usernameFocusNode,
      label: "Username",
      hint: "Enter your username",
      validator: (value) {
        if (value == null || value.isEmpty) {
          return "Username is required";
        }
        return null;
      },
      errorText: _usernameError,
    );
  }
}
