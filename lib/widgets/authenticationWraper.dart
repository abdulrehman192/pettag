import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/sign_in_screen.dart';
import 'package:provider/provider.dart';


class AuthenticationWraper extends StatelessWidget {

  const AuthenticationWraper();
  @override
  Widget build(BuildContext context) {
    final firebaseUser = context.watch<User>();
    if(firebaseUser != null){
      return PetSlideScreen();
    }
    return SignInScreen();
  }
}