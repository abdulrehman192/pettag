import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as msg;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:location/location.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pettag/geo_firestore/geo_firestore.dart';
import 'package:pettag/geo_firestore/geo_hash.dart';
import 'package:pettag/main.dart';
import 'package:pettag/models/address.dart' as address;
import 'package:pettag/repo/settingRepo.dart';
import 'package:pettag/screens/permission_disclosure_screen.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/sign_in_screen.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

import '../services/sharedPref.dart';
import 'about_screen.dart';
import 'addNewProfile.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();
}


class SplashScreen extends StatefulWidget {
  static const String splashScreenRoute = 'SplashScreen';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animationLogo;
  double startPos = 1.0;
  double endPos = -1.0;
  Curve curve = Curves.easeInExpo;
  FirebaseAuth auth = FirebaseAuth.instance;

  String interestedIn = '';
  var lat = 0.0;
  var lng = 0.0;

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;

  updateInterest() async {
    await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get()
        .then((value) {
      sharedPrefs.currentUserPetType = value.data()!['interest'];
    });
  }

  checkDoc(id) async {
    var a = await FirebaseFirestore.instance.collection('User').doc(id).get();
    if (a.exists) {
      if (a.data()!['pet'] == null) {
        return false;
      } else {
        return true;
      }
    }
    if (!a.exists) {
      return false;
    }
  }

  location() async {
    await getCurrentLocation().then((address.Address value) async {
      setState(() {});
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

  navigateAndAnimate() {
    _controller.forward();
    Future.delayed(const Duration(seconds: 3)).then((value) =>
        Navigator.pushReplacementNamed(context, AboutScreen.aboutScreenRoute));
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

  void _checkFirstTimeScreen() async {
    bool isSeen = sharedPrefs.isSeen;
    _controller.forward();

    print("IS SEEN ::::::::::::::::::::: $isSeen");

    if (isSeen) {
      if (FirebaseCredentials().auth.currentUser == null) {
        Future.delayed(
            const Duration(seconds: 3),
            () => Navigator.pushReplacementNamed(
                context, SignInScreen.secondScreenRoute));
      } else {
        bool status =
            await checkDoc(FirebaseCredentials().auth.currentUser!.uid);
        if (status) {
          await FirebaseFirestore.instance
              .collection('Pet')
              .where("ownerId",
                  isEqualTo: FirebaseCredentials().auth.currentUser!.uid)
              .get()
              .then((value) {
            if (value.size > 0 && value.docs.isNotEmpty) {
              sharedPrefs.currentUserPetType =
                  value.docs.first.data()["type"] ?? "nan";
            }
          });
          await sendTokenToServer();
          Future.delayed(
              const Duration(seconds: 3),
              () => Navigator.pushReplacementNamed(
                  context, PetSlideScreen.petSlideScreenRouteName));
        } else {
          User? firebaseUser = FirebaseCredentials().auth.currentUser;
          final permissionStatus = await Permission.location.status;
          if(permissionStatus.toString() != LocationManager.PermissionStatus.granted.toString()) {
            Navigator.pushNamed(context, PermissionDisclosureScreen.permissionDisclosureRoute).then((value) async{
              if(value != null) {
                final center = await getUserLocation();
                List<String> names = firebaseUser!.displayName!.split(" ");
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
                }, SetOptions(merge: true)).then((ref) async {
                  GeoFirestore geoFirestore =
                  GeoFirestore(FirebaseCredentials().db.collection('User'));
                  geoFirestore
                      .setLocation(firebaseUser.uid,
                      GeoPoint(center.latitude, center.longitude))
                      .catchError((onError) {
                    print("apple login error ${onError.toString()}");
                  });
                  Navigator.pushReplacementNamed(
                      context, AddNewProfileScreen.addNewProfileScreenRoute);
                });
              } else {
                Navigator.pop(context);
              }
            });
          }


        }
      }
    } else {
      Future.delayed(const Duration(seconds: 3),
          () => Navigator.pushNamed(context, AboutScreen.aboutScreenRoute));
    }
  }

  Future<void> onSelectNotification(NotificationResponse? payload) async {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
       return Scaffold(body: Container());
    }));
  }

  showNotification(RemoteMessage map) async {
    var android = const AndroidNotificationDetails(
      'PT',
      'pettag ',
      channelDescription: 'One to One Chat Notifications',
      priority: msg.Priority.high,
      importance: Importance.max,
    );
    var iOS = const DarwinNotificationDetails();
    var platform = NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, map.notification!.title, map.notification!.body, platform,
        payload: '');
  }

  pushNotificationSettings()
  {
    SharedPrefs().pushNotificationNewMatches = true;
    SharedPrefs().pushNotificationNewMessages = true;
    SharedPrefs().pushNotificationNewTreat = true;
    SharedPrefs().pushNotificationNewSuperTreat = true;
    SharedPrefs().pushNotificationNewTopPick = true;
    SharedPrefs().pushNotificationNewPetWall = true;
  }
  @override
  void initState() {
    super.initState();
    pushNotificationSettings();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 3000));
    _animationLogo = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    //updateInterest();

    var initializationSettingsAndroid =
        const AndroidInitializationSettings('ic_launcher');

    var initializationSettingsIOs = const DarwinInitializationSettings();

    var initSettings = InitializationSettings(
        android: initializationSettingsAndroid, iOS: initializationSettingsIOs);

    flutterLocalNotificationsPlugin.initialize(initSettings,
        onDidReceiveNotificationResponse: onSelectNotification);

    firebaseMessaging.requestPermission(sound: true, badge: true, alert: true);
    FirebaseMessaging.onMessage.listen((event) {
      showNotification(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      showNotification(event);
    });

WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
  if (!kIsWeb && Platform.isIOS) {
    WidgetsBinding.instance.addPostFrameCallback((_) => initPlugin());
  } else {
    final permissionStatus = await Permission.location.status;
    debugPrint('---> ${permissionStatus.toString()}');
    debugPrint('---> ${LocationManager.PermissionStatus.granted}');


    if(permissionStatus.toString() != LocationManager.PermissionStatus.granted.toString()) {
      Navigator.pushNamed(context, PermissionDisclosureScreen.permissionDisclosureRoute).then((value){
        setCurrentLocation().then((value) {
          _checkFirstTimeScreen();
        }).catchError((onError) {
          _checkFirstTimeScreen();
        });
      });
    } else {
      setCurrentLocation().then((value) {
        _checkFirstTimeScreen();
      }).catchError((onError) {
        _checkFirstTimeScreen();
      });
    }
  }
});
  }

  Future<void> initPlugin() async {
    try {
      final TrackingStatus status =
          await AppTrackingTransparency.trackingAuthorizationStatus;
      print("tracking status $status");
      if (status == TrackingStatus.notDetermined) {
        if (await showCustomTrackingDialog(context)) {
          await Future.delayed(const Duration(milliseconds: 200));
          await AppTrackingTransparency.requestTrackingAuthorization()
              .then((value) {
            if (value == TrackingStatus.authorized) {
              setCurrentLocation().then((value) {
                _checkFirstTimeScreen();
              }).catchError((onError) {
                _checkFirstTimeScreen();
              });
            }
          });
        } else {
          setCurrentLocation().then((value) {
            _checkFirstTimeScreen();
          }).catchError((onError) {
            _checkFirstTimeScreen();
          });
        }
      } else if (status == TrackingStatus.denied ||
          status == TrackingStatus.restricted) {
        bool res = await showCupertinoDialog(
            context: context,
            builder: (context) => AlertDialog(
                  title: const Text('Dear User'),
                  content: const Text(
                    'Please turn on the app tracking service from settings.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text("Dismiss"),
                    ),
                  ],
                ));
        if (res) {
          setCurrentLocation().then((value) {
            _checkFirstTimeScreen();
          }).catchError((onError) {
            _checkFirstTimeScreen();
          });
        }
      } else {
        setCurrentLocation().then((value) {
          _checkFirstTimeScreen();
        }).catchError((onError) {
          _checkFirstTimeScreen();
        });
      }
    } on PlatformException {}

    // final uuid = await AppTrackingTransparency.getAdvertisingIdentifier();
  }

  Future<bool> showCustomTrackingDialog(BuildContext context) async =>
      await showCupertinoDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Dear User'),
          content: const Text(
            'We care about your privacy and data security. we use your device location for finding nearby pets and parks also show your personalization ads.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("I'll decide later"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Allow tracking'),
            ),
          ],
        ),
      ) ??
      false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
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
            Positioned(
              top: 100,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _animationLogo,
                child: Column(
                  children: [
                    Image.asset(
                      "assets/3x/Group 378@3x.png",
                      height: 120,
                      width: 120,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Text(
                      "PetTag",
                      style: TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                builder: (context, child) {
                  return Container(
                    child: Opacity(
                      opacity: _animationLogo.value,
                      child: child,
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 30,
              right: 200,
              bottom: 120,
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(
                    begin: const Offset(-1, 0), end: const Offset(0, 0)),
                duration: const Duration(milliseconds: 1500),
                curve: curve,
                builder: (context, offset, child) {
                  return FractionalTranslation(
                    translation: offset as Offset,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/catAnim.png",
                  height: 150,
                  width: 150,
                ),
              ),
            ),
            Positioned(
              left: 200,
              right: 30,
              bottom: 120,
              child: TweenAnimationBuilder(
                tween: Tween<Offset>(
                    begin: const Offset(1, 0), end: const Offset(0, 0)),
                duration: const Duration(milliseconds: 1500),
                curve: curve,
                builder: (context, offset, child) {
                  return FractionalTranslation(
                    translation: offset as Offset,
                    child: SizedBox(
                      width: double.infinity,
                      child: Center(
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  "assets/dogAnim.png",
                  height: 150,
                  width: 150,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
