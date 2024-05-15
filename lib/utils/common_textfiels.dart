import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget offerTextField({
   IconData? iconData,
  String? label,
  TextEditingController? controller,
  FocusNode? focusNode,
  Function(String)? onSubmitted,
  double? width,
  TextInputType? type,
  bool isPriceField = false,
  Function(String)? onChanged,
  List<TextInputFormatter>? inputFormatter,
}) {

  return SizedBox(
    width: 250,
    child: Material(
      elevation: 6.0,
      borderRadius: BorderRadius.circular(15.0),
      child: Column(
        children: [
          TextField(keyboardType: type,focusNode: focusNode,onSubmitted: onSubmitted,
            controller: controller,onChanged: onChanged,
            decoration: InputDecoration(
              prefixIcon: Icon(
                iconData,
                color: Colors.red
              ),
              labelText: label,
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(15.0),
              ),
            ),inputFormatters: inputFormatter,
          ),

        ],
      ),
    ),
  );
}