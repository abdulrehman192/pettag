import 'package:flutter/material.dart';
import 'package:pettag/main.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

import '../constant.dart';
import 'agree_screen.dart';

class AboutScreen extends StatelessWidget {
  static const String aboutScreenRoute = 'AboutScreen';

  const AboutScreen({super.key});

  void _setFirstTimeScreen() async {
    //SharedPreferences prefs = await SharedPreferences.getInstance();
    //prefs.setBool("seen", true);
    sharedPrefs.isSeen = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          //color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //DemoWidget(),
              const Spacer(
                flex: 1,
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Image.asset(
                  'assets/logo@3xUpdated.png',
                  width: 80,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Welcome to PetTag",
                style: kwordStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)
                    .copyWith(fontSize: 17),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "A Unique Social App For Pets And Owners",
                style: kwordStyle(color: Colors.black).copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Swipe. Like. Meet. Socialize",
                style: kwordStyle(
                        color: Colors.black, fontWeight: FontWeight.normal)
                    .copyWith(fontSize: 13),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(
                "About PetTag",
                style: kwordStyle(color: Colors.black).copyWith(fontSize: 25),
              ),
              const Spacer(
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "PetTag is the exclusive social app for pet owners. Pets are a big part our lives and identity, so doesn't it make sense to look for someone special for you and your pet? We are happy to bring you a unique communal experience that brings people and pets together!",
                  style: TextStyle(
                      color: Colors.pink[900], fontSize: 14, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              GenericBShadowButton(
                buttonText: "Next",
                onPressed: () async {
                  _setFirstTimeScreen();
                  Navigator.pushNamed(context, AgreeScreen.agreeScreenRoute);
                },
              ),
              const Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
