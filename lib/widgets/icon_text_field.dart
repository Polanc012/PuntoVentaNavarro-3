import 'package:flutter/material.dart';

class IconTextField extends StatelessWidget {
  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final bool obscureText;
  final TextStyle? hintStyle;

  const IconTextField({
    Key? key,
    required this.icon,
    required this.hintText,
    required this.controller,
    this.obscureText = false,
    this.hintStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: Icon(icon),
        hintText: hintText,
        hintStyle: hintStyle, // Usar el estilo del hint
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      obscureText: obscureText,
    );
  }
}
