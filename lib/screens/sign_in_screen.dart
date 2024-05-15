import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:pettag/constant.dart';
import 'package:pettag/geo_firestore/geo_firestore.dart';
import 'package:pettag/geo_firestore/geo_hash.dart';
import 'package:pettag/main.dart';
import 'package:pettag/screens/addNewProfile.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/register_screen.dart';
import 'package:pettag/services/sharedPref.dart';
import 'package:pettag/utilities/email_validation/email_validator.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/newUserWidget.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'passwordReset.dart';

class SignInScreen extends StatefulWidget {
  static const String secondScreenRoute = 'SignInScreen';

  const SignInScreen({Key? key}) : super(key: key);

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  IconData _visibility = Icons.visibility;
  bool obscure = true;
  String interestedIn = '';

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();

  final GoogleSignIn googleSignIn = GoogleSignIn();

  final fb = FacebookAuth.instance;
  bool isLoading = false;
  var lat = 0.0;
  var lng = 0.0;
  var center;

  ValidateEmail emailValidator = ValidateEmail();

  final _formKey = GlobalKey<FormState>();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    checkConnection();
  }

  sendTokenToServer() async {
    await firebaseMessaging.getToken().then((value) {
      FirebaseCredentials()
          .db
          .collection('token')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'token': value,
      }, SetOptions(merge: true));
    });
  }

  Future<LatLng?> getUserLocation() async {
    final location = LocationManager.Location();
    LocationManager.LocationData? locationData;
    try {
      locationData = await location.getLocation();
      lat = locationData.latitude!;
      lng = locationData.longitude!;
      final center = LatLng(lat, lng);
      return center;
    } on Exception {
      locationData = null;
      return null;
    }
  }

  checkConnection() async {
    try {
      await InternetAddress.lookup("google.com");
    } on SocketException {
      Fluttertoast.showToast(
          msg: "Check Your Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.white,
          textColor: Colors.black,
          fontSize: 16.0);
    }
  }

  checkDoc(id) async {
    var a = await FirebaseFirestore.instance.collection('User').doc(id).get();
    if (a.exists) {
      if (a.data()!['pet'] == null) {
        return false;
      } else {
        return true;
      }
    } else {
      return false;
    }
  }

  uploadFirebase(User firebaseUser,
      [GoogleSignInAccount? googleSignInAccount,
      FacebookAuth? fb,
      AuthorizationCredentialAppleID? appleID]) async {
    bool status = await checkDoc(firebaseUser.uid);
    if (status) {
      // await sendTokenToServer();
      await FirebaseFirestore.instance
          .collection('Pet')
          .where("ownerId", isEqualTo: firebaseUser.uid)
          .get()
          .then((value) {
        sharedPrefs.currentUserPetType = value.docs[0].data()["type"] ?? '-';
      });
      Navigator.pushReplacementNamed(
          context, PetSlideScreen.petSlideScreenRouteName);
    } else {
      List<String> names = ['', ''];
      if (googleSignInAccount != null) {
        firebaseUser.updateDisplayName(googleSignInAccount.displayName);
        firebaseUser.updateEmail(googleSignInAccount.email);
        firebaseUser.updatePhotoURL(googleSignInAccount.photoUrl);
        names = googleSignInAccount.displayName!.split(" ");
      }
      if (fb != null) {
        var data = await fb.getUserData();
        var name = data['name'];
        var email =  data['email'];
        var photo = data['picture'];
        var d = photo['data'];
        var profileUrl = d['url'];
        firebaseUser.updateDisplayName(name!.name);
        if (email != null) firebaseUser.updateEmail(email);
        firebaseUser.updatePhotoURL(profileUrl);
        names = [name.firstName!, name.lastName!];
      }
      if (appleID != null) {
        firebaseUser
            .updateDisplayName("${appleID.givenName} ${appleID.familyName}");
        firebaseUser.updateEmail(appleID.email!);
        names = [appleID.givenName!, appleID.familyName!];
      }
      if (googleSignInAccount == null && fb == null && appleID == null) {
        names = firebaseUser.displayName!.split(" ");
      }
      final center = await getUserLocation();
      interestedIn = sharedPrefs.petType;
      await FirebaseCredentials()
          .db
          .collection('User')
          .doc(firebaseUser.uid)
          .set({
        'id': firebaseUser.uid,
        'firstName': names[0],
        'lastName': names[1],
        'email': firebaseUser.email,
        'visible': true,
        'age': 0,
        'description': null,
        'interest': interestedIn,
        'latitude': center!.latitude,
        'longitude': center.longitude,
        'geoHash': GeoHash.encode(center.latitude, center.longitude),
        'pet': null,
        'images': [],
        'createdAt': Timestamp.now()
      }, SetOptions(merge: true)).then((ref) async {
        GeoFirestore geoFirestore =
            GeoFirestore(FirebaseCredentials().db.collection('User'));
        geoFirestore.setLocation(
            firebaseUser.uid, GeoPoint(center.latitude, center.longitude));
        // await sendTokenToServer();
        Navigator.pushReplacementNamed(
            context, AddNewProfileScreen.addNewProfileScreenRoute);
      });
    }
  }

  signinWithGoogle() async {
    SharedPrefs().treatCounter = 25;
    SharedPrefs().superTreatCounter = 1;
    final GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
    try {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );
      User? firebaseUser =
          (await FirebaseAuth.instance.signInWithCredential(credential)).user;
      if (firebaseUser != null) {
        uploadFirebase(firebaseUser, googleSignInAccount, null, null);
      }
      setState(() {
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        isLoading = false;
      });
    }
  }

  loginFacebook() async {
    SharedPrefs().treatCounter = 25;
    SharedPrefs().superTreatCounter = 1;
    print('Starting Facebook Login');
    final res = await fb.login(permissions: [
      'public_profile',
      'email',
    ]);
    switch (res.status) {
      case LoginStatus.success:
        final AccessToken? fbToken = res.accessToken;
        final AuthCredential credential =
            FacebookAuthProvider.credential(fbToken!.token);
        User? firebaseUser =
            (await FirebaseAuth.instance.signInWithCredential(credential)).user;
        if (firebaseUser != null) {
          uploadFirebase(firebaseUser, null, fb, null);
        }
        setState(() {
          isLoading = false;
        });
        break;
      case LoginStatus.cancelled:
        print('The user canceled the login');
        setState(() {
          isLoading = false;
        });
        break;
      case LoginStatus.failed:
        print('There was an error');
        setState(() {
          isLoading = false;
        });
        break;
      case LoginStatus.operationInProgress:
        // TODO: Handle this case.
    }
  }

  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> signInWithApple() async {
    SharedPrefs().treatCounter = 25;
    SharedPrefs().superTreatCounter = 1;
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );
    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );
    await FirebaseAuth.instance
        .signInWithCredential(oauthCredential)
        .then((val) async {
      User? firebaseUser = val.user;
      if (firebaseUser != null) {
        uploadFirebase(firebaseUser, null, null, appleCredential);
      }
      setState(() {
        isLoading = false;
      });
    }).catchError((e) {
      print(e is SocketException
          ? "Check your internet connection"
          : e.toString());
      setState(() {
        isLoading = false;
      });
    });
  }

  SizedBox buildImageButtons(BuildContext context, isVisible, imagePath, text) {
    return SizedBox(
      height: 100,
      width: 70,
      child: Column(
        children: [
          Stack(
            children: [
              Visibility(
                visible: isVisible,
                child: Container(
                  height: 80,
                  width: MediaQuery.of(context).size.width / 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(0),
                    border: Border.all(
                      color: Colors.pink[900]!,
                      width: 2,
                    ),
                  ),
                ),
              ),
              Center(
                child: Image.asset(
                  imagePath,
                  height: 70,
                ),
              )
            ],
          ),
          Text(
            text,
            style:
                TextStyle(color: Colors.pink[900], fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Stack(
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
                  SingleChildScrollView(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(
                            width: currentMediaWidth(context),
                            height: currentMediaHeight(context),
                            child: Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.only(top: 30),
                                    width: currentMediaWidth(context),
                                    height: MediaQuery.of(context).size.height /
                                        2.5,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          height: 70,
                                          child: Image.asset(
                                            'assets/2x/Group 378@2x.png',
                                          ),
                                        ),
                                        SizedBox(height: 30),
                                        LocaleText(
                                          'connect',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withOpacity(0.7)),
                                        ),
                                        SizedBox(height: 15),
                                        Flexible(
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              if (!kIsWeb && Platform.isIOS)
                                                GestureDetector(
                                                  onTap: () async {
                                                    //await _handleLogin();
                                                    setState(() {
                                                      isLoading = true;
                                                    });
                                                    /*await showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return SignInDialog();
                                                          })
                                                      .then((value) =>
                                                          interestedIn = value);*/
                                                    //loginFacebook();
                                                    signInWithApple();
                                                  },
                                                  child: getHomeScreenImage(
                                                      'assets/2x/apple.png',
                                                      circleRadius: 70,
                                                      imageWidth: 35,
                                                      imageHeight: 35,
                                                      circleSize: 24,
                                                      color: Colors.white,
                                                      isFullOpacity: false),
                                                ),
                                              SizedBox(width: 10),
                                              GestureDetector(
                                                onTap: () async {
                                                  //await _handleLogin();
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  /*await showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return SignInDialog();
                                                          })
                                                      .then((value) =>
                                                          interestedIn = value);*/
                                                  loginFacebook();
                                                },
                                                child: getHomeScreenImage(
                                                    'assets/2x/Group 246@2x.png',
                                                    circleRadius: 70,
                                                    imageWidth: 47,
                                                    imageHeight: 47,
                                                    circleSize: 25,
                                                    isFullOpacity: true),
                                              ),
                                              SizedBox(width: 10),
                                              InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    isLoading = true;
                                                  });
                                                  signinWithGoogle();
                                                },
                                                child: getHomeScreenImage(
                                                    'assets/googleIcon.png',
                                                    circleRadius: 70,
                                                    imageWidth: 47,
                                                    imageHeight: 47,
                                                    circleSize: 25,
                                                    isFullOpacity: true),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 15),
                                        // showing heart image
                                        getHomeScreenImage(
                                          'assets/2x/Group 249@2x.png',
                                          isFullOpacity: true,
                                          circleSize: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width / 1.3,
                                    child: Column(
                                      children: [
                                        TextFormField(
                                          controller: email,
                                          validator: (value) {
                                            if (emailValidator
                                                .validateEmail(value!)) {
                                              return null;
                                            } else {
                                              return 'Wrong Email';
                                            }
                                          },
                                          textAlign: TextAlign.center,
                                          textInputAction: TextInputAction.next,
                                          obscureText: false,
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            hintText: Locales.string(
                                                context, 'email'),
                                            filled: true,
                                            contentPadding:
                                                const EdgeInsets.all(8.0),
                                            hintStyle: hintTextStyle,
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
                                            focusedErrorBorder:
                                                OutlineInputBorder(
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
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextFormField(
                                          controller: password,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Password is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          textAlign: TextAlign.center,
                                          textInputAction: TextInputAction.next,
                                          obscureText:
                                              _visibility == Icons.visibility
                                                  ? true
                                                  : false,
                                          decoration: InputDecoration(
                                            suffixIcon: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  _visibility = _visibility ==
                                                          Icons.visibility_off
                                                      ? Icons.visibility
                                                      : Icons.visibility_off;
                                                });
                                              },
                                              child: Icon(
                                                _visibility,
                                                color: Colors.black,
                                              ),
                                            ),
                                            fillColor: Colors.white,
                                            hintText: Locales.string(
                                                context, 'password'),
                                            filled: true,
                                            contentPadding:
                                                const EdgeInsets.only(
                                                    left: 55,
                                                    right: 8,
                                                    top: 8,
                                                    bottom: 8),
                                            hintStyle: hintTextStyle,
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
                                            focusedErrorBorder:
                                                OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.redAccent,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(30),
                                              borderSide: const BorderSide(
                                                color: Colors.transparent,
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
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return PasswordReset(
                                                message:
                                                    "An email has just been sent to you, Click the link provided to complete password reset",
                                              );
                                            }));
                                          },
                                          child: const LocaleText(
                                            "forget_password",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                color: Colors.black87,
                                                fontSize: 12),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        GenericBShadowButton(
                                          buttonText: Locales.string(
                                              context, 'sign_in'),
                                          onPressed: () async {
                                            SharedPrefs().treatCounter = 25;
                                            SharedPrefs().superTreatCounter = 1;
                                            if (_formKey.currentState!
                                                .validate()) {
                                              setState(() {
                                                isLoading = true;
                                              });
                                              try {
                                                UserCredential userCredential =
                                                    await FirebaseAuth.instance
                                                        .signInWithEmailAndPassword(
                                                            email: email.text,
                                                            password:
                                                                password.text);
                                                User? firebaseUser =
                                                    userCredential.user;
                                                uploadFirebase(firebaseUser!,
                                                    null, null, null);
                                              } catch (e) {
                                                setState(() {
                                                  isLoading = false;
                                                });
                                                final snackbar = SnackBar(
                                                  content: Text('${e}'),
                                                );
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(snackbar);
                                                if (e.toString().contains('user-not-found')) {
                                                  print(
                                                      'No user found for that email.');
                                                } else if (e.toString().contains('wrong-password')) {
                                                  print(
                                                      'Wrong password provided for that user.');
                                                }
                                              }
                                            }
                                          },
                                        ),
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        NewUserTextWidget(
                                          onTap: () {
                                            Navigator.pushReplacementNamed(
                                                context,
                                                RegisterScreen
                                                    .registerScreenRoute);
                                          },
                                          userType:
                                              "${Locales.string(context, 'new_user')} ? ",
                                          action: Locales.string(
                                              context, 'sign_up'),
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
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (_) => BackdropFilter(
                                  filter: ImageFilter.blur(
                                      sigmaX: 105, sigmaY: 105),
                                  child: AlertDialog(
                                    backgroundColor:
                                        Colors.white.withOpacity(0.5),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20.0))),
                                    title: const LocaleText('language'),
                                    content: Builder(
                                      builder: (context) {
                                        var height =
                                            MediaQuery.of(context).size.height;
                                        var width =
                                            MediaQuery.of(context).size.width;

                                        return SizedBox(
                                          height: height - 500,
                                          width: width - 300,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children: [
                                              Card(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    onTap: () {
                                                      LocaleNotifier.of(context)!
                                                          .change('en');
                                                    },
                                                    leading: Image.asset(
                                                      "assets/uk.png",
                                                      height: 55,
                                                      width: 55,
                                                    ),
                                                    title: const LocaleText(
                                                      'english',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    onTap: () {
                                                      LocaleNotifier.of(context)!
                                                          .change('es');
                                                    },
                                                    leading: Image.asset(
                                                      "assets/spain.png",
                                                      height: 55,
                                                      width: 55,
                                                    ),
                                                    title: const LocaleText(
                                                      'spanish',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    onTap: () {
                                                      LocaleNotifier.of(context)!
                                                          .change('hi');
                                                    },
                                                    leading: Image.asset(
                                                      "assets/india.png",
                                                      height: 55,
                                                      width: 55,
                                                    ),
                                                    title: const LocaleText(
                                                      'hindi',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    onTap: () {
                                                      LocaleNotifier.of(context)!
                                                          .change('zh');
                                                    },
                                                    leading: Image.asset(
                                                      "assets/china.png",
                                                      height: 55,
                                                      width: 55,
                                                    ),
                                                    title: const LocaleText(
                                                      'chinese',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                color: Colors.white
                                                    .withOpacity(0.5),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: ListTile(
                                                    onTap: () async {
                                                      LocaleNotifier.of(context)!
                                                          .change('pt');
                                                    },
                                                    leading: Image.asset(
                                                      "assets/portugal.png",
                                                      height: 55,
                                                      width: 55,
                                                    ),
                                                    title: const LocaleText(
                                                      'portuguese',
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ));
                      },
                      child: Align(
                        alignment: Alignment.topRight,
                        child: Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(15)),
                          child: const Padding(
                            padding: EdgeInsets.only(
                                right: 22, left: 22, top: 10, bottom: 10),
                            child: LocaleText(
                              "language",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Visibility(
                visible: isLoading,
                child: Container(
                  height: 100,
                  width: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.red,
                      strokeWidth: 2,
                    ),
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

/*Dialog(
                                                      child: Container(
                                                        height: 330,
                                                        width: 200,
                                                        padding:
                                                            EdgeInsets.all(8),
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            Text(
                                                              "Interested In",
                                                              style: TextStyle(
                                                                  fontSize: 17,
                                                                  color: Colors
                                                                          .pink[
                                                                      900],
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            SizedBox(
                                                              height: 5,
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceEvenly,
                                                              children: [
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isVisibleCat =
                                                                          true;
                                                                      _isVisibleDog =
                                                                          false;
                                                                      interestedIn =
                                                                          'Cat';
                                                                    });
                                                                  },
                                                                  child: buildImageButtons(
                                                                      context,
                                                                      _isVisibleCat,
                                                                      'assets/newimg.png',
                                                                      "Cat"),
                                                                ),
                                                                GestureDetector(
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _isVisibleDog =
                                                                          true;
                                                                      _isVisibleCat =
                                                                          false;
                                                                      interestedIn =
                                                                          'Dog';
                                                                    });
                                                                  },
                                                                  child: buildImageButtons(
                                                                      context,
                                                                      _isVisibleDog,
                                                                      'assets/dogArt.png',
                                                                      "Dog"),
                                                                ),
                                                              ],
                                                            ),
                                                            /*TextField(
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            50),
                                                                hintText:
                                                                    "Enter Your Email-id",
                                                                hintStyle: TextStyle(
                                                                    color: Colors
                                                                        .black38),
                                                                border:
                                                                    InputBorder
                                                                        .none,
                                                              ),
                                                            ),*/
                                                            GenericBShadowButton(
                                                              buttonText:
                                                                  "Submit",
                                                              onPressed: () {
                                                                (_isVisibleCat ||
                                                                        _isVisibleDog)
                                                                    ? Navigator.pop(
                                                                        context)
                                                                    : null;
                                                              },
                                                            ),
                                                            SizedBox(
                                                              height: 10,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    )*/
