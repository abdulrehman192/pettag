import 'package:flutter/material.dart';
import 'package:pettag/screens/treat_screen.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/main.dart';

class PetFoodIconInAppBar extends StatefulWidget {
  const PetFoodIconInAppBar({
    this.isLeft = true,
  });

  final bool isLeft;

  @override
  _PetFoodIconInAppBarState createState() => _PetFoodIconInAppBarState();
}

class _PetFoodIconInAppBarState extends State<PetFoodIconInAppBar> {
  var rightColors;
  var leftColors;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 35,
          width: 90,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Positioned(
          left: 4,
          top: 4,
          bottom: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                leftColors = Colors.pink;
                rightColors = Colors.white;
              });
              Navigator.pushReplacementNamed(
                  context, PetSlideScreen.petSlideScreenRouteName);
            },
            child: Container(
              width: 41,
              height: 33,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: widget.isLeft ?  Colors.pink : Colors.white?? Colors.pink,
              ),
              child: Image.asset(
                "assets/2x/Group 378@2x.png",
                height: 15,
                width: 15,
                color:
                    leftColors == Colors.pink  || widget.isLeft? Colors.white : Colors.black12,
              ),
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          bottom: 4,
          child: InkWell(
            onTap: () {
              setState(() {
                rightColors = Colors.pink;
                leftColors = Colors.white;
              });
              Navigator.pushReplacementNamed(
                  context, TreatScreen.treatScreenRoute);
            },
            child: Container(
              width: 41,
              height: 33,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: widget.isLeft ? Colors.white : Colors.pink?? Colors.white,
              ),
              child: Image.asset(
                sharedPrefs.currentUserPetType == 'Cat'? "assets/2x/tuna-fish.png" :"assets/2x/Path 373@2x.png",
                height: 15,
                width: 15,
                color:
                    rightColors == Colors.pink || widget.isLeft ? Colors.black12 : Colors.white,
              ),
            ),
          ),
        ),
        /*buildPositionedRight(
            widget.isLeft ? Colors.pinkAccent : Colors.white12),
        buildPositionedLeft(
            widget.isLeft ? Colors.white12 : Colors.pinkAccent),*/
      ],
    );
  }

  Positioned buildPositionedLeft(color) {
    return Positioned(
      bottom: 4,
      top: 4,
      right: 4,
      child: Container(
        width: 40,
        height: 33,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        child: Image.asset(
          "assets/2x/Path 373@2x.png",
          height: 15,
          width: 15,
        ),
      ),
    );
  }

  Positioned buildPositionedRight(color) {
    return Positioned(
      bottom: 4,
      top: 4,
      left: 4,
      child: Container(
        width: 40,
        height: 33,
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        child: Image.asset(
          "assets/2x/Group 378@2x.png",
          height: 15,
          width: 15,
        ),
      ),
    );
  }
}

/*Container(
          constraints: BoxConstraints.tightFor(
            width: 90,
            height: 35,
          ),
          decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        Positioned(
          right: 10,
          top: 5,
          bottom: 5,
          child: Image.asset(petFoodIconPath,width: 25,height: 25,),
        ),
        Positioned(
          left: 1,
          top: 1,
          child: Container(
              padding: EdgeInsets.all(5),
              constraints: BoxConstraints.tightFor(
                width: 45,
                height: 33,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.pinkAccent,
              ),
              child: Image.asset("assets/2x/Group 378@2x.png",height: 15,width: 15,)
          ),
        ), */
