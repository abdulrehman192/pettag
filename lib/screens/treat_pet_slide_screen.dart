import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' show cos, sqrt, asin;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart'
    as localNotification;
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:pettag/constant.dart';
import 'package:pettag/enums/enums.dart';
import 'package:pettag/main.dart';
import 'package:pettag/models/packageDetail.dart';
import 'package:pettag/repo/paymentRepo.dart' as repo;
import 'package:pettag/screens/all_profiles.dart';
import 'package:pettag/screens/pet_chat_screen.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/services/sharedPref.dart';
import 'package:pettag/utilities/tinder_card.dart';
import 'package:pettag/widgets/boostDialog.dart';
import 'package:pettag/widgets/myTreats.dart';
import 'package:pettag/widgets/petDate.dart';
import 'package:pettag/widgets/small_action_buttons.dart';
import 'package:pettag/widgets/topPicks.dart';
import 'package:pettag/widgets/treat.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../addmophelper.dart';
import 'pet_chat_screen.dart';
import 'pet_detail_screen.dart';

class TreatPetSlideScreen extends StatefulWidget {
  static const String petSlideScreenRouteName = 'PetSlideScreen';

  final String? petId;
  TreatPetSlideScreen({Key? key, this.petId}) : super(key: key);

  bool isLeft = true;

  @override
  _TreatPetSlideScreenState createState() => _TreatPetSlideScreenState();
}

class _TreatPetSlideScreenState extends State<TreatPetSlideScreen>
    with TickerProviderStateMixin {
  late CardController controller;
  late PackageDetail package;
  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  int _index = 0;
  double minAge = 0;
  double maxAge = 0;
  int preferableDistance =0;
  String preferableGender = '';
  bool isShuffled = false;
  bool isLeft = false;
  bool isRight = false;
  bool _action = false;
  bool isTop = false;
  double leftPos = 20;
  double rightPos = 20;
  String text = "GRAWL";
  final bool _noCardVisibility = false;
  Color containerColor = Colors.red;
  bool _treat = true;
  bool _topPicks = false;
  bool _petDate = false;
  bool _myTreats = false;
  var subscription;
  var connectionStatus;
  String currentPetId = '';
  String petId = '';
  String _petType = '';
  var lat = 0.0;
  var lng = 0.0;
  double distance = 0.0;
  int endTime = 0;
  bool likesLimit = true;
  String whichPackage = '';
  int superLikeEndTime = 0;
  bool superLikesLimit = true;
  bool lastCard = false;
  bool isOffilne = false;
  String myPetId = '';
  String myPetImage = '';
  String myPetName = '';
  bool isBoosted = false;

  late CountdownTimerController timeController;
  late CountdownTimerController timeControllerDay;
  late CountdownTimerController boostedTimeController;
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  int boostEndTimer = 0;

  localNotification.FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      localNotification.FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // InterstitialAd _interstitialAd;
  final bool _isInterstitialAdReady = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  List<String> cardImages = [
    'assets/dogsAndCats/doggy.png',
    'assets/dogsAndCats/doggy1.jpg',
    'assets/dogsAndCats/doggy1.jpg',
  ];
  List<QueryDocumentSnapshot> profiles = [];

  boostedOnEnd() {
    FirebaseFirestore.instance.collection("Pet").doc(myPetId).update({
      "boosted": false,
    }).whenComplete(() => setState(() {
          //isBoosted = false;
        }));
  }

  Future<bool> getLimit() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('likeCount')
        ? prefs.getInt("likeCount")! < 25
            ? true
            : false
        : true;
  }

  getPrefs() async {}

  getProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("ProfileType")) {
      return prefs.getString("ProfileType");
    } else {
      return "";
    }
  }

/*  void _loadInterstitialAd() {
    InterstitialAd.load();
  }

  void _onInterstitialAdEvent(MobileAdEvent event) {
    switch (event) {
      case MobileAdEvent.loaded:
        _isInterstitialAdReady = true;
        print('AA Load an interstitial ad');
        break;
      case MobileAdEvent.failedToLoad:
        _isInterstitialAdReady = false;
        print('AA Failed to load an interstitial ad');
        break;
      case MobileAdEvent.closed:
        print('AA Closed an interstitial ad');
        FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
        _interstitialAd = InterstitialAd(
          adUnitId: */ /*AdManager.interstitialAdUnitId*/ /* InterstitialAd
              .testAdUnitId,
          listener: _onInterstitialAdEvent,
        );
        _loadInterstitialAd();
        break;
      default:
      // do nothing
    }
  }*/

  showNotification(RemoteMessage map) async {
    var android = const localNotification.AndroidNotificationDetails(
      'PT',
      'pettag ',
      channelDescription: 'You Have a PetDate',
      priority: localNotification.Priority.high,
      importance: localNotification.Importance.max,
    );
    var iOS = const localNotification.DarwinNotificationDetails();
    var platform =
        localNotification.NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
        0, map.notification!.title, map.notification!.title, platform,
        payload: '');
  }

  callOnFcmApiSendPushNotifications(userToken) async {
    const postUrl = 'https://fcm.googleapis.com/fcm/send';

    final data = {
      "notification": {"body": "You have a new PetDate.", "title": "PetDate"},
      "priority": "high",
      "data": {"click_action": "FLUTTER_NOTIFICATION_CLICK", "status": "done"},
      "to": "$userToken"
    };

    final headers = {
      'content-type': 'application/json',
      'Authorization':
          'key=AAAAiTi4Ky4:APA91bHOEj1tSQUQC2Op27Z1Fdwh4j6FwmT1IlvvGRp99SFU1oX6wAbo20lyZ4Q9HpJ2wnLiBuN20luSYlQO-0IwyzI3a5qm3q4YVebwB3xmAdCuEb0K8c371Ishr_dr3n8Q9b709pbA'
      // 'key=YOUR_SERVER_KEY'
    };

    try {
      final response = await post(Uri.parse(postUrl),
          body: json.encode(data),
          encoding: Encoding.getByName('utf-8'),
          headers: headers);

      if (response.statusCode == 200) {
        print('CFM Succeed');
        return true;
      } else {
        print(response.body);
        return false;
      }
    } catch (e) {
      print(e);
    }
  }

  updateInteraction({status, petId, petImage, petName}) {
    if (status == 1) {
      DocumentReference doc =
          FirebaseFirestore.instance.collection('Pet').doc(currentPetId);
      doc.set({
        auth.currentUser!.uid: status,
        'likedBy': FieldValue.arrayUnion([
          {
            'user_id': auth.currentUser!.uid,
            'petId': myPetId,
            "petImage": myPetImage,
            "petName": myPetName
          }
        ])
      }, SetOptions(merge: true)).then((value) async {
        List<String> userIds = [];
        await doc.get().then((value) {
          (value.data() as Map<String, dynamic>)["likedBy"].forEach((element) {
            userIds.add(element["user_id"]);
          });
        });
        print("UserIds : $userIds");
        List<DocumentSnapshot> snapshots = [];
        for (int i = 0; i < userIds.length; i++) {
          await FirebaseFirestore.instance
              .collection("token")
              .doc(userIds[i])
              .get()
              .then((value) {
            if (value.exists) {
              callOnFcmApiSendPushNotifications(value.data()!["token"]);
              snapshots.add(value);
            }
            print("Shit Id : ${value.id}");
          });
        }
        print("Length de snaps : ${snapshots.length}");
      });
      FirebaseFirestore.instance.collection('Pet').doc(petId).set({
        'likes': FieldValue.arrayUnion([currentPetId])
      }, SetOptions(merge: true));
    } else if (status == 2) {
      FirebaseFirestore.instance.collection('Pet').doc(currentPetId).set({
        auth.currentUser!.uid: status,
        'superLikedBy': FieldValue.arrayUnion([
          {
            'user_id': auth.currentUser!.uid,
            'petId': myPetId,
            "petImage": myPetImage,
            "petName": myPetName
          }
        ])
      }, SetOptions(merge: true));
      FirebaseFirestore.instance.collection('Pet').doc(petId).set({
        'likes': FieldValue.arrayUnion([currentPetId])
      }, SetOptions(merge: true));
    } else {
      FirebaseFirestore.instance.collection('Pet').doc(currentPetId).set({
        auth.currentUser!.uid: status,
      }, SetOptions(merge: true));
    }
  }

  updateDummyInteraction({status}) {
    FirebaseFirestore.instance
        .collection('Pet')
        .doc(currentPetId)
        .set({auth.currentUser!.uid: status}, SetOptions(merge: true));
  }

  getPreferableAge() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    minAge = prefs.getDouble('minAge') ?? 1;
    maxAge = prefs.getDouble('maxAge') ?? 30;
    print("Min : $minAge ---- Max : $maxAge");
  }

  getPreferableDistance() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    preferableDistance = prefs.getInt('radius') ?? 20;
    print("Distance : $preferableDistance");
  }

  getPreferableGender() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    preferableGender = prefs.getString('preferredGender') ?? 'Male';
    print("Gender : $preferableGender");
  }

  getPetType() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty) {
        print("Interest : ${data['interest']}");
        _petType = data['interest'];
        print("PetType : $_petType");
      }
    }
  }

  getLatLng() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    lat = data['latitude'];
    lng = data['longitude'];
  }

  setTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        "likesTime", DateTime.now().millisecondsSinceEpoch + 1000 * 28800);
  }

  setSuperLikeTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(
        "superLikesTime", DateTime.now().millisecondsSinceEpoch + 1000 * 86400);
  }

  Future<int?> getSuperLikeTimer() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey("superLikesTime")) {
      return prefs.getInt("superLikesTime");
    } else {
      await setSuperLikeTime();
      return prefs.getInt("superLikesTime");
    }
  }

  Future<int?> getTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('likesTime')) {
      return prefs.getInt("likesTime");
    } else {
      await setTime();
      return prefs.getInt("likesTime");
    }
  }

  Future<bool> superLikeCounter(counter) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('superLikesCount')) {
      if (prefs.getInt('superLikesCount') == counter) {
        print("SuperLikes Counter is greater than 1");
        return false;
      } else {
        prefs.setInt('superLikesCount', prefs.getInt('superLikesCount')! + 1);
        return true;
      }
    } else {
      prefs.setInt("superLikesCount", 1);
      return true;
    }
  }

  Future<bool> likeCounter() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('likeCount')) {
      if (prefs.getInt('likeCount')! >= 25) {
        print("Likes Counter is greater than 2");
        return false;
      } else {
        prefs.setInt('likeCount', prefs.getInt('likeCount')! + 1);
        return true;
      }
    } else {
      prefs.setInt("likeCount", 1);
      return true;
    }
  }

  void onEnd() async {
    await setTime();
    await getTime().then((value) async {
      endTime = value!;
      print("WTF IS HAPPENING");
      timeController.endTime = endTime;
      timeController.start();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('likeCount')) {
        prefs.remove('likeCount');
      }
      setState(() {
        likesLimit = true;
      });
    });
  }

  onEndSuperLike() async {
    await setSuperLikeTime();
    await getSuperLikeTimer().then((value) async {
      superLikeEndTime = value!;
      print("WTF IS HAPPENING HERE");
      timeControllerDay.endTime = superLikeEndTime;
      timeControllerDay.start();
      SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('superLikesCount')) {
        prefs.remove('superLikesCount');
      }
      setState(() {
        superLikesLimit = true;
      });
    });
  }

  Packages packages = Packages.STANDARD;

  void setPackageName(Packages packages) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("packageName", packages.name!);
  }

  Future<Packages> getPackageName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Packages packages = Packages.STANDARD;
    if (prefs.containsKey("packageName")) {
      for (var element in Packages.values) {
        if (element.name == prefs.getString("packageName")) {
          packages = element;
          return element;
        }
      }
    } else {
      setPackageName(Packages.STANDARD);
      return Packages.STANDARD;
    }
    return packages;
  }

  Future<void> initPlatformState() async {
    //appData.isPro = false;

    // await Purchases.setDebugLogsEnabled(true);
    // await Purchases.setup("gzgzAsBNGojGMkJBZyMcDnSsxiwbbAkF",
    //     appUserId: auth.currentUser!.uid);
    //
    // PurchaserInfo purchaserInfo;
    // try {
    //   purchaserInfo = await Purchases.getPurchaserInfo();
    //   print(purchaserInfo.toString());
    //   if (purchaserInfo.entitlements.all['pettagplus'] != null &&
    //       purchaserInfo.entitlements.all['pettagplus']!.isActive) {
    //     appData.isPro = purchaserInfo.entitlements.all['pettagplus']!.isActive;
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setString("packageName", "pettagPLUS");
    //   } else if (purchaserInfo.entitlements.all['breeder'] != null &&
    //       purchaserInfo.entitlements.all['breeder']!.isActive) {
    //     appData.isPro = purchaserInfo.entitlements.all['breeder']!.isActive;
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setString("packageName", "BREEDER");
    //   } else if (purchaserInfo.entitlements.all['rescuer'] != null &&
    //       purchaserInfo.entitlements.all['rescuer']!.isActive) {
    //     appData.isPro = purchaserInfo.entitlements.all['rescuer']!.isActive;
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setString("packageName", "RESCUER");
    //   } else {
    //     appData.isPro = false;
    //     SharedPreferences prefs = await SharedPreferences.getInstance();
    //     prefs.setString("packageName", "STANDARD");
    //   }
    // } on Platform catch (e) {
    //   print(e);
    // }
    print('#### is user pro? ${appData.isPro}');
  }

  getPetId() async {
    await FirebaseFirestore.instance
        .collection("Pet")
        .where("ownerId", isEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      myPetId = value.docs[0].data()['petId'];
      FirebaseFirestore.instance
          .collection('Pet')
          .doc(myPetId)
          .get()
          .then((value) {
        myPetImage = value.data()!["images"][0];
        myPetName = value.data()!["name"];
        boostEndTimer = DateTime.now().millisecondsSinceEpoch + 1000 * 60;
      });
      isOffline();
    });
  }

  isOffline() async {
    await FirebaseFirestore.instance
        .collection("Pet")
        .doc(myPetId)
        .get()
        .then((value) {
      setState(() {
        isOffilne = value.data()!['visible'];
      });
    });
  }

  late StreamSubscription iosSubscription;
  // AdMobHelper admobHelper = new AdMobHelper();

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initDynamicLinks();
    FirebaseMessaging.onMessage.listen((event) {
      showNotification(event);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((event) {
      showNotification(event);
    });
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await getSuperLikeTimer().then((value) async {
        superLikeEndTime = value!;
        if (DateTime.now().millisecondsSinceEpoch * 1000 > superLikeEndTime) {
          if (prefs.containsKey('superLikesTime')) {
            prefs.remove('superLikesTime');
          }
          await setSuperLikeTime();
          await getSuperLikeTimer().then((value) {
            superLikeEndTime = value!;
          });
        }
        timeControllerDay = CountdownTimerController(
            endTime: superLikeEndTime, onEnd: onEndSuperLike);
      });
      getPackageName().then((value) async {
        if (value.getPackage is StandardPackagesModel) {
          await getTime().then((value) async {
            endTime = value!;
            if (DateTime.now().millisecondsSinceEpoch * 1000 > endTime) {
              if (prefs.containsKey('likeCount')) {
                prefs.remove('likeCount');
              }
              await setTime();
              await getTime().then((value) {
                endTime = value!;
              });
            }
            timeController =
                CountdownTimerController(endTime: endTime, onEnd: onEnd);
          });
          /* FirebaseAdMob.instance.initialize(appId: FirebaseAdMob.testAppId);
          _interstitialAd = InterstitialAd(
            adUnitId: InterstitialAd.testAdUnitId,
            listener: _onInterstitialAdEvent,
          );
          _loadInterstitialAd();*/
          whichPackage = 'STANDARD';
        } else if (value.getPackage is pettagPlusPackagesModel) {
          setState(() {
            whichPackage = 'pettagPLUS';
          });
        } else if (value.getPackage is BreederPackagesModel) {
          setState(() {
            whichPackage = 'BREEDER';
          });
        } else if (value.getPackage is RescuerPackagesModel) {
          setState(() {
            whichPackage = 'RESCUER';
          });
        }
      });
    });
    getPetId();
    getPetType();
    getPreferableAge();
    getPreferableDistance();
    getPreferableGender();
    if (mounted) {
      getPackage();
    }
    checkConnectivity();
    getLatLng();
    AdMobHelper.createInterAdd();
  }

  getData() async {
    return await FirebaseFirestore.instance
        .collection('Pet')
        .where('interaction', whereIn: [auth.currentUser!.uid])
        .snapshots()
        .isEmpty;
  }

  fetchData() {
    if (getData() == null || !getData()) {
      return FirebaseFirestore.instance.collection('Pet').snapshots();
    } else {
      FirebaseFirestore.instance
          .collection('Pet')
          .where('interaction', whereNotIn: [auth.currentUser!.uid]).snapshots();
    }
  }

  Future<bool> checkConnectivity() async {
    var connected = false;
    try {
      final googleLookup = await InternetAddress.lookup('google.com');
      if (googleLookup.isNotEmpty && googleLookup[0].rawAddress.isNotEmpty) {
        connected = true;
      } else {
        connected = false;
      }
    } on SocketException {
      connected = false;
      Fluttertoast.showToast(
          msg: "Check Your Internet Connection",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 3,
          backgroundColor: Colors.pink,
          textColor: Colors.black,
          fontSize: 16.0);
    }
    return connected;
  }

  getPackage() async {
    await repo.getPkgInfo().then((value) => setState(() {
          package = value;
        }));
  }

  calculateDistance(lat1, lon1, lat2, lon2) {
    /*Geolocator geo = Geolocator();
    distance =  await geo.distanceBetween(lat2, lon2,
        lat1, lon1);*/
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  var rightColors;
  var leftColors;
  var leftIconColor;
  var rightIconColor;

  Future<List<DocumentSnapshot>> getDocs() async {
    QuerySnapshot snap;
    List<DocumentSnapshot> docList = [];
    await FirebaseFirestore.instance
        .collection("Pet")
        .where("boosted", isEqualTo: true)
        .orderBy("boostedTimestamp", descending: true)
        .get()
        .then((value) {
      docList.addAll(value.docs);
    });
    await FirebaseFirestore.instance
        .collection("Pet")
        .where("ownerId", isNotEqualTo: auth.currentUser!.uid)
        .get()
        .then((value) {
      docList.addAll(value.docs);
    });
    print("\n\nLength of DocList : ${docList.length}\n\n");
    //setState((){});
    docList.removeWhere((element) =>
        (element.data() as Map<String, dynamic>)["ownerId"] ==
        auth.currentUser!.uid);
    return docList;
  }

  void initDynamicLinks() async {
    dynamicLinks.onLink.listen((PendingDynamicLinkData dynamicLink) async {
      final Uri? deepLink = dynamicLink.link;
      if (deepLink != null) {
        print("onLink${deepLink.queryParameters["petId"]}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PetProfileScreen(
            docId: deepLink.queryParameters["petId"],
            isJustPreview: true,
            ownerId: deepLink.queryParameters["ownerId"],
          );
        }));
      }
    }, onError: (e) async {
      print('onLinkError');
      print(e.message);
    });

    await FirebaseDynamicLinks.instance.getInitialLink().then((value) {
      final Uri? deepLink = value?.link;
      if (deepLink != null) {
        print("initialLink${deepLink.queryParameters["petId"]}");
        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
          return PetProfileScreen(
            docId: deepLink.queryParameters["petId"],
            isJustPreview: true,
            ownerId: deepLink.queryParameters["ownerId"],
          );
        }));
        // Navigator.of(context).push(ShopInfoModel(deepLink.queryParameters["id"]));
      }
    }).catchError((error) {
      print('initialLinkError $error');
    });
  }

  @override
  void dispose() {
    super.dispose();
    //_interstitialAd?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    CardController controller = CardController();
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
            ? Colors.blue[600]
            : const Color(0xFFFC4048),
        elevation: 0.0,
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 20,
                height: 20,
              )),
          onTap: () async {
            if (package.isAvailable()) {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return AllProfiles();
              }));
            } else {
              Navigator.pushNamed(
                  context, PetDetailedScreen.petDetailedScreenRoute);
            }
          },
        ),
        centerTitle: true,
        title: Stack(
          children: [
            Container(
              height: 35,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            Positioned(
              left: 4,
              top: 4,
              bottom: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    leftColors = Colors.pink;
                    widget.isLeft = true;
                    rightColors = Colors.white;
                    rightIconColor = Colors.black12;
                    leftIconColor = Colors.white;
                  });
                  pageController.animateToPage(0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn);
                },
                child: Container(
                  width: 41,
                  height: 33,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.isLeft
                        ? Colors.pink
                        : Colors.white ?? Colors.pink,
                  ),
                  child: Image.asset(
                    "assets/2x/Group 378@2x.png",
                    height: 15,
                    width: 15,
                    color: leftIconColor ?? Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 4,
              top: 4,
              bottom: 4,
              child: InkWell(
                onTap: () {
                  setState(() {
                    rightColors = Colors.pink;
                    rightIconColor = Colors.white;
                    leftIconColor = Colors.black12;
                    leftColors = Colors.white;
                    widget.isLeft = false;
                  });
                  pageController.animateToPage(1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.fastLinearToSlowEaseIn);
                },
                child: Container(
                  width: 41,
                  height: 33,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: widget.isLeft
                        ? Colors.white
                        : Colors.pink ?? Colors.white,
                  ),
                  child: Image.asset(
                    sharedPrefs.currentUserPetType == "Cat"
                        ? "assets/2x/tuna-fish.png"
                        : "assets/2x/Path 373@2x.png",
                    height: 15,
                    width: 15,
                    color: rightIconColor ?? Colors.black12,
                    //rightIconColor ?? Colors.black12,
                    //rightColors == Colors.pink || widget.isLeft ? Colors.black12 : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon simple-hipchat@2x.png",
                  width: 22,
                  height: 22,
                )),
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: PageView(
          controller: pageController,
          pageSnapping: false,
          allowImplicitScrolling: false,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: Stack(alignment: Alignment.topCenter, children: [
                      Visibility(
                        visible: _noCardVisibility,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const LocaleText("you_have_no_card"),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 5.0, right: 5.0),
                              child: Container(
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.black, width: 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection("Pet")
                              .doc(widget.petId)
                              .get(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.data!.data() != null) {
                              print(
                                  "PET ID ::::::::::::::::::::::::: ${widget.petId}");
                              //sharedPrefs.currentUserPetType = snapshot.data.docs[0].data()['type'];
                              /*List list;
                              if (_petType == "Both" || _petType == null) {
                                list = snapshot.data.where((element) {
                                  Map<String, dynamic> map = element.data() as Map<String, dynamic>;

                                  return !(map.containsKey(auth.currentUser.uid)) &&
                                      // (element.data()['type'] == _petType) &&
                                      (map['age'] >= minAge && map['age'] <= maxAge) &&
                                      (preferableDistance >=
                                          mp.SphericalUtil.computeDistanceBetween(
                                              mp.LatLng(lat, lng), mp.LatLng(map['latitude'], map['longitude']))) &&
                                      (preferableGender == map['sex']) &&
                                      (!map.containsKey('block_${FirebaseAuth.instance.currentUser.uid}'));
                                }).toList();
                                print("List Length Standard: ${list.length}");
                                print("Selected Pet Type Standard: ${_petType.toString()}");
                              } else {
                                list = snapshot.data.where((element) {
                                  Map<String, dynamic> map = element.data() as Map<String, dynamic>;
                                  return !(map.containsKey(auth.currentUser.uid)) &&
                                      (map['type'] == _petType) &&
                                      (map['age'] >= minAge && map['age'] <= maxAge) &&
                                      (preferableDistance >=
                                          mp.SphericalUtil.computeDistanceBetween(
                                              mp.LatLng(lat, lng), mp.LatLng(map['latitude'], map['longitude']))) &&
                                      (preferableGender == map['sex']) &&
                                      (!map.containsKey('block_${FirebaseAuth.instance.currentUser.uid}'));
                                }).toList();
                                print("List Length Standard: ${list.length}");
                                print("Selected Pet Type Standard: ${_petType.toString()}");
                              }

                              */ /*if (!isShuffled) {
                                  list.shuffle();
                                  isShuffled = true;
                                }*/ /*
                              petId = snapshot.data[0].id;*/
                              Map<String, dynamic> data =
                                  snapshot.data!.data() as Map<String, dynamic>;
                              return TinderSwapCard(
                                cardController: controller = CardController(),
                                swipeUp: true,
                                swipeDown: true,
                                limit: likesLimit,
                                superLikeLimit: superLikesLimit,
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.9,
                                maxHeight:
                                    MediaQuery.of(context).size.height * 0.9,
                                minWidth:
                                    MediaQuery.of(context).size.width * 0.8,
                                minHeight:
                                    MediaQuery.of(context).size.width * 0.8,
                                orientation: AmassOrientation.bottom,
                                totalNum: 1,
                                stackNum: 2,
                                swipeEdge: 3.0,
                                cardBuilder: (context, index) {
                                  if (data.containsKey('latitude') ||
                                      data.containsKey('longitude')) {
                                    distance =
                                        mp.SphericalUtil.computeDistanceBetween(
                                            mp.LatLng(lat, lng),
                                            mp.LatLng(data['latitude'],
                                                data['longitude'])).toDouble();
                                    distance = (distance / 1000);
                                  }
                                  currentPetId = data['petId'];
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return PetProfileScreen(
                                          docId: snapshot.data!['petId'],
                                          ownerId: snapshot.data!['ownerId'],
                                          isJustPreview: false,
                                        );
                                      }));
                                    },
                                    child: Stack(children: [
                                      Card(
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Stack(
                                            children: [
                                              ShaderMask(
                                                shaderCallback: (bounds) =>
                                                    LinearGradient(
                                                  begin: Alignment.bottomCenter,
                                                  end: Alignment.topCenter,
                                                  tileMode: TileMode.mirror,
                                                  colors: [
                                                    const Color(0xFFEA4253),
                                                    Colors.pink[50]!,
                                                  ],
                                                  stops: const [
                                                    0.0,
                                                    0.4,
                                                  ],
                                                ).createShader(bounds),
                                                blendMode: BlendMode.multiply,
                                                child: Image.network(
                                                  snapshot.data!['images'][0],
                                                  fit: BoxFit.cover,
                                                  height: 520,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      40,
                                                ),
                                              ),
                                              Positioned(
                                                bottom: 20,
                                                left: 15,
                                                child: Column(
                                                  children: [
                                                    Text(
                                                      snapshot.data!['name'],
                                                      style: storyTitle,
                                                    ),
                                                    const SizedBox(
                                                      height: 10,
                                                    ),
                                                    Text(
                                                      "${distance.toStringAsFixed(1)} Km Away",
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      isLeft
                                          ? Visibility(
                                              visible: _action,
                                              child: Positioned(
                                                right: 15,
                                                top: 50,
                                                child: Transform.rotate(
                                                  angle: 3.14 / 7,
                                                  child: Container(
                                                    height: 50,
                                                    width: 130,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      border: Border.all(
                                                          color: Colors.red,
                                                          width: 2),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(2),
                                                    child: Center(
                                                      child: Text(
                                                        _petType == "Both"
                                                            ? snapshot.data![
                                                                        'type'] ==
                                                                    "Cat"
                                                                ? "Hiss"
                                                                : "GROWL"
                                                            : sharedPrefs
                                                                        .currentUserPetType ==
                                                                    "Cat"
                                                                ? "Hiss"
                                                                : "GROWL",
                                                        style: const TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 35,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            )
                                          : isRight
                                              ? Visibility(
                                                  visible: _action,
                                                  child: Positioned(
                                                    left: 15,
                                                    top: 40,
                                                    child: Transform.rotate(
                                                      angle: -3.14 / 7,
                                                      child: Container(
                                                        height: 50,
                                                        width: 110,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color:
                                                                  Colors.green,
                                                              width: 3),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: Center(
                                                          child: Text(
                                                            _petType == "Both"
                                                                ? snapshot.data![
                                                                            'type'] ==
                                                                        "Cat"
                                                                    ? "Purr"
                                                                    : "BARK"
                                                                : sharedPrefs
                                                                            .currentUserPetType ==
                                                                        "Cat"
                                                                    ? "Purr"
                                                                    : "BARK",
                                                            // sharedPrefs.currentUserPetType ==
                                                            //         "Cat"
                                                            //     ? "Purr"
                                                            //     : "BARK",
                                                            style:
                                                                const TextStyle(
                                                              color:
                                                                  Colors.green,
                                                              fontSize: 35,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : Visibility(
                                                  visible: _action,
                                                  child: Positioned(
                                                    left: 80,
                                                    right: 80,
                                                    bottom: 100,
                                                    child: Transform.rotate(
                                                      angle: -3.14 / 7,
                                                      child: Container(
                                                        width: 60,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                          border: Border.all(
                                                              color: Colors
                                                                  .blue[700]!,
                                                              width: 3),
                                                        ),
                                                        padding:
                                                            const EdgeInsets
                                                                .all(2),
                                                        child: Center(
                                                          child: Text(
                                                            "SUPER\nLIKE",
                                                            style: TextStyle(
                                                              color: Colors
                                                                  .blue[700],
                                                              fontSize: 35,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                    ]),
                                  );
                                },
                                swipeUpdateCallback: (DragUpdateDetails details,
                                    Alignment align) {
                                  if (align.x < -2) {
                                    //setState(() {
                                    _action = true;
                                    isLeft = true;
                                    isRight = false;
                                    isTop = false;
                                    // });
                                    //updateInteraction(status: 0, petId: petId);
                                    //Card is LEFT swiping
                                  } else if (align.x > 2) {
                                    //Card is RIGHT swiping
                                    //setState(() {
                                    _action = true;
                                    isLeft = false;
                                    isRight = true;
                                    isTop = false;
                                    // });
                                    //updateInteraction(status: 1, petId: petId);
                                  }
                                  if (align.y < -2) {
                                    //setState(() {
                                    _action = true;
                                    isTop = true;
                                    isLeft = false;
                                    isRight = false;

                                    // });
                                    //updateInteraction(status: 2, petId: petId);
                                  }
                                },
                                swipeCompleteCallback:
                                    (CardSwipeOrientation orientation,
                                        int index) async {
                                  _index = index - 1;
                                  print("swiped");
                                  AdMobHelper.showInterAdd();
                                  if (orientation ==
                                      CardSwipeOrientation.right) {
                                    lastCard = false;
                                    if (await likeCounter()) {
                                      updateInteraction(
                                        status: 1,
                                        petId: snapshot.data!['petId'],
                                        petName: snapshot.data!['name'],
                                        petImage: snapshot.data!['images'][0],
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {
                                        likesLimit = false;
                                      });
                                    }
                                  } else if (orientation ==
                                      CardSwipeOrientation.down) {
                                    lastCard = true;
                                  } else if (orientation ==
                                      CardSwipeOrientation.left) {
                                    lastCard = true;
                                    Navigator.pop(context);
                                    //updateInteraction(status: 0, petId: petId);
                                  } else if (orientation ==
                                      CardSwipeOrientation.up) {
                                    lastCard = false;
                                    if (await superLikeCounter(
                                        SharedPrefs().superTreatCounter)) {
                                      updateInteraction(
                                        status: 2,
                                        petId: snapshot.data!['petId'],
                                        petName: snapshot.data!['name'],
                                        petImage: snapshot.data!['images'][0],
                                      );
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {
                                        superLikesLimit = false;
                                      });
                                    }
                                  }
                                  _action = false;
                                },
                              );
                            } else {
                              return const Center(
                                child: CircularProgressIndicator(
                                  backgroundColor: Colors.pink,
                                  strokeWidth: 2,
                                ),
                              );
                            }
                          })
                    ]),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.06,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallActionButtons(
                        onPressed: () async {
                          print(widget.petId);
                          tri = _index;
                          if (lastCard) {
                            controller.triggerBack();
                          }
                          /*var res = await showDialog(
                            context: context,
                            builder: (context) {
                              return MySearchDialog();
                            });
                        if (res) {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return AllProfiles();
                          }));
                        }*/
                        },
                        height: 40,
                        width: 40,
                        icon: const Icon(
                          Icons.refresh_sharp,
                          color: Colors.black26,
                          size: 25,
                        ),
                      ),
                      SmallActionButtons(
                        onPressed: () {
                          //updateInteraction(status: 0, petId: petId);
                          // setState(() {
                          _action = true;
                          isLeft = true;
                          isRight = false;
                          isTop = false;
                          controller.triggerLeft();
                          lastCard = false;
                          //});
                        },
                        height: 40,
                        width: 40,
                        icon: Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(2),
                          child: Image.asset("assets/2x/cross-sign@2x.png"),
                        ),
                      ),
                      SmallActionButtons(
                        onPressed: () async {
                          // setState(() {

                          if (whichPackage == 'pettagPLUS') {
                            if (await superLikeCounter(
                                SharedPrefs().superTreatCounter)) {
                              _action = true;
                              isTop = true;
                              isLeft = false;
                              isRight = false;
                              controller.triggerUp();
                              updateInteraction(status: 2, petId: petId);
                            } else {
                              setState(() {
                                superLikesLimit = false;
                              });
                            }
                          } else if (whichPackage == 'BREEDER') {
                            if (await superLikeCounter(100)) {
                              _action = true;
                              isTop = true;
                              isLeft = false;
                              isRight = false;
                              controller.triggerUp();
                              updateInteraction(status: 2, petId: petId);
                            } else {
                              setState(() {
                                superLikesLimit = false;
                              });
                            }
                          } else {
                            _action = true;
                            isTop = true;
                            isLeft = false;
                            isRight = false;
                            controller.triggerUp();
                            lastCard = true;
                          }
                          // });
                          /* if (superLikeCounter == 0) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return SuperLikeDialog();
                              });
                        } else {

                        }*/
                        },
                        height: 40,
                        width: 40,
                        icon: Container(
                          height: 40,
                          width: 40,
                          padding: const EdgeInsets.all(2),
                          child:
                              Image.asset("assets/3x/Icon awesome-star@3x.png"),
                        ),
                      ),
                      SmallActionButtons(
                        width: 40,
                        height: 40,
                        onPressed: () async {
                          //updateInteraction(status: 1, petId: petId);
                          //setState(() {

                          if (whichPackage == 'STANDARD') {
                            if (await likeCounter()) {
                              _action = true;
                              isLeft = false;
                              isRight = true;
                              isTop = false;
                              controller.triggerRight();
                              updateInteraction(status: 1, petId: petId);
                            } else {
                              setState(() {
                                likesLimit = false;
                              });
                            }
                          } else {
                            _action = true;
                            isLeft = false;
                            isRight = true;
                            isTop = false;
                            controller.triggerRight();
                            lastCard = true;
                          }
                          //  });
                        },
                        icon: Container(
                          width: 40,
                          height: 40,
                          padding: const EdgeInsets.all(2),
                          child: Image.asset(
                              "assets/3x/Icon awesome-heart@3x.png"),
                        ),
                      ),
                      isBoosted
                          ? Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: RawMaterialButton(
                                onPressed: () {},
                                fillColor: const Color(0xFFFDF7F7),
                                constraints: const BoxConstraints.tightFor(
                                  height: 40,
                                  width: 40,
                                ),
                                elevation: 3,
                                padding: const EdgeInsets.all(8),
                                shape: const CircleBorder(),
                                child: Center(
                                  child: CountdownTimer(
                                    onEnd: boostedOnEnd(),
                                    controller: boostedTimeController,
                                    widgetBuilder:
                                        (_, CurrentRemainingTime? time) {
                                      if (time == null) {
                                        if (mounted) {
                                          setState(() {
                                            isBoosted = false;
                                          });
                                        }
                                        return Container();
                                      }
                                      return Center(
                                        child: Text('${time.sec}'),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : SmallActionButtons(
                              onPressed: () async {
                                isBoosted = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return const BoostDialog();
                                    });
                                if (isBoosted) {
                                  boostedTimeController =
                                      CountdownTimerController(
                                          endTime: DateTime.now()
                                                  .millisecondsSinceEpoch +
                                              1000 * 60);
                                  setState(() {});
                                }
                              },
                              height: 40,
                              width: 40,
                              icon: Container(
                                padding: const EdgeInsets.all(2),
                                child: Image.asset("assets/icon/injection.png"),
                              ),
                            ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
            Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(
                        width: size.width * 0.15,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _treat = true;
                              _myTreats = false;
                              _petDate = false;
                              _topPicks = false;
                            });
                          },
                          child: LocaleText(
                            "treat",
                            style: TextStyle(
                                color:
                                    _treat ? Colors.black : Colors.brown[100],
                                fontSize: 15,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.pink,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _treat = false;
                            _myTreats = false;
                            _petDate = false;
                            _topPicks = true;
                          });
                        },
                        child: LocaleText(
                          "top_picks",
                          style: TextStyle(
                              color:
                                  _topPicks ? Colors.black : Colors.brown[200],
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.pink,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _treat = false;
                            _myTreats = false;
                            _petDate = true;
                            _topPicks = false;
                          });
                        },
                        child: LocaleText(
                          "pet_date",
                          style: TextStyle(
                              color:
                                  _petDate ? Colors.black : Colors.brown[200],
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.pink,
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _treat = false;
                            _topPicks = false;
                            _petDate = false;
                            _myTreats = true;
                          });
                        },
                        child: LocaleText(
                          "my_treats",
                          style: TextStyle(
                              color:
                                  _myTreats ? Colors.black : Colors.brown[200],
                              fontSize: 15,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 5),
                  height: 1,
                  width: MediaQuery.of(context).size.width - 40,
                  color: Colors.pink[300],
                ),
                Container(
                  child: (_treat)
                      ? const Treat()
                      : (_topPicks)
                          ? const TopPicks()
                          : (_petDate)
                              ? const PetDate()
                              : const MyTreat(),
                ),
              ],
            ),
          ]),
    );
  }
}
