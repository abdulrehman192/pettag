import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

class PrivacyPolicyDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Material(
              child: Container(
                color: Colors.white,
                height: 400,
                width: double.infinity,
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: 80,
                            width: 80,
                            child: Image.asset(
                              "assets/logo@3xUpdated.png",
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          const LocaleText(
                            "privacy_policy",
                            style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          SizedBox(
                            height: 255,
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 25),
                              scrollDirection: Axis.vertical,
                              child: LocaleText(
                                "policy",
                                style: TextStyle(
                                    color: Colors.pink[900], height: 1.5),

                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                        top: 10,
                        right: 10,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: 25,
                              width: 25,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  color: Colors.black),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(
                                Icons.cancel_rounded,
                                color: Colors.white,
                                size: 30,
                              ),
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
      ),
    );
  }
}
