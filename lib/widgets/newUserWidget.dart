import 'package:flutter/material.dart';

class NewUserTextWidget extends StatelessWidget {
  NewUserTextWidget({super.key,
    required this.action,
    required this.userType,
    required this.onTap,
  });

  VoidCallback onTap;
  final String userType;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InkWell(
          onTap: onTap,
          child: Text.rich(
            TextSpan(
                text: userType,
                style: const TextStyle(
                  color: Colors.white54,
                ),
                children: [
                  TextSpan(
                    text: action,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontSize: 15),
                  )
                ]),
          ),
        ),
      ],
    );
  }
}
