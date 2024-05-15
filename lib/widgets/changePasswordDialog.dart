import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

class ChangePasswordDialog extends StatefulWidget {
  @override
  _ChangePasswordDialogState createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<ChangePasswordDialog> {
  final TextEditingController oldPassword = TextEditingController();
  final TextEditingController newPassword = TextEditingController();
  final TextEditingController confirmPassword = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //final RoundedLoadingButtonController _btnController = RoundedLoadingButtonController();
  bool isLoading = false;

  bool currentPasswordStatus = true;

  Future<bool> checkCurrentPassword() async {
    var firebaseUser = FirebaseCredentials().auth.currentUser;
    var authCredentials = EmailAuthProvider.credential(
        email: firebaseUser!.email!, password: oldPassword.text);
    print("$authCredentials the current change pass");
    try {
      final user =
          await firebaseUser.reauthenticateWithCredential(authCredentials);
      print("$user the current user");
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      child: Form(
        key: _formKey,
        child: SizedBox(
          height: 400,
          width: 330,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.close_sharp,
                  color: Colors.black45,
                  size: 25,
                ),
              ),
              const Center(
                child: Text(
                  "Change Password",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.normal),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      validator: (value) {
                        if (value != null) {
                          if (currentPasswordStatus) {
                            return null;
                          } else {
                            return 'Incorrect Passowrd.';
                          }
                        } else {
                          return 'Enter Your Old Password';
                        }
                      },
                      controller: oldPassword,
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        hintText: "Enter Your Old Password",
                        hintStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      controller: newPassword,
                      obscureText: true,
                      validator: (value) {
                        if (value != null) {
                          return null;
                        } else {
                          return 'Enter Your New Password';
                        }
                      },
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        hintText: "Enter Your New Password",
                        hintStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Center(
                child: SizedBox(
                  height: 40,
                  width: MediaQuery.of(context).size.width / 1.6,
                  child: Center(
                    child: TextFormField(
                      cursorHeight: 30,
                      controller: confirmPassword,
                      obscureText: true,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 18),
                        hintText: "Re-Enter Your New Password",
                        hintStyle: const TextStyle(
                          fontSize: 17,
                        ),
                        errorStyle: const TextStyle(color: Colors.red),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.red,
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: const BorderSide(
                            color: Colors.black38,
                            width: 1,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value != null) {
                          if (value == newPassword.text) {
                            return null;
                          } else {
                            return 'Passwords do not match.';
                          }
                        } else {
                          return 'Please Enter Your New Password';
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.pink,
                          strokeWidth: 2,
                        ),
                      )
                    : GenericBShadowButton(
                        buttonText: 'Submit',
                        width: 160,
                        height: 60,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            currentPasswordStatus =
                                await checkCurrentPassword();
                            setState(() {
                              isLoading = true;
                            });
                            print("$currentPasswordStatus the current status");
                            if (currentPasswordStatus) {
                              try {
                                await FirebaseCredentials()
                                    .auth
                                    .currentUser!
                                    .updatePassword(newPassword.text)
                                    .then(
                                  (value) {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    // TODO: SHOW NOTIFICATION
                                    Navigator.pop(context);
                                  },
                                );
                              } catch (e) {
                                print(e);
                              }
                            } else {
                              setState(() {
                                isLoading = false;
                              });
                            }
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/*RoundedLoadingButton(
                  controller: _btnController,
                  onPressed: ()async{
                    if(_formKey.currentState.validate()){
                      currentPasswordStatus = await checkCurrentPassword();
                      setState(() {

                      });
                      if(currentPasswordStatus){
                        try{
                          await FirebaseCredentials().auth.currentUser.updatePassword(newPassword.text);
                          _btnController.success();
                        }catch(e){
                          print(e);
                          _btnController.error();
                        }
                      }
                      else{
                        _btnController.error();
                      }
                    }
                  },
                  width: 160,
                  height: 60,
                  loaderStrokeWidth: 2,
                  elevation: 5,
                  animateOnTap: true,
                  curve: Curves.ease,
                  duration: Duration(seconds: 2),
                  child: Container(
                    height: 60,
                    width: 160,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Colors.red,
                    ),
                    child: Center(
                      child: Text(
                        "Submit",
                        style: TextStyle(color: Colors.white, fontSize: 17),
                      ),
                    ),
                  ),
                )*/
