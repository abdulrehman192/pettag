import 'package:flutter/material.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import '../main.dart';
import 'home_screen.dart';

class AgreeScreen extends StatelessWidget {
  static const String agreeScreenRoute = 'AgreeScreen';

  const AgreeScreen({super.key});

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
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                padding: const EdgeInsets.only(top: 20),
                child: Image.asset(
                  'assets/logo@3xUpdated.png',
                  height: 80,
                  width: 80,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Terms & Condition",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "These terms and conditions ('Terms', 'Agreement') are an agreement between MyTag LLC ('MyTag LLC','us','we' or 'our') and you ('User', 'you' or 'your'). This Agreement sets forth the general terms and conditions of your use of the Pet-Tag mobile application and any of it's products or services (collectively, 'Mobile Application' or 'Services').",
                  style: TextStyle(color: Colors.pink[700], height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 5.0),
                child: Text(
                  "Privacy Policy",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      "The privacy policy ('Policy') describes how MyTag LLC ('MyTag LLC','we','us' or 'our') collects, protects and uses the personally identifiable information ('Personal Information') you ('User','you' or 'your') may provide in the Pet-Tag mobile application and any of it's products or services (collectively, 'Mobile Application' or 'Services'). It also describes the choices available to you regarding our use of your Personal Information and how you can access and update this information. This Policy does not apply to the practices of companies that we do not own or control, or to individuals that we do not employ or maintain.",
                      style: TextStyle(color: Colors.pink[700], height: 1.3, ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              GenericBShadowButton(
                buttonText: "I agree",
                onPressed: ()async {
                  //_setFirstTimeScreen();
                  Navigator.pushNamed(context, HomeScreen.homeScreenRoute);
                },
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
