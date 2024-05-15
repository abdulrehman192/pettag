import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  CustomTextField({
    this.hintStyle,
    this.obscureText,
    this.text,
    this.suffixIcon,
    this.controller,
  });

  final String? text;
  final TextStyle? hintStyle;
  bool? obscureText;
  Icon? suffixIcon;
  TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      textInputAction: TextInputAction.next,
      obscureText: obscureText ?? false,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        fillColor: Colors.white,
        hintText: text,
        filled: true,
        contentPadding: const EdgeInsets.all(8.0),
        hintStyle: hintStyle,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: const BorderSide(
            color: Colors.transparent,
          ),
        ),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(
              color: Colors.transparent,
            )),
      ),
    );
  }
}
