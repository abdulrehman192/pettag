import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    Key? key,
     this.width,
     this.height,
     this.child,
  }) : super(key: key);

  final double? height;
  final double? width;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Card(
        color: Colors.white,
        elevation: 6,
        shadowColor: Colors.black,
        // margin: const EdgeInsets.symmetric(vertical: 5.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: child,
        ),
      ),
    );
  }
}
