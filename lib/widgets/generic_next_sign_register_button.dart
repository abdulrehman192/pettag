import 'package:flutter/material.dart';

class GenericBButton extends StatelessWidget {
  const GenericBButton({required this.buttonText, required this.onPressed});
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      splashColor: Colors.transparent,
      elevation: 5.0,
      onPressed: onPressed,
      child: Container(
        alignment: Alignment.center,
        width: MediaQuery.of(context).size.width/2,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.white,
              //blurRadius: 0,
              offset: Offset(0, -3),
            ),
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0,3),
              blurRadius: 3,
            ),
          ],
          gradient: const LinearGradient(
            begin: Alignment.centerRight,
            end: Alignment.bottomLeft,
            colors: [
              Color.fromRGBO(252, 44, 53, 1.0),
              Color.fromRGBO(253, 121, 45, 1.0),
            ],
          ),
        ),
        child: Text(
          buttonText ?? 'no text',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}
