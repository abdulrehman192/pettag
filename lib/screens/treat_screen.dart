import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/widgets/myTreats.dart';
import 'package:pettag/widgets/petDate.dart';
import 'package:pettag/widgets/petFood_icon_appbar.dart';
import 'package:pettag/widgets/topPicks.dart';
import 'package:pettag/widgets/treat.dart';

import 'pet_chat_screen.dart';
import 'pet_detail_screen.dart';

class TreatScreen extends StatefulWidget {
  static const String treatScreenRoute = 'TreatScreen';

  const TreatScreen({super.key});

  @override
  _TreatScreenState createState() => _TreatScreenState();
}

class _TreatScreenState extends State<TreatScreen> {
  bool _treat = true;
  bool _topPicks = false;
  bool _petDate = false;
  bool _myTreats = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0.0,
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 20,
                height: 20,
              )),
          onTap: () {
            Navigator.pushNamed(
                context, PetDetailedScreen.petDetailedScreenRoute);
          },
        ),
        centerTitle: true,
        title: const PetFoodIconInAppBar(
          isLeft: false,
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon simple-hipchat@2x.png",
                  width: 22,
                  height: 22,
                )),
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.19,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _treat = true;
                        _myTreats = false;
                        _petDate = false;
                        _topPicks = false;
                      });
                    },
                    child: Text(
                      "Treat",
                      style: TextStyle(
                          color: _treat ? Colors.black : Colors.brown[100],
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _myTreats = false;
                      _petDate = false;
                      _topPicks = true;
                    });
                  },
                  child: Text(
                    "Top Picks",
                    style: TextStyle(
                        color: _topPicks ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _myTreats = false;
                      _petDate = true;
                      _topPicks = false;
                    });
                  },
                  child: Text(
                    "PetDate",
                    style: TextStyle(
                        color: _petDate ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _treat = false;
                      _topPicks = false;
                      _petDate = false;
                      _myTreats = true;
                    });
                  },
                  child: Text(
                    "My Treats",
                    style: TextStyle(
                        color: _myTreats ? Colors.black : Colors.brown[200],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            Container(
              margin: const EdgeInsets.only(bottom: 5),
              height: 1,
              width: MediaQuery.of(context).size.width - 40,
              color: Colors.pink[300],
            ),
            Container(
              child: (_treat)
                  ? const Treat()
                  : (_topPicks)
                      ? const TopPicks()
                      : (_petDate)
                          ? const PetDate()
                          : const MyTreat(),
            ),
          ],
        ),
      ),
    );
  }
}
