import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/widgets/custom_textfield.dart';
import 'package:pettag/widgets/generic_next_sign_register_button.dart';
import 'package:pettag/widgets/top_screen_content.dart';
import 'pet_slide_screen.dart';

class SecondRegisterScreen extends StatefulWidget {
  static const String secondRegisterScreenRoute = 'SecondRegisterScreen';

  const SecondRegisterScreen({super.key});
  @override
  _SecondRegisterScreenState createState() => _SecondRegisterScreenState();
}

class _SecondRegisterScreenState extends State<SecondRegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFFF774D),
                  Color(0xFFF14B57),
                ],
                begin: Alignment.topRight,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/clip_art.png",),
                  fit: BoxFit.contain,
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(
                      width: currentMediaWidth(context),
                      height: currentMediaHeight(context)-20,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          ScreenTopSection(
                            containerWidth: currentMediaWidth(context),
                            containerHeight: 320,
                            topPadding: 65,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          SizedBox(
                            width: MediaQuery.of(context).size.width/1.3,
                            child: Column(
                              children: [
                                CustomTextField(
                                  text: "First Name",
                                  hintStyle: hintTextStyle,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),CustomTextField(
                                  text: "Last Name",
                                  hintStyle: hintTextStyle,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),CustomTextField(
                                  text: "Email Address",
                                  hintStyle: hintTextStyle,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),CustomTextField(
                                  text: "Paasword",
                                  obscureText: true,
                                  hintStyle: hintTextStyle,

                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 30),
                          GenericBButton(
                            buttonText: 'Register',
                            onPressed: () {
                              Navigator.of(context)
                                  .pushNamed(PetSlideScreen.petSlideScreenRouteName);
                            },
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
