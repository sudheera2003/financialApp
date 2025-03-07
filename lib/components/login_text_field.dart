import 'package:flutter/material.dart';

class LoginTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String hintText;
  final bool obscureText;
  final Color borderColor; // New property for dynamic border color

  const LoginTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.borderColor = Colors.white, // Default border color
  });

  @override
  _LoginTextFieldState createState() => _LoginTextFieldState();
}

class _LoginTextFieldState extends State<LoginTextField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    final hintTextLower = widget.hintText.toLowerCase();
    final isPasswordField = hintTextLower.contains("password");

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        controller: widget.controller,
        obscureText: _isObscured,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: widget.borderColor), // =border color
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.deepOrangeAccent), // Change focus color
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400), // Hint text color
          suffixIcon: isPasswordField
              ? IconButton(
                  icon: Icon(
                    _isObscured ? Icons.visibility_off : Icons.visibility,
                    color: Colors.deepOrangeAccent, // Change icon color
                  ),
                  onPressed: () {
                    setState(() {
                      _isObscured = !_isObscured;
                    });
                  },
                )
              : null,
        ),
        style: TextStyle(color: Colors.white), // Change input text color
      ),
    );
  }
}
