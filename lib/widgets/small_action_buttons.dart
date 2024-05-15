import 'package:flutter/material.dart';

class SmallActionButtons extends StatelessWidget {
  SmallActionButtons({super.key,
    required this.icon,
    required this.height,
    required this.onPressed,
    required this.width,
  });

  VoidCallback onPressed;
  Widget icon;
  double height;
  double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        
      ),
      child: RawMaterialButton(
        onPressed: onPressed,
        fillColor: const Color(0xFFFDF7F7),
        constraints: BoxConstraints.tightFor(
          height: height,
          width: width,
        ),
        elevation: 3,
        padding: const EdgeInsets.all(8),
        shape: const CircleBorder(),
        child: Center(child: icon),
      ),
    );
  }
}
