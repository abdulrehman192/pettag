import 'package:flutter/material.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/mySearchDialog.dart';

class SignUpPlan extends StatelessWidget {
  static const String singUpPlanRoute = "SignUpPlan";

  const SignUpPlan({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF774D),
                      Color(0xFFF14B57),
                    ],
                    begin: Alignment.topRight,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                height: MediaQuery.of(context).size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/clip_art.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 40,
                right: 10,
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(
                      context, PetSlideScreen.petSlideScreenRouteName),
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const SizedBox(
                    height: 80,
                  ),
                  Image.asset(
                    "assets/3x/Group 378@3x.png",
                    height: 60,
                    width: 60,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Sign up for PetTag+",
                    style: TextStyle(
                      fontSize: 25,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          padding: const EdgeInsets.only(left: 5, right: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width / 2.6,
                                  child: const Center(
                                    child: Text(
                                      "Basic",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                              buildListTile(value: "Limited Treats"),
                              buildListTile(value: "Ads"),
                              buildListTile(value: "Single pet profile"),
                              buildListTile(value: "Pack Track"),
                              buildListTile(value: "ParkFinder"),
                              buildListTile(value: "Messaging"),
                              buildListTile(value: "PetWall"),
                              buildListTile(value: "5 photo/ 2 clips"),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height / 2.5,
                          padding: const EdgeInsets.only(
                              left: 5, right: 5, bottom: 5),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.white,
                          ),
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 2.6,
                                    child: const Center(
                                      child: Text(
                                        "PetTag +",
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                                buildListTile(value: "Basic Membership"),
                                buildListTile(value: "Unlimited Treats"),
                                buildListTile(value: "View your Treats"),
                                buildListTile(value: "Ad free"),
                                buildListTile(value: "Booster shot"),
                                buildListTile(value: "5 Super Treats"),
                                buildListTile(value: "Back Track"),
                                buildListTile(value: "2 Pet Profile"),
                                buildListTile(
                                    value:
                                        "5 additional photo / 2 \nadditional clips"),
                                buildListTile(
                                  value:
                                      "10% of membership \nfees are donated to",
                                  textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset(
                          "assets/catAnim.png",
                          height: 120,
                          width: 120,
                        ),
                        Image.asset(
                          "assets/dogAnim.png",
                          height: 120,
                          width: 120,
                        ),
                      ],
                    ),
                  ),
                  GenericBShadowButton(
                    buttonText: 'My PetTag+',
                    onPressed: () {
                      // TODO: implementation left
                      showDialog(
                        context: context,
                        builder: (context) {
                          return MySearchDialog();
                        },
                      );
                    },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildListTile({String? value, textStyle}) {
    return Row(
      children: [
        RichText(
          text: TextSpan(
            text: "✓ ",
            style: TextStyle(
              color: Colors.pink[300],
            ),
            children: <TextSpan>[
              TextSpan(
                  text: value,
                  style: textStyle ??
                      const TextStyle(
                        height: 1.4,
                        fontSize: 15,
                        color: Colors.black,
                      )),
            ],
          ),
        ),
      ],
    );
  }
}
