import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/main.dart';
import 'package:pettag/screens/sign_in_screen.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

class HomeScreen extends StatefulWidget {
  static const String homeScreenRoute = 'HomeScreen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isCatSelected = false;
  bool isDogSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF774D),
                Color(0xFFF14B57),
              ],
              begin: Alignment.topRight,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/clip_art.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: Image.asset('assets/3x/Group 378@3x.png',
                      width: 100, height: 100),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                Text(
                  'Hey,',
                  style: kwordStyle().copyWith(fontSize: 25),
                ),
                const SizedBox(height: 20),
                Text(
                  'You are creating an account for',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 60),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getHomeScreenCircularImage(
                            'assets/newimg.png',
                          ),
                          const SizedBox(width: 20),
                          Checkbox(
                            value: isCatSelected,
                            checkColor: Colors.black45,
                            activeColor: Colors.grey[700]!.withOpacity(0.3),
                            onChanged: (value) {
                              setState(() {
                                isCatSelected = value!;
                                isDogSelected = value ? false : true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          getHomeScreenCircularImage('assets/dogArt.png'),
                          const SizedBox(width: 20),
                          Checkbox(
                            value: isDogSelected,
                            checkColor: Colors.black45,
                            activeColor: Colors.grey[700]!.withOpacity(0.3),
                            onChanged: (value) {
                              setState(() {
                                isDogSelected = value!;
                                isCatSelected = value ? false : true;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 60,
                ),
                GenericBShadowButton(
                  buttonText: 'Next',
                  onPressed: () async {
                    if (isCatSelected || isDogSelected) {
                      if (isCatSelected) {
                        sharedPrefs.petType = "Cat";
                        sharedPrefs.currentUserPetType = "Cat";
                      } else {
                        sharedPrefs.petType = "Dog";
                        sharedPrefs.currentUserPetType = "Dog";
                      }
                      print("PetType : ${sharedPrefs.petType}");
                      print("IsSeen : ${sharedPrefs.isSeen}");
                      //sharedPrefs.isSeen
                      Navigator.pushNamed(
                          context, SignInScreen.secondScreenRoute);
                    }
                  },
                ),
                const SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
