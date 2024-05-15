import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:pettag/geo_firestore/geo_hash.dart';
import 'package:pettag/screens/push_notification.dart';
import 'package:pettag/screens/sign_in_screen.dart';
import 'package:pettag/services/sharedPref.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/boostDialog.dart';
import 'package:pettag/widgets/changePasswordDialog.dart';
import 'package:pettag/widgets/customCard.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'package:pettag/widgets/privacy_policy_dialog.dart';
import 'package:pettag/widgets/termsAndCondDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';
import '../main.dart';
import 'blocklistScreen.dart';
import 'email_notification.dart';
import 'languages.dart';

class SettingsScreen extends StatefulWidget {
  static const String settingsScreenRoute = 'SettingsScreen';

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool superTreatPurchase = false;
  String? interestedIn;
  String? gender;
  String? ownerGender;
  bool isDistanceUnitChange = true;
  int age = 5;
  int distance = 1;
  double locationContainerHeight = 0;
  RangeValues preferableAge = const RangeValues(1, 30);
  RangeValues ownerAge = const RangeValues(18, 100);
  bool _isVisible = false;
  var lat = 0.0;
  var lng = 0.0;
  bool isAgeChanged = false;
  bool isOwnerAgeChanged = false;
  bool isLoading = false;
  String? distanceUnit = "Km";
  String checkInterest = '';

  // final GlobalKey<SnackBarWidgetState> _globalKey = GlobalKey();
  SharedPrefs prefs = SharedPrefs();

  late CountdownTimerController controller;
  int endTime = DateTime.now().millisecondsSinceEpoch + 1000 * 30;

   StreamSubscription? _purchaseUpdatedSubscription;
   StreamSubscription? _purchaseErrorSubscription;
  List<String> productIds = [
    'treats',
    'super_treats',
  ];
  List<IAPItem> _items = [];
  late IAPItem purchaseIt;

  Future<SnackBarClosedReason> showInSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar).closed;
  }

  Future<void> initPlatformState() async {
    // prepare
    var result = await FlutterInappPurchase.instance.initialize();
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    // refresh items for android
    // String msg = await FlutterInappPurchase.instance.consumeAllItems;
    // print('consumeAllItems: $msg');
    try {
      String msg = await FlutterInappPurchase.instance.consumeAll();
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
      if (superTreatPurchase) {
        // prefs.setInt('superLikesCount', prefs.getInt('superLikesCount') + 5);
        SharedPrefs().superTreatCounter = SharedPrefs().superTreatCounter + 5;
      } else {
        SharedPrefs().treatCounter = SharedPrefs().treatCounter + 15;
        FirebaseFirestore.instance
            .collection("User")
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({
          'treats': 15,
        });
      }
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
    await _getProduct();
  }

  Future<void> _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getProducts(productIds);
    for (var item in items) {
      print(item.toString());
      _items.add(item);
    }
    setState(() {
      _items = items;
    });
  }

  Future<void> _buyProduct(IAPItem item) async {
    try {
      PurchasedItem purchased =
          await FlutterInappPurchase.instance.requestPurchase(item.productId!);
      PurchaseState? state = purchased.purchaseStateAndroid;
      print("\n\n\nState of purchase : $state");
      String msg = await FlutterInappPurchase.instance.consumeAll();
      print('consumeAllItems: $msg');
    } catch (error) {
      print('$error');
    }
  }

  updateInterestFilter() {
    sharedPrefs.currentUserPetType = interestedIn!;
    FirebaseCredentials()
        .db
        .collection('User')
        .doc(FirebaseCredentials().auth.currentUser!.uid)
        .update({
      'interest': interestedIn,
    }).then((value) {
      setState(() {
        isLoading = false;
      });
    });
  }

  updateGenderFilter(gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('preferredGender', gender);
  }

  updateOwnerGenderFilter(gender) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('preferredOwnerGender', gender);
  }

  setDistanceUnit(String unit) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('distUnit', unit);
    print('---> distance changed to: $unit');
  }

  updatePreferableAge(start, end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('minAge', start);
    prefs.setDouble('maxAge', end);
  }

  updatePreferableOwnerAge(start, end) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setDouble('ownerMinAge', start);
    prefs.setDouble('ownerMaxAge', end);
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

  getPetType() async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('User')
        .doc(FirebaseCredentials().auth.currentUser!.uid)
        .get();
    if (snapshot.exists) {
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data.isNotEmpty) {
        print("Interest : ${data['interest']}");
        interestedIn = data['interest'];
        checkInterest = data['interest'];
        setState(() {});
        print("PetType : $interestedIn");
      }
    }
  }

  getPreviousData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('minAge') && prefs.containsKey('maxAge')) {
      preferableAge =
          RangeValues(prefs.getDouble('minAge')!, prefs.getDouble('maxAge')!);
    }
    if (prefs.containsKey('ownerMinAge') && prefs.containsKey('ownerMaxAge')) {
      ownerAge = RangeValues(
          prefs.getDouble('ownerMinAge')!, prefs.getDouble('ownerMaxAge')!);
    }
    if (prefs.containsKey('radius')) {
      distance = prefs.getInt('radius')!;
    }
    if (prefs.containsKey('preferredGender')) {
      gender = prefs.getString('preferredGender')!;
    }
    if (prefs.containsKey('preferredOwnerGender')) {
      ownerGender = prefs.getString('preferredOwnerGender')!;
    }
    if (prefs.containsKey("distUnit")) {
      distanceUnit = prefs.getString("distUnit")!;
    }
    await getPetType();
  }

  void onEnd() {
    print('onEnd');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initAppPurchase();
    print("isDistanceUnitChange $isDistanceUnitChange");
    initPlatformState();
    getPreviousData();
    print("distance ${prefs.getRadius}");
    distance = prefs.getRadius ;
  }

  initAppPurchase() async
  {
    await FlutterInappPurchase.instance.initialize();
  }

  @override
  Future<void> dispose() async {
    // TODO: implement dispose
    super.dispose();
    await FlutterInappPurchase.instance.finalize();
    _purchaseUpdatedSubscription!.cancel();
    _purchaseErrorSubscription!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: const Icon(
            Icons.arrow_back,
            size: 22,
            color: Colors.pink,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const LocaleText(
          "settings",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ),
      body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 16, right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MySearchDialog();
                      },
                    );
                  },
                  child: CustomCard(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          //crossAxisAlignment: CrossAxisAlignment.baseline,
                          children: [
                            Image.asset(
                              "assets/logo@3xUpdated.png",
                              height: 25,
                              width: 25,
                              color: Colors.pink,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: const TextSpan(
                                text: 'PetTag',
                                style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                                children: <TextSpan>[
                                  TextSpan(
                                      text: '+',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 25)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const LocaleText(
                          "receive_booster_shot",
                          style: TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    /*_globalKey.currentState.show(
                        "You have to purchase subscription package to boost your profile");*/
                    showDialog(
                        context: context,
                        builder: (context) {
                          return const BoostDialog();
                        });
                  },
                  child: CustomCard(
                    height: 90,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 0),
                                spreadRadius: 2,
                                blurRadius: 2,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            "assets/icon/injection.png",
                            height: 25,
                            width: 25,
                            color: Colors.pink,
                          ),
                        ),
                        const LocaleText(
                          "increase_boost",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.w900,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () async {
                        await _buyProduct(_items[1]);
                        setState(() {
                          superTreatPurchase = false;
                        });
                      },
                      child: CustomCard(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 170,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/2x/Icon awesome-heart@2x.png",
                              ),
                            ),
                            const LocaleText(
                              "treats",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.pink[50]!.withOpacity(0.2),
                              ),
                              child: Text(
                                "\$3",
                                style: TextStyle(
                                  backgroundColor:
                                      Colors.pink[50]!.withOpacity(0.5),
                                  fontSize: 17,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.pink,
                                  child: Text(
                                    SharedPrefs().treatCounter != null
                                        ? "${SharedPrefs().treatCounter - SharedPrefs().likeCount}"
                                        : SharedPrefs().treatCounter.toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const LocaleText(
                                  "treat_lefts",
                                  style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        setState(() {
                          superTreatPurchase = true;
                        });
                        await _buyProduct(_items[0]);
                      },
                      child: CustomCard(
                        width: MediaQuery.of(context).size.width / 2 - 20,
                        height: 170,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              padding: const EdgeInsets.all(3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    offset: Offset(0, 0),
                                    spreadRadius: 2,
                                    blurRadius: 2,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/2x/Icon awesome-star@2x.png",
                              ),
                            ),
                            const LocaleText(
                              "super_treats",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                            Container(
                              height: 20,
                              width: 50,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.pink[50]!.withOpacity(0.2),
                              ),
                              child: Text(
                                "\$2.50",
                                style: TextStyle(
                                  backgroundColor:
                                      Colors.pink[50]!.withOpacity(0.5),
                                  fontSize: 17,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: Colors.pink,
                                  child: Text(
                                    SharedPrefs().superTreatCounter != null
                                        ? "${SharedPrefs().superTreatCounter - SharedPrefs().superLikesCount}"
                                        : SharedPrefs()
                                            .superTreatCounter
                                            .toString(),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                const LocaleText(
                                  "treat_left",
                                  style: TextStyle(
                                    color: Colors.pink,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.all(5.0),
                  child: LocaleText(
                    "discovery_settings",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.black,
                      fontSize: 19,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isVisible = _isVisible ? false : true;
                    });
                  },
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            offset: Offset(0, 2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ]),
                    duration: const Duration(seconds: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            children: const [
                              LocaleText(
                                "location",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                              Spacer(),
                              LocaleText(
                                "current_location",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                        ),
                        /*Visibility(
                          visible: _isVisible,
                          child: ElevatedButton(
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            padding: EdgeInsets.all(0),
                            child: Text(
                              "Add New Location",
                              style: TextStyle(
                                color: Colors.brown[400],
                              ),
                            ),
                            onPressed: () {},
                          ),
                        ),*/
                        Visibility(
                          visible: _isVisible,
                          child: ElevatedButton(
                            onPressed: () async {
                              final center = await getUserLocation();
                              if (center!.longitude != null &&
                                  center.latitude != null) {
                                await FirebaseCredentials()
                                    .db
                                    .collection('User')
                                    .doc(FirebaseCredentials()
                                        .auth
                                        .currentUser!
                                        .uid)
                                    .update({
                                  'latitude': center.latitude,
                                  'longitude': center.longitude,
                                  'geoHash': GeoHash.encode(
                                      center.latitude, center.longitude),
                                });
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  FontAwesomeIcons.locationDot,
                                  color: Colors.blue,
                                  size: 15,
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                LocaleText(
                                  "use_current_location",
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(5),
                  child: LocaleText(
                    "change_location",
                    style: TextStyle(
                      color: Colors.black38,
                      fontSize: 12,
                    ),
                  ),
                ),
                /*CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Have My Pet",
                          style: pinkHeadingStyle,
                        ),
                        Row(
                          children: [
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: true,
                              activeColor: Colors.black54,
                              focusColor: Colors.black,
                              groupValue: _haveMyPet,
                              onChanged: (bool value) {
                                setState(() {
                                  _haveMyPet = value;
                                });
                              },
                            ),
                            Text(
                              "Yes",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                        Row(
                          children: [
                            Radio(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              value: false,
                              toggleable: true,
                              activeColor: Colors.black54,
                              groupValue: _haveMyPet,
                              onChanged: (bool value) {
                                setState(() {
                                  _haveMyPet = value;
                                });
                              },
                            ),
                            Text(
                              "No",
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.black54,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),*/
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "interested_in",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: interestedIn ?? "Cat",
                            contentPadding: const EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: interestedIn,
                          items: <String>['Dog', 'Cat', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              interestedIn = value.toString();
                              //updateInterestFilter();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "show_me",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: gender ?? "Female",
                            contentPadding: const EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: gender,
                          items: <String>['Male', 'Female', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              gender = value.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "owner",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: ownerGender ?? "Female",
                            contentPadding: const EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: ownerGender,
                          items: <String>['Male', 'Female', 'Both']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              ownerGender = value.toString();
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 15.0, left: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "show_distance",
                          style: pinkHeadingStyle,
                        ),
                        DropdownButtonFormField(
                          isExpanded: false,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            hintText: distanceUnit ?? "Km",
                            contentPadding: const EdgeInsets.all(8.0),
                            hintStyle: hintTextStyle.copyWith(
                              color: Colors.black87,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30),
                                borderSide: const BorderSide(
                                  color: Colors.transparent,
                                )),
                          ),
                          value: distanceUnit,
                          items: <String>['Km', 'Miles']
                              .map<DropdownMenuItem<String>>(
                                  (String value) => DropdownMenuItem(
                                        value: value,
                                        child: Text(value),
                                      ))
                              .toList(),
                          onChanged: (value) {
                            print("---> value" + value.toString());
                            setState(() {
                              if (value != distanceUnit) {
                                isDistanceUnitChange = true;
                              }
                              distanceUnit = value.toString();
                              if (distanceUnit == 'Miles') {
                                double temp = distance * 0.6213711922;
                                distance = temp.toInt();
                              } else {
                                double temp = distance * 1.609344;
                                distance = temp.toInt();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const LocaleText(
                              "pet_age",
                              style: pinkHeadingStyle,
                            ),
                            const Spacer(),
                            Text(
                              "${preferableAge.start.toInt()} - ${preferableAge.end.toInt()}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            trackHeight: 1,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            //overlayColor: Color(0x29EB1555),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25.0),
                          ),
                          child: RangeSlider(
                              min: 1,
                              max: 30,
                              values: preferableAge,
                              onChanged: (value) {
                                setState(() {
                                  preferableAge = value;
                                  isAgeChanged = true;
                                  print("Preferable Age : $preferableAge");
                                });
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const LocaleText(
                              "owner_age",
                              style: pinkHeadingStyle,
                            ),
                            const Spacer(),
                            Text(
                              "${ownerAge.start.toInt()} - ${ownerAge.end.toInt()}",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            trackHeight: 1,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            //overlayColor: Color(0x29EB1555),
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25.0),
                          ),
                          child: RangeSlider(
                              min: 18,
                              max: 100,
                              values: ownerAge,
                              onChanged: (value) {
                                setState(() {
                                  ownerAge = value;
                                  isOwnerAgeChanged = true;
                                  //print("Owner Age : $ownerAge");
                                });
                              }),
                        )
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 15.0, right: 15, left: 12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const LocaleText(
                              "maximum_distance",
                              style: pinkHeadingStyle,
                            ),
                            const Spacer(),
                            Text(
                              "${distance.toString()} $distanceUnit",
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: Colors.redAccent,
                            inactiveTrackColor: Colors.black26,
                            thumbColor: Colors.redAccent,
                            trackHeight: 1,
                            thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 10.0),
                            overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 25.0),
                          ),
                          child: Slider(
                            value: distance.toDouble(),
                            min: 0,
                            max: 1000,
                            onChanged: (double newValue) async {
                              setState(() {
                                distance = newValue.ceil();
                                //print(" onChange Distance${distance}");
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 13.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "notification",
                          style: pinkHeadingStyle,
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context,
                              EmailNotification.emailNotificationScreenRoute),
                          child: const LocaleText(
                            "email",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context,
                              PushNotification.pushNotificationScreenRoute),
                          child: const LocaleText(
                            "push_notification",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 130,
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15.0, left: 13.0, bottom: 10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LocaleText(
                          "legal",
                          style: pinkHeadingStyle,
                        ),
                        const SizedBox(
                          height: 1,
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return CustomTermsAndCondDialog();
                              },
                            );
                          },
                          child: const LocaleText(
                            "terms_and_conditions",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return PrivacyPolicyDialog();
                              },
                            );
                          },
                          child: const LocaleText(
                            "privacy_policy",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return BlocklistScreen();
                        }));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Center(
                            child: LocaleText(
                              "blocklist",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                CustomCard(
                  width: MediaQuery.of(context).size.width,
                  height: 60,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const Languages();
                        }));
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Center(
                            child: LocaleText(
                              "language",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.black,
                            size: 15,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Spacer(),
                    InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return ChangePasswordDialog();
                          },
                        );
                      },
                      child: const CustomCard(
                        width: 160,
                        height: 50,
                        child: Center(
                          child: LocaleText(
                            "change_password",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
                InkWell(
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    sharedPrefs.clearPetType();
                    sharedPrefs.clearPackageDetails();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const SignInScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  child: CustomCard(
                    width: MediaQuery.of(context).size.width,
                    height: 60,
                    child: const Center(
                      child: LocaleText(
                        "log_out",
                        style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 17),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () {
                    if (interestedIn != checkInterest) {
                      setState(() {
                        isLoading = true;
                      });
                      updateInterestFilter();
                    }
                    if (gender != null) {
                      setState(() {
                        isLoading = true;
                      });
                      updateGenderFilter(gender);
                    }
                    if (ownerGender != null) {
                      setState(() {
                        isLoading = true;
                      });
                      updateOwnerGenderFilter(ownerGender);
                    }
                    if (isDistanceUnitChange) {
                      setDistanceUnit(distanceUnit!);
                    }
                    if (distance > 1) {
                      setState(() {
                        isLoading = true;
                      });
                      prefs.setRadius(distance);
                    }
                    if (isAgeChanged) {
                      setState(() {
                        isLoading = true;
                      });
                      updatePreferableAge(
                          preferableAge.start, preferableAge.end);
                    }

                    if (isOwnerAgeChanged) {
                      setState(() {
                        isLoading = true;
                      });
                      updatePreferableOwnerAge(ownerAge.start, ownerAge.end);
                    }
                    showInSnackBar("Changes has been saved!").then((value) {
                      isLoading ? Navigator.pop(context) : null;
                    });
                    print("distanceUnit$distanceUnit");
                  },
                  child: CustomCard(
                    height: 60,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                      child: LocaleText(
                        "save_changes",
                        style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
              ],
            ),
          ),
        ),
    );
  }
}
