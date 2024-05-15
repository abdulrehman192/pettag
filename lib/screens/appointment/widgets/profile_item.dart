import 'package:flutter/material.dart';


class ProfileItem extends StatelessWidget {
  const ProfileItem({Key? key, required this.title, required this.value, this.onTap}) : super(key: key);

  final String title;
  final String value;
  final Function()? onTap;


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15.0, right: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold),),
              GestureDetector(
                  onTap: onTap,
                  child: Text(value)
              ),
            ],
          ),
        ),
        Container(
          color: Colors.grey,
          height: 0.4,
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }
}
