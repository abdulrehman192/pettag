/*import 'package:flutter/material.dart';
import 'package:pettag/widgets/subscriptionDealCard.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AnotherDialog extends StatefulWidget {
  static const String mySearchDialogScreenDialog = "AnotherDialog";

  @override
  _AnotherDialogState createState() => _AnotherDialogState();
}

class _AnotherDialogState extends State<AnotherDialog> {
  bool pettagStandard = false;
  bool pettag = false;
  bool pettagBreeder = false;
  bool pettagRescuer = false;
  int _currentPos = 0;
  bool somethingSelected = false;

  List<String> listPaths = [
    "assets/dogsAndCats/dog4.png",
    "assets/dogsAndCats/dog3.png",
    "assets/dogsAndCats/dog2.png",
    "assets/dogsAndCats/dog5.png",
  ];

  List<String> planList = [
    "pettag Standard",
    "pettag+",
    "pettag Breeder",
    "pettag Rescuer",
  ];

  List<String> duration = [
    "25 likes every 8 hours\nAd pop up every 10 swipes\n1 Pet Treat(superlike) per day\n1 pet profile\nPack Track\nPark finder\n5 photo and 2 video (pets) 3 owner",
    "Unlimited Likes\nSee who likes you\n1 booster shot\nNo ads\n5 Pet Treats(super likes)\nBack Track(rewind)\n2 pet profiles\nAdditional 5 photos and 2 video clips",
    "Set up a breeder profile\n30 photos\n3 booster shots\n6 profiles",
    "Only can be created by Shelters\n15 pet profiles\n3 photos/ 1 video clips\n3 boosts",
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            child: Container(
              height: 600,
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    height: 350,
                    width: double.infinity,
                    color: Colors.blue,
                    padding: EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CarouselSlider.builder(
                          itemCount: 4,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(100),
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: CircleAvatar(
                                      backgroundImage:
                                          AssetImage(listPaths[index]),
                                      radius: 50,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1,
                                  ),
                                  Text(
                                    "${planList[index]}",
                                    style: dialogTitle.copyWith(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    "${duration[index]}",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                          options: CarouselOptions(
                              autoPlay: false,
                              height: 300,
                              onPageChanged: (index, reason) {
                                setState(() {
                                  _currentPos = index;
                                });
                              }),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: listPaths.map((url) {
                            int index = listPaths.indexOf(url);
                            return Container(
                              width: 8.0,
                              height: 8.0,
                              margin: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 2.0),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: _currentPos == index
                                    ? Color.fromRGBO(255, 255, 255, 0.9)
                                    : Color.fromRGBO(255, 255, 255, 0.4),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 230,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pettagStandard = true;
                                    pettag = false;
                                    pettagBreeder= false;
                                    pettagRescuer=false;
                                  });
                                },
                                child: SubscriptionDealCard(
                                  duration: "12",
                                  price: "0",
                                  isVisible: pettagStandard,
                                  plan: "pettag Standard",
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pettagStandard = false;
                                    pettag = true;
                                    pettagBreeder= false;
                                    pettagRescuer=false;
                                  });
                                },
                                child: SubscriptionDealCard(
                                  duration: "12",
                                  price: "5",
                                  isVisible: pettag,
                                  plan: "pettag+",
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pettagStandard = false;
                                    pettag = false;
                                    pettagBreeder= true;
                                    pettagRescuer=false;
                                  });
                                },
                                child: SubscriptionDealCard(
                                  duration: "1",
                                  price: "30",
                                  plan: "pettag Breeder",
                                  isVisible: pettagBreeder,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    pettagStandard = false;
                                    pettag = false;
                                    pettagBreeder= false;
                                    pettagRescuer=true;
                                  });
                                },
                                child: SubscriptionDealCard(
                                  duration: "6",
                                  price: "25",
                                  plan: "pettag Rescuer",
                                  isVisible: pettagRescuer,
                                ),
                              ),
                            ],
                          ),
                        ),
                        GenericBShadowButton(
                          buttonText: "Continue",
                          onPressed: () {
                            (pettag || pettagBreeder || pettagRescuer || pettagStandard)
                                ? Navigator.pop(context)
                                : print("");
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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
