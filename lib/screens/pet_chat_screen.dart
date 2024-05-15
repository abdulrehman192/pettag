import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/main.dart';
import 'package:pettag/widgets/message_container_search_bar.dart';
import 'package:pettag/widgets/pet_wall_screen.dart';

import '../constant.dart';
import 'pet_detail_screen.dart';
import 'pet_slide_screen.dart';

class PetChatScreen extends StatefulWidget {
  static const String petChatScreenRoute = 'PetChatScreen';

  const PetChatScreen({super.key});

  @override
  _PetChatScreenState createState() => _PetChatScreenState();
}

class _PetChatScreenState extends State<PetChatScreen> {
  InkWell buildAppBarImageIcon(
      {required String image, required VoidCallback onPressed,
      double? width,
      double? height}) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset(
        image,
        width: width,
        height: height,
      ),
    );
  }

  bool _messages = true;
  bool _petWall = false;

  late DocumentSnapshot petDoc;

  getMyDocument() async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();
    Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
    List<String> petIds = data['pet'];

    petDoc =
        await FirebaseFirestore.instance.collection("Pet").doc(petIds[0]).get();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
              ? Colors.blue[600]
              : appBarBgColor,
          elevation: 0.0,
          // TODO: Implemenetation Left
          leading: GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 15,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/dog (1)@2x.png",
                  width: 15,
                  height: 15,
                )),
            onTap: () {
              Navigator.pushNamed(
                  context, PetDetailedScreen.petDetailedScreenRoute);
            },
          ),
          centerTitle: true,
          title: buildAppBarImageIcon(
            image: 'assets/2x/Group 378@2x.png',
            width: 20,
            height: 20,
            onPressed: () {
              Navigator.pushReplacementNamed(
                  context, PetSlideScreen.petSlideScreenRouteName);
            },
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
              onTap: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _messages = true;
                      _petWall = false;
                    });
                  },
                  child: LocaleText(
                    "messages",
                    style: TextStyle(
                        color: _messages ? Colors.black : Colors.brown[100],
                        fontSize: 15,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.pink[100],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _petWall = true;
                      _messages = false;
                    });
                  },
                  child: Text(
                    "PetWall",
                    style: TextStyle(
                        color: _petWall ? Colors.black : Colors.brown[200],
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
              color: Colors.pink[100],
            ),
            (_messages)
                ? const MessageContainerWithSearchBar()
                : const PetWallScreen(),
          ],
        ));
  }
}
