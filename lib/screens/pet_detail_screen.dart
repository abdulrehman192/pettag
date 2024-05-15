import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/main.dart';
import '/screens/screens.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'package:pettag/widgets/petFood_icon_appbar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constant.dart';

class PetDetailedScreen extends StatefulWidget {
  static const String petDetailedScreenRoute = 'PetDetailedScreen';

  const PetDetailedScreen({super.key});

  @override
  _PetDetailedScreenState createState() => _PetDetailedScreenState();
}

class _PetDetailedScreenState extends State<PetDetailedScreen> {
  final privacyPolicyLink = "https://pettag.net/";
  bool petChangingSwitch = false;

  late CollectionReference pet;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late Stream<QuerySnapshot> snap;
  String id = '';

  @override
  void initState() {
    super.initState();
    pet = FirebaseFirestore.instance.collection('Pet');
    print(auth.currentUser!.uid);
  }

  Stream<QuerySnapshot> getSnap() {
    snap = FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser!.uid)
        .snapshots();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
            ? Colors.blue[600]
            : appBarBgColor,
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
          onTap: () {
            Navigator.pushNamed(
                context, PetSlideScreen.petSlideScreenRouteName);
          },
        ),
        centerTitle: true,
        title: const PetFoodIconInAppBar(
          isLeft: true,
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 30,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 17,
                  height: 17,
                )),
            onTap: () {
              /*Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Home(isChatSide: false,);
              }));*/
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyMap(
                  isVisible: true,
                  isChatSide: false,
                  peerId: '',
                );
              }));
            },
          ),
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
      body: SafeArea(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('Pet')
                  .where('ownerId', isEqualTo: auth.currentUser!.uid)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }
                if (snapshot.hasData) {
                  Map<String, dynamic> data = snapshot.data!.docs[0].data() as Map<String, dynamic>;
                  List<dynamic> image = data['images'] ?? [];
                  id = data['petId'];
                  String ownerId = data['ownerId'];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        height: 40,
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return PetProfileScreen(
                              ownerId: ownerId,
                              docId: id,
                              isJustPreview: true,
                            );
                          }));
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.pink, width: 2),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: CircleAvatar(
                            radius: 70,
                            backgroundColor: Colors.white,
                            backgroundImage: showImage(data['images'][0]),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Text(
                        data['name'] ?? "Unknown",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            "",
                            style:
                                TextStyle(color: Colors.black26, fontSize: 13),
                          ),
                        ],
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              /*InkWell(
                              child: Container(
                                padding: EdgeInsets.all(5),
                                height: 70,
                                width: 70,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(100),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black12,
                                        blurRadius: 4,
                                        spreadRadius: 1,
                                        offset: Offset(0, 0),
                                      ),
                                    ]),
                                child: Center(
                                  child: Text("PT+",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 25,
                                        foreground: Paint()..shader = linearGradient,
                                      )),
                                ),
                              ),
                              onTap: () async {
                                var res = await showDialog(
                                    context: context,
                                    builder: (context) {
                                      return MySearchDialog();
                                    });
                                if (res) {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                                    return AllProfiles();
                                  }));
                                }
                              },
                            ),*/
                              InkWell(
                                child: Container(
                                  padding: const EdgeInsets.all(15),
                                  height: 60,
                                  width: 60,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: Image.asset(
                                    "assets/2x/Icon ionic-ios-settings@2x.png",
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context,
                                      SettingsScreen.settingsScreenRoute);
                                },
                              ),
                              Stack(
                                children: [
                                  InkWell(
                                    //radius: 30,
                                    child: Container(
                                      width: 60,
                                      height: 60,
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                          color: const Color(0xFFF22C6D),
                                          borderRadius:
                                              BorderRadius.circular(100),
                                          boxShadow: const [
                                            BoxShadow(
                                              color: Colors.black12,
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                              offset: Offset(0, 0),
                                            ),
                                          ]),
                                      child: Image.asset(
                                          "assets/2x/Icon material-linked-camera@2x.png"),
                                    ),
                                    onTap: () {
                                      // Navigator.pushNamed(
                                      //   context,
                                      //   EditProfileScreen
                                      //       .editProfileScreenRoute,
                                      //   arguments: <dynamic, dynamic>{
                                      //     "id": id,
                                      //     "ownerId": ownerId,
                                      //     "isPro": false,
                                      //   },
                                      // );
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              EditProfileScreen(
                                            id: id,
                                            ownerId: ownerId,
                                            isPro: false,
                                                petName: '',
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  Positioned(
                                    bottom: 2,
                                    right: 2,
                                    child: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Image.asset(
                                          "assets/2x/Icon feather-plus-circle@2x.png"),
                                    ),
                                  ),
                                ],
                              ),
                              InkWell(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "assets/2x/Icon awesome-pencil-alt@2x.png",
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) {
                                        return EditInfoScreen(
                                          id: id,
                                          ownerId: ownerId,
                                          isPro: false,
                                          petName: '',
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "assets/bag.png",
                                      color: const Color(0xFFF22C6D),
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  if (await canLaunch(privacyPolicyLink)) {
                                    await launch(privacyPolicyLink);
                                  } else {
                                    throw 'Could not launch $privacyPolicyLink';
                                  }
                                },
                              ),
                              InkWell(
                                child: Container(
                                  height: 60,
                                  width: 60,
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          spreadRadius: 1,
                                          offset: Offset(0, 0),
                                        ),
                                      ]),
                                  child: SizedBox(
                                    height: 30,
                                    width: 30,
                                    child: Image.asset(
                                      "assets/healthcare.png",
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                Navigator.pushNamed(context, AppointmentScreen.appointmentScreenRoute);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(
                        flex: 1,
                      ),
                      GenericBShadowButton(
                        buttonText: 'Get PetTag+',
                        onPressed: () async {
                          var res = await showDialog(
                              context: context,
                              builder: (context) {
                                return MySearchDialog();
                              });
                          if (res) {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return AllProfiles();
                            }));
                          }
                        },
                      ),
                      SizedBox(height: 40),
                    ],
                  );
                }
                return const Center(
                    child: CircularProgressIndicator(
                  backgroundColor: Colors.transparent,
                  strokeWidth: 2,
                ));
              }),
        ),
      ),
    );
  }

  showImage(String? url) {
    if(url == null)
    {
      return const AssetImage("assets/ownerProfile.png");
    }
    else
    {
      return NetworkImage(url);
    }
  }
}

/*SearchMapPlaceWidget(
                  apiKey: 'AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM',
                  hintText: 'To',
                  location: LatLng(24.12345, 34.45678),
                  radius: 50 * 1000,
                  hasClearButton: true,
                  strictBounds: true,
                  onSelected: (place) async {
                    /*final geolocation = await place.geolocation;
                    LatLng latLng = geolocation.coordinates;
                    destinationLatitude = latLng.latitude;
                    destinationLongitude = latLng.longitude;
                    destinationLocationLatLng =
                        LatLng(destinationLatitude, destinationLongitude);

                    double totalDistance = distance(
                        userLocationLatLng, destinationLocationLatLng);

                    controller.animateCamera(CameraUpdate.newLatLngZoom(
                        userLocationLatLng,
                        getZoomLevel(totalDistance * 1000)));

                    markers.add(Marker(
                        markerId: MarkerId('2'),
                        position:
                        LatLng(destinationLatitude, destinationLongitude),
                        icon: BitmapDescriptor.defaultMarkerWithHue(0)));

                    _getPolyline();

                    user.totalKilometers = totalDistance;

                    print('******* Total Distance ********');
                    print('Distance in KM : ' + totalDistance.toString());

                    final coordinates = new Coordinates(destinationLatitude, destinationLongitude);
                    var addresses = await Geocoder.local.findAddressesFromCoordinates(coordinates);
                    var first = addresses.first;

                    user.userDestinationAddress = first.locality;//+ ',' + first.subLocality;

                    print('Destination Address : '+user.userDestinationAddress.toString());


                    setState(() {
                      isDestinationSelected = true;
                    });*/
                  },
                );*/
