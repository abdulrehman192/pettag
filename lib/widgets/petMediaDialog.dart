import 'package:flutter/material.dart';

class PetMediaDialog extends StatelessWidget {
  PetMediaDialog({required this.imagePath});
  String imagePath;
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Stack(children: [
        Container(
          height: MediaQuery.of(context).size.width / 1.4,
          //width: 200,
          padding: const EdgeInsets.all(8),
          child: imagePath!=null ? Image.network(
            imagePath,
            fit: BoxFit.cover,
          ):null,
        ),
        Positioned(
          top: 0,
          left: 0,
          child: GestureDetector(
            onTap: ()=>Navigator.pop(context),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5), color: Colors.grey),
              child: const Icon(Icons.close, size: 18,),
            ),
          ),
        ),
      ]),
    );
  }
}
