/*import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pettag/widgets/subscriptionDealCard.dart';

class CustomSearchDialog extends StatefulWidget {
  @override
  _CustomSearchDialogState createState() => _CustomSearchDialogState();
}

class _CustomSearchDialogState extends State<CustomSearchDialog> {
  PageController _controller = PageController(
    initialPage: 0,
  );
  bool pettag = false;
  bool silver = false;
  bool gold = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 2,
      backgroundColor: Color(0xFFFFF6F7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        height: 500,
        child: Column(
          children: [
            Container(
              height: 250,
              padding: EdgeInsets.all(5.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20),
                  topLeft: Radius.circular(20),
                ),
                color: Colors.pink,
              ),
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  PageView(
                    controller: _controller,
                    children: [
                      buildCarousalCard(
                          imagePath: images[6], title: "pettag+", period: "12"),
                      buildCarousalCard(
                          imagePath: images[2], title: "Silver", period: "1"),
                      buildCarousalCard(
                          imagePath: images[5], title: "Gold", period: "6"),
                    ],
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        FontAwesomeIcons.solidTimesCircle,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 180,
              padding: EdgeInsets.all(0),
              color: Colors.white54,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pettag = true;
                            silver = false;
                            gold = false;
                          });
                        },
                        child: SubscriptionDealCard(
                          duration: "12",
                          price: "100",
                          isVisible: pettag,
                          plan: "pettag+",
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pettag = false;
                            silver = true;
                            gold = false;
                          });
                        },
                        child: SubscriptionDealCard(
                          duration: "16",
                          price: "100",
                          plan: "Silver",
                          isVisible: silver,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            pettag = false;
                            silver = false;
                            gold = true;
                          });
                        },
                        child: SubscriptionDealCard(
                          duration: "1",
                          price: "100",
                          plan: "Gold Plan",
                          isVisible: gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GenericBShadowButton(
              buttonText: "Continue",
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Column buildCarousalCard({String imagePath, String title, String period}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 50,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: dialogTitle,
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          "For $period months",
          style: dialogTitle,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          "Get 5 Free Super Likes a day & more",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}*/




