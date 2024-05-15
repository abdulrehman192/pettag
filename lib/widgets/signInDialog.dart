import 'package:flutter/material.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

class SignInDialog extends StatefulWidget {
  @override
  _SignInDialogState createState() => _SignInDialogState();
}

class _SignInDialogState extends State<SignInDialog> {
  bool _isVisibleCat = false;
  bool _isVisibleDog = false;
  String interestedIn = '';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: 330,
        width: 200,
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              "Interested In",
              style: TextStyle(
                  fontSize: 17,
                  color: Colors.pink[900],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisibleCat = true;
                      _isVisibleDog = false;
                      interestedIn = 'Cat';
                    });
                  },
                  child: buildImageButtons(
                      context, _isVisibleCat, 'assets/newimg.png', "Cat"),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisibleDog = true;
                      _isVisibleCat = false;
                      interestedIn = 'Dog';
                    });
                  },
                  child: buildImageButtons(
                      context, _isVisibleDog, 'assets/dogArt.png', "Dog"),
                ),
              ],
            ),
            /*TextField(
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(50),
                hintText: "Enter Your Email-id",
                hintStyle: TextStyle(color: Colors.black38),
                border: InputBorder.none,
              ),
            ),*/
            GenericBShadowButton(
              buttonText: "Submit",
              onPressed: () {
                (_isVisibleCat || _isVisibleDog)
                    ? Navigator.pop(context, interestedIn)
                    : null;
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  SizedBox buildImageButtons(BuildContext context, isVisible, imagePath, text) {
    return SizedBox(
      height: 100,
      width: 70,
      child: Column(
        children: [
          Stack(
            children: [
              Visibility(
                visible: isVisible,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: Colors.pink.shade900,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Image.asset(
                  imagePath,
                  height: 70,
                ),
              )
            ],
          ),
          Text(
            text,
            style:
                TextStyle(color: Colors.pink[900], fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
