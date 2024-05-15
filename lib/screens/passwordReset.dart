import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

import '../constant.dart';

class PasswordReset extends StatefulWidget {

   final String? message;

  const PasswordReset({super.key,  this.message});

  @override
  _PasswordResetState createState() => _PasswordResetState();
}

class _PasswordResetState extends State<PasswordReset> {

  TextEditingController emailController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool isLoading = false;

  String email = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFF774D),
                      Color(0xFFF14B57),
                    ],
                    begin: Alignment.topRight,
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                height: MediaQuery.of(context).size.height / 2.1,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        "assets/clip_art.png",
                      ),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const LocaleText("enter_your_email", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(widget.message.toString(), style: TextStyle(color: Colors.grey[300], fontWeight: FontWeight.normal, fontSize: 14),),
                      const SizedBox(
                        height: 20,
                      ),
                      SizedBox(
                        height: 50,
                        child: TextFormField(
                          validator: (value){
                            if(value!.isEmpty){
                              return "Required";
                            }else{
                              return null;
                            }
                          },
                          onSaved: (value){
                            setState(() {
                              email = value.toString();
                            });
                          },
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            hintText: Locales.string(context, 'email'),
                            filled: true,
                            contentPadding: const EdgeInsets.all(16.0),
                            hintStyle: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 14,
                              fontWeight: FontWeight.normal
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            errorStyle: const TextStyle(
                              color: Colors.white,
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.redAccent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius:
                                BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      isLoading ? const Center(child: CircularProgressIndicator(color: mainColor, backgroundColor: Colors.white,),) : GenericBShadowButton(
                        buttonText: Locales.string(context, 'reset_password'),
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          try {
                            _formKey.currentState!.save();
                            if(_formKey.currentState!.validate()){
                              final user = await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                              const snackbar = SnackBar(
                                duration: Duration(seconds: 2),
                                content:
                                LocaleText("email_send"),
                              );
                              ScaffoldMessenger.of(context) .showSnackBar(snackbar);
                              await Future.delayed(const Duration(seconds: 3), (){
                                Navigator.pop(context);
                              });
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
