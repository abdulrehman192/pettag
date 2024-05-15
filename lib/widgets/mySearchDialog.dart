import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/models/packageData.dart';
import 'package:pettag/models/packageDetail.dart';
import 'package:pettag/repo/paymentRepo.dart' as repo;
import 'package:pettag/services/sharedPref.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
// import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../main.dart';

class MySearchDialog extends StatefulWidget {
  static const String mySearchDialogScreenDialog = "MySearchDialog";

  PackageDetail? package;

  @override
  _MySearchDialogState createState() => _MySearchDialogState();
}

class _MySearchDialogState extends State<MySearchDialog> {
  bool pettagStandard = false;
  bool pettag = false;
  bool pettagAdopt = false;
  bool pettagRescuer = false;
  int _currentPos = 0;
  final String updatedPolicyLink =
      "https://www.websitepolicies.com/policies/view/p01F74C4";
  bool somethingSelected = false;
  PackageDetail? packageDetail;
  int indexExtra = -1;
  // Offerings? _offerings;
  // late PurchaserInfo _purchaserInfo;
  PackageData? pkgData;
  List<PackageData> pkgList = [
    PackageData(
      duration: "",
      profileCount: 1,
      plan: "PetTag Standard",
      price: "Free",
      index: 0,
    ),
    PackageData(
      duration: "1",
      profileCount: 5,
      plan: "PetTag+",
      price: "30",
      index: 2,
    ),
    PackageData(
      duration: "6",
      profileCount: 14,
      plan: "PetTag Adopt",
      price: "25",
      index: 3,
    ),
    PackageData(
      duration: "12",
      profileCount: 1,
      plan: "PetTag Rescuer",
      price: "5",
      index: 1,
    ),
  ];

  List<String> listPaths = [
    "assets/dogsAndCats/dog4.png",
    "assets/dogsAndCats/dog3.png",
    "assets/dogsAndCats/dog2.png",
    "assets/dogsAndCats/dog5.png",
  ];

  List<String> planList = [
    "PetTag Standard",
    "PetTag+",
    "PetTag Adopt",
    "PetTag Rescuer",
  ];

  List<String> duration(context) => [
        Locales.string(context, 'pettag_standard_key'),
        Locales.string(context, 'pettag_plus_key'),
        Locales.string(context, 'pettag_breeder_key'),
        Locales.string(context, 'pettag_rescuer')
      ];

  saveProfile(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("ProfileType", value);
  }

  Future<void> fetchData() async {
    // PurchaserInfo purchaserInfo = await Purchases.getPurchaserInfo();
    //
    // Offerings offerings = await Purchases.getOfferings();
    //
    // if (!mounted) return;
    // setState(() {
    //   _purchaserInfo = purchaserInfo;
    //   _offerings = offerings;
    // });
  }

  @override
  void initState() {
    fetchData();
    super.initState();

    repo.getPkgInfo().then((value) {
      if (value != null) {
        packageDetail = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Material(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                color: Colors.pink.withAlpha(255),
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context, false);
                      },
                      child: Material(
                        borderRadius: BorderRadius.circular(20),
                        elevation: 4.0,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.black,
                            gradient: const RadialGradient(
                              colors: [
                                Colors.black,
                                Colors.white,
                              ],
                              stops: [0.5, 0.1],
                            ),
                          ),
                          child: const Icon(
                            Icons.cancel_rounded,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      child: Column(
                        children: [
                          CarouselSlider.builder(
                            itemCount: 4,
                            itemBuilder: (context, index, _) {
                              return Container(
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius:
                                            BorderRadius.circular(100),
                                        border: Border.all(
                                            color: Colors.white, width: 2),
                                      ),
                                      child: CircleAvatar(
                                        backgroundImage:
                                            AssetImage(listPaths[index]),
                                        radius: 50,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 1,
                                    ),
                                    Text(
                                      planList[index],
                                      style: dialogTitle.copyWith(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      "For ${duration(context)[index]} months",
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.normal,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            options: CarouselOptions(
                                autoPlay: true,
                                autoPlayCurve: Curves.elasticInOut,
                                autoPlayAnimationDuration:
                                    const Duration(seconds: 1),
                                enlargeCenterPage: false,
                                viewportFraction: 1.5,
                                height: 350,
                                onPageChanged: (index, reason) {
                                  setState(() {
                                    _currentPos = index;
                                  });
                                }),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: listPaths.map((url) {
                              int index = listPaths.indexOf(url);
                              return Container(
                                width: 8.0,
                                height: 8.0,
                                margin: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 2.0),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _currentPos == index
                                      ? const Color.fromRGBO(255, 255, 255, 0.9)
                                      : const Color.fromRGBO(
                                          255, 255, 255, 0.4),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              InkWell(
                child: RichText(
                  text: const TextSpan(
                    text: 'Before processing payment, Please read our ',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    children: <TextSpan>[
                      TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                              fontSize: 14)),
                    ],
                  ),
                ),
                onTap: () async {
                  if (await canLaunch(updatedPolicyLink)) {
                    await launch(updatedPolicyLink);
                  } else {
                    throw 'Could not launch $updatedPolicyLink';
                  }
                },
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8.0),
                      scrollDirection: Axis.horizontal,
                      shrinkWrap: true,
                      itemCount: pkgList.length,
                      itemBuilder: (context, index) {
                        print("From List");
                        print(pkgList);
                        return Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Stack(
                            alignment: Alignment.topCenter,
                            children: [
                              Card(
                                margin: const EdgeInsets.only(top: 20),
                                elevation: 4.0,
                                shape: pkgList[index].index == indexExtra
                                    ? RoundedRectangleBorder(
                                        side: const BorderSide(
                                            color: Colors.redAccent, width: 2),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      )
                                    : RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                child: SizedBox(
                                  height: 150,
                                  width: 130,
                                  child: Center(
                                    child: ListTile(
                                      isThreeLine: true,
                                      onTap: () async {
                                        setState(() {
                                          indexExtra = pkgList[index].index!;
                                          pkgData = pkgList[index];
                                          print("Index Extra : $indexExtra");
                                        });
                                      },
                                      title: Text(
                                        '',
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          color: Color(0xFF854D5E),
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [

                                          // Text(
                                          //   //"\$${pkgList[index].price}/month",
                                          //   index == 0
                                          //       ? "${pkgList[index].price}"
                                          //       : index == 1
                                          //           ? "${_offerings?.getOffering("pettagplus")!.monthly!.product.priceString}/month"
                                          //           : index == 2
                                          //               ? "${_offerings?.getOffering("breeder_package")!.monthly!.product.priceString}/month"
                                          //               : "${_offerings?.getOffering("rescuer_package")!.monthly!.product.priceString}/month",
                                          //   textAlign: TextAlign.center,
                                          //   style: const TextStyle(
                                          //     color: Colors.black,
                                          //     fontSize: 18,
                                          //     fontWeight: FontWeight.bold,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Visibility(
                                visible: pkgList[index].index == indexExtra,
                                child: Container(
                                  height: 40,
                                  width: 100,
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      pkgList[index].plan.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
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
                  GenericBShadowButton(
                    buttonText: Locales.string(context, 'continue'),
                    onPressed: //pkgData == null ?
                         (){}
                        // : () async {
                        //     var pcount = pkgData!.profileCount;
                        //     var rcount = pkgData!.profileCount;
                        //     if (pkgData!.plan == "pettag+") {
                        //       _purchaserInfo = await Purchases.purchasePackage(
                        //           _offerings!.getOffering("pettagplus")!.monthly!);
                        //       if (_purchaserInfo
                        //           .entitlements.active.isNotEmpty) {
                        //         SharedPreferences prefs =
                        //             await SharedPreferences.getInstance();
                        //         prefs.setString('packageName', 'pettagPLUS');
                        //         SharedPrefs().leftBoostCounter = 1;
                        //         SharedPrefs().superTreatCounter =
                        //             SharedPrefs().superTreatCounter + 5;
                        //         appData.isPro = _purchaserInfo
                        //             .entitlements.all['pettagplus']!.isActive;
                        //         User? user = FirebaseAuth.instance.currentUser;
                        //         var map = {
                        //           'type': 'pettagplus',
                        //           'price': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .price,
                        //           'currency': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .currencyCode,
                        //           'user_id': user!.uid,
                        //           'user_name': user.displayName,
                        //           'user_picture': user.photoURL,
                        //           'timeStamp': Timestamp.now(),
                        //         };
                        //         uploadHistory(map);
                        //       } else {
                        //         print('Purchase Not Made');
                        //       }
                        //
                        //       print('purchase completed');
                        //     } else if (pkgData!.plan == 'pettag Standard') {
                        //       SharedPreferences prefs =
                        //           await SharedPreferences.getInstance();
                        //       prefs.setString('packageName', 'STANDARD');
                        //       User? user = FirebaseAuth.instance.currentUser;
                        //       var map = {
                        //         'name': 'standard',
                        //         'price': '0',
                        //         'currency': _offerings!
                        //             .getOffering("pettagplus")!
                        //             .monthly!
                        //             .product!
                        //             .currencyCode,
                        //         'user_id': user!.uid,
                        //         'user_name': user.displayName,
                        //         'user_picture': user.photoURL,
                        //         'timeStamp': Timestamp.now(),
                        //       };
                        //       uploadHistory(map);
                        //       Navigator.pop(context, false);
                        //       return;
                        //     } else if (pkgData!.plan == "pettag Breeder") {
                        //       _purchaserInfo = await Purchases.purchasePackage(
                        //           _offerings!.getOffering("breeder_package")!.monthly!);
                        //       if (_purchaserInfo
                        //           .entitlements.active.isNotEmpty) {
                        //         SharedPreferences prefs =
                        //             await SharedPreferences.getInstance();
                        //         prefs.setString('packageName', 'BREEDER');
                        //         SharedPrefs().leftBoostCounter = 3;
                        //         appData.isPro = _purchaserInfo
                        //             .entitlements.all['breeder']!.isActive;
                        //         User? user = FirebaseAuth.instance.currentUser;
                        //         var map = {
                        //           'name': 'breeder_package',
                        //           'price': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .price,
                        //           'currency': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .currencyCode,
                        //           'user_id': user!.uid,
                        //           'user_name': user.displayName,
                        //           'user_picture': user.photoURL,
                        //           'timeStamp': Timestamp.now(),
                        //         };
                        //         uploadHistory(map);
                        //       } else {
                        //         print('Purchase Not Made');
                        //       }
                        //       print('purchase completed');
                        //     } else if (pkgData!.plan == "pettag Rescuer") {
                        //       _purchaserInfo = await Purchases.purchasePackage(
                        //           _offerings!.getOffering("rescuer_package")!.monthly!);
                        //       if (_purchaserInfo
                        //           .entitlements.active.isNotEmpty) {
                        //         SharedPreferences prefs =
                        //             await SharedPreferences.getInstance();
                        //         prefs.setString('packageName', 'RESCUER');
                        //         SharedPrefs().leftBoostCounter = 3;
                        //         appData.isPro = _purchaserInfo
                        //             .entitlements.all['rescuer']!.isActive;
                        //         User? user = FirebaseAuth.instance.currentUser;
                        //         var map = {
                        //           'name': 'rescuer_package',
                        //           'price': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .price,
                        //           'currency': _offerings!
                        //               .getOffering("pettagplus")!
                        //               .monthly!
                        //               .product
                        //               .currencyCode,
                        //           'user_id': user!.uid,
                        //           'user_name': user.displayName,
                        //           'user_picture': user.photoURL,
                        //           'timeStamp': Timestamp.now(),
                        //         };
                        //         uploadHistory(map);
                        //       } else {
                        //         print('Purchase Not Made');
                        //       }
                        //       print('purchase completed');
                        //     }
                        //     if (packageDetail != null) {
                        //       pcount = (packageDetail!.profileCount!  +
                        //           pkgData!.profileCount! );
                        //       rcount = packageDetail!.remaining! +
                        //           pkgData!.profileCount!;
                        //     }
                        //     Map<String, dynamic> myMap = {
                        //       "pkgName": pkgData!.plan,
                        //       "price": pkgData!.price,
                        //       "profileCount": pcount,
                        //       "time": ((DateTime.now().millisecondsSinceEpoch) +
                        //           1000 * 525600 * 60),
                        //       "remaining": rcount
                        //     };
                        //     PackageDetail pkgDetail =
                        //         PackageDetail.fromJson(myMap);
                        //     repo.storePkgInfo(pkgDetail);
                        //     repo.pkg.value = pkgDetail;
                        //     repo.pkg.notifyListeners();
                        //     Navigator.of(context).pop(true);
                        //   },
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column buildCarousalCard({required String imagePath, required String title, required String period}) {
    return Column(
      children: [
        CircleAvatar(
          backgroundImage: AssetImage(imagePath),
          radius: 50,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: dialogTitle,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          "For $period months",
          style: dialogTitle,
        ),
        const SizedBox(
          height: 20,
        ),
        const Text(
          "Get 5 Free Super Likes a day & more",
          style: TextStyle(
            color: Colors.white70,
          ),
        ),
      ],
    );
  }

  showInSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  uploadHistory(map) async {
    await FirebaseFirestore.instance
        .collection('paymentHistory')
        .doc()
        .set(map, SetOptions(merge: true));
  }
}
