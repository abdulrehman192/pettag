import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart';
import 'package:location/location.dart' as LocationManager;
import 'package:numberpicker/numberpicker.dart';
import 'package:pettag/geo_firestore/geo_firestore.dart';
import 'package:pettag/geo_firestore/geo_utils.dart';
import 'package:pettag/repo/settingRepo.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/utilities/helper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyMap extends StatefulWidget {
  bool? isVisible = false;
  final String? peerId;
  final bool? isChatSide;

  MyMap({Key? key,  this.isVisible,  this.isChatSide,  this.peerId})
      : super(key: key);

  @override
  State createState() => _MyMapState();
}

class _MyMapState extends State<MyMap> {
  final Set<Marker> _markers = <Marker>{};
  int radius = 50;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late CameraUpdate cameraUpdate;
  late GoogleMapController mapController;
  late Set<Circle> circles;
  late NumberPicker integerInfiniteNumberPicker;
  late NumberPicker decimalNumberPicker;
  bool isLeft = false;
  String petId = '';
  bool isLoading = false;
  String errorMessage = '';
  Color? rightColors;
   Color? leftColors;
   Color? leftIconColor;
   Color? rightIconColor;
  List<PlacesSearchResult> places = [];
  int raaaadius = 0;
  LatLng? userLocation;

  //AIzaSyCBfQv3UsQhuG8m8iRArEuBBSHoDHVT_sI
  //AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM

  final GoogleMapsPlaces _placesList =
      GoogleMapsPlaces(apiKey: "AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM");

  late Uint8List imageMarker;

  getImageMarker() async {
    imageMarker = await getByteFromAsset('assets/logo.png', 200);
  }

  static Future<Uint8List> getByteFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  Future<LatLng?> getUserLocation() async {
    final location = LocationManager.Location();
    LocationManager.LocationData? locationData;
    try {
      locationData = await location.getLocation();
      final lat = locationData.latitude;
      final lng = locationData.longitude;
      final center = LatLng(lat!, lng!);
      userLocation = center;
      setState(() {

      });
      return center;
    } on Exception {
      locationData = null;
      return null;
    }
  }

  Future<LatLng> getPeerLocation() async {
    var snap = await FirebaseCredentials()
        .db
        .collection('User')
        .doc(widget.peerId)
        .get();
    return LatLng(snap.data()!['latitude'], snap.data()!['longitude']);
  }

  getLoc() async {
    if (kDebugMode) {
      print("on getLoc");
    }
    await getCurrentLocation().then((value) async {
      if (kDebugMode) {
        print("$value the value on current location");
      }
      if (!value.isUnknown()) {
        var coord = LatLng(value.latitude!, value.longitude!);
        cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: coord,
          zoom: getZoomLevel(
              (GeoUtils.capRadius(double.parse(radius.toString())) * 1000))!,
        ));
        GeoFirestore geoFirestore =
            GeoFirestore(FirebaseCredentials().db.collection('User'));

        final queryLocation = GeoPoint(value.latitude!, value.longitude!);
        final List<DocumentSnapshot> documents =
            await geoFirestore.getAtLocation(
                queryLocation, double.parse(radius.toString()) * 1000);
        for (var document in documents) {
          if (kDebugMode) {
            print("the documents before marker ${document.id}");
          }
          await _setMarkers(document);
        }
        setState(() {});
      }
    }, onError: (error) {
      if (kDebugMode) {
        print("$error the error");
      }
    });
  }

  getRadius() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    radius = (prefs.containsKey('radius') ? prefs.getInt('radius') : 10)!;
  }

  setRadius(int radius) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('radius', radius);
  }

  // ignore: missing_return
  getCorrespondingPet(String petId) async {
    DocumentSnapshot shot =
        await FirebaseFirestore.instance.collection("Pet").doc(petId).get();
    Map<String, dynamic> map = shot.data() as Map<String, dynamic>;
    return map['images'][0];
  }

  Future<bool> checkMatch(String ownerId) async {
    /*bool matched = false;
    await FirebaseFirestore.instance.collection('Pet').where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser.uid).get().then((value) {
      for(int i=0;i < value.docs.length;i++){
        if(value.docs[i].data().containsKey(ownerId) && value.docs[i].data()[ownerId]==1){
          matched = true;
        }
      }
    });
    return matched;*/
    bool matched = false;
    bool otherMatched = false;
    await FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) async {
      await FirebaseFirestore.instance
          .collection('Pet')
          .where('ownerId', isEqualTo: ownerId)
          .get()
          .then((other) {
        for (int i = 0; i < value.docs.length; i++) {
          if (value.docs[i].data().containsKey(ownerId) &&
              value.docs[i].data()[ownerId] == 1) {
            matched = true;
          }
        }
        if (matched) {
          for (int i = 0; i < other.docs.length; i++) {
            if (other.docs[i]
                    .data()
                    .containsKey(FirebaseAuth.instance.currentUser!.uid) &&
                other.docs[i].data()[FirebaseAuth.instance.currentUser!.uid] ==
                    1) {
              otherMatched = true;
            }
          }
        }
      });
    });
    return matched && otherMatched;
  }

  Future<void> _setMarkers(DocumentSnapshot point) async {
    Map<String, dynamic> map = point.data() as Map<String, dynamic>;
    String imageUrl = '';
    bool isMatched = false;
    if (point.id == FirebaseAuth.instance.currentUser!.uid) {
      isMatched = true;
    } else {
      isMatched = await checkMatch(point.id);
    }

    if (kDebugMode) {
      print(
          "isMatched $isMatched and id=${point.id} with my=${FirebaseAuth.instance.currentUser!.uid}");
    }

    if (isMatched) {
      if (map['visible'] &&
          !map.containsKey('block_${FirebaseAuth.instance.currentUser!.uid}')) {
        petId = point['pet'][0];
        bool havePet = false;
        await FirebaseFirestore.instance
            .collection("Pet")
            .doc(petId)
            .get()
            .then((value) {
          imageUrl = value.data()!['images'][0];
          havePet = value.data()!['haveMyPet'];
        });
        if (kDebugMode) {
          print("getMarkerImage $point ${imageUrl} ${point['pet'][0]}");
        }
        await Helper.getMarkerImage(point, imageUrl, point['pet'][0],
                havePet ? Colors.green : const Color(0xFFF20554), context)
            .then((marker) {
          _markers.add(marker);
          setState(() {});
          if (kDebugMode) {
            print("the markers $_markers");
          }
        });
      }
    }
  }

  void refreshForPetDetail() async {
    await getLoc();
  }

  void refresh() async {
    final peerCenter = await getPeerLocation();
    getNearbyPlaces(peerCenter);
  }

  void getNearbyPlaces(LatLng center) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final location = Location(lat: center.latitude, lng: center.longitude);
    final result =
        await _placesList.searchNearbyWithRadius(location, 30000, type: 'park');
    isLoading = false;
    if (kDebugMode) {
      print("$result the markers");
    }
    if (result.status == "OK") {
      places = result.results;
      for (var f in result.results) {
        String id = f.placeId;
        _markers.add(Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(0.7),
          markerId: MarkerId(id),
          position: LatLng(f.geometry!.location.lat, f.geometry!.location.lng),
          visible: true,
          infoWindow: InfoWindow(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return SizedBox(
                        height: 300,
                        width: 200,
                        child: Dialog(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Share :",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.pink,
                                          fontSize: 15),
                                    ),
                                    InkWell(
                                      onTap: () => Navigator.of(context).pop(),
                                      child: const Icon(
                                        Icons.cancel_outlined,
                                        color: Colors.black,
                                        size: 24,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  InkWell(
                                    onTap: () async {
                                      SharedPreferences prefs =
                                          await SharedPreferences.getInstance();

                                      String myId =
                                          FirebaseAuth.instance.currentUser!.uid;
                                      String? groupChatId =
                                          prefs.getString("groupChatId");

                                      String mapImageUrl = Uri(
                                        scheme: 'https',
                                        host: 'maps.googleapis.com',
                                        port: 443,
                                        path: '/maps/api/staticmap',
                                        queryParameters: {
                                          'center':
                                              '${f.geometry!.location.lat},${f.geometry!.location.lng}',
                                          'zoom': '18',
                                          'size': '500x500',
                                          'maptype': 'roadmap',
                                          'key':
                                              'AIzaSyABFmjpW4zSizocefrOcxVOXjzr0kZNsmM',
                                          'markers':
                                              'color:red|${f.geometry!.location.lat},${f.geometry!.location.lng}'
                                        },
                                      ).toString();
                                      /*if (id.hashCode <= widget.peerId.hashCode) {
                                          groupChatId = '$myId-${widget.peerId}';
                                        } else {
                                          groupChatId = '${widget.peerId}-$myId';
                                        }*/
                                      var time = DateTime.now()
                                          .millisecondsSinceEpoch
                                          .toString();
                                      var documentReference = FirebaseFirestore
                                          .instance
                                          .collection('messages')
                                          .doc(groupChatId)
                                          .collection(groupChatId!)
                                          .doc(time);

                                      FirebaseFirestore.instance
                                          .runTransaction((transaction) async {
                                        transaction.set(
                                          documentReference,
                                          {
                                            'idFrom': myId,
                                            'idTo': widget.peerId,
                                            'timestamp': DateTime.now()
                                                .millisecondsSinceEpoch,
                                            'content': mapImageUrl,
                                            'type': 3,
                                            'thumb': 'N/A'
                                          },
                                        );
                                      }).whenComplete(() async {
                                        Navigator.of(context).pop();
                                      });
                                    },
                                    child: SizedBox(
                                      height: 130,
                                      width: 100,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(10.0),
                                            child: Image.asset(
                                              "assets/logo@3xUpdated.png",
                                              width: 70,
                                              height: 70,
                                            ),
                                          ),
                                          Text(
                                            "pettag",
                                            style: TextStyle(
                                              color: Colors.red[900],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      if (kDebugMode) {
                                        print(
                                            'MAP SHARE URL ::::::::: https://www.google.com/maps/search/?api=1&query=${f.geometry!.location.lat},${f.geometry!.location.lng}');
                                      }
                                      Share.share(
                                          'https://www.google.com/maps/search/?api=1&query=${f.geometry!.location.lat},${f.geometry!.location.lng}');
                                    },
                                    child: SizedBox(
                                      height: 130,
                                      width: 100,
                                      child: Column(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Image.asset(
                                              "assets/shareIcon.png",
                                              width: 60,
                                              height: 60,
                                            ),
                                          ),
                                          Text(
                                            "Other Apps",
                                            style: TextStyle(
                                              color: Colors.red[900],
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    });
              },
              title: f.name,
              snippet:
                  "Ratings : ${f.rating != null ? f.rating.toString() : '0'}"),
        ));
      }
    } else {
      errorMessage = result.errorMessage!;
    }
    setState(() {});
    if (kDebugMode) {
      print("$_markers the markers");
    }
  }

  double? getZoomLevel(double radius) {
    double? zoomLevel = 11;
    if (radius > 0) {
      double radiusElevated = radius + radius / 2;
      double scale = radiusElevated / 500;
      zoomLevel = 23 - math.log(scale) / math.log(2);
    }
    zoomLevel = double.parse(zoomLevel.toStringAsFixed(2));
    if (kDebugMode) {
      print("zoomlevel $zoomLevel");
    }
    return zoomLevel;
  }

  QuerySnapshot? myOwnPets;

  @override
  void initState() {
    super.initState();
    getRadius();

    if (mounted) {
      getUserLocation();
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        myOwnPets = await FirebaseFirestore.instance
            .collection("Pet")
            .where("ownerId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get();
        Map<String, dynamic> data =
            myOwnPets!.docs.first.data() as Map<String, dynamic>;
        if (kDebugMode) {
          print("the map data");
          print(data);
        }
        widget.isVisible = data['visible'];
        if (widget.isVisible!) {
          leftColors = Colors.pink;
          widget.isVisible = true;
          rightColors = Colors.white;
          rightIconColor = Colors.black12;
          leftIconColor = Colors.white;
        } else {
          rightColors = Colors.pink;
          rightIconColor = Colors.white;
          leftIconColor = Colors.black12;
          leftColors = Colors.white;
          widget.isVisible = false;
        }
        cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: const LatLng(0.0, 0.0),
          zoom: getZoomLevel(
              (GeoUtils.capRadius(double.parse(radius.toString())) * 1000))!,
        ));
        await getLoc();
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    _markers.clear();
    //mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          extendBodyBehindAppBar: true,
          key: _scaffoldKey,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            actions: [
              InkWell(
                onTap: () async {
                  // myOwnPets = await FirebaseFirestore.instance
                  //     .collection("Pet")
                  //     .where("ownerId",
                  //         isEqualTo: FirebaseAuth.instance.currentUser.uid)
                  //     .get();
                  // Map<String, dynamic> data =
                  //     myOwnPets.docs.first.data() as Map<String, dynamic>;
                  await FirebaseFirestore.instance
                      .collection('User')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get()
                      .then((value) {
                    setState(() {
                      widget.isVisible = value.data()!['visible'];
                      if (widget.isVisible!) {
                        leftColors = Colors.pink;
                        widget.isVisible = true;
                        rightColors = Colors.white;
                        rightIconColor = Colors.black12;
                        leftIconColor = Colors.white;
                      } else {
                        rightColors = Colors.pink;
                        rightIconColor = Colors.white;
                        leftIconColor = Colors.black12;
                        leftColors = Colors.white;
                        widget.isVisible = false;
                      }
                    });
                  });
                  await showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          elevation: 0,
                          child: StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return Container(
                                height: 300,
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      const Text(
                                        "Invisible Mode",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Center(
                                        child: Stack(
                                          children: [
                                            Container(
                                              height: 35,
                                              width: 90,
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(30),
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
                                                    widget.isVisible = true;
                                                    rightColors = Colors.white;
                                                    rightIconColor =
                                                        Colors.black12;
                                                    leftIconColor =
                                                        Colors.white;
                                                    FirebaseFirestore.instance
                                                        .collection("User")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser
                                                            !.uid)
                                                        .update({
                                                      'visible': true,
                                                    });
                                                    FirebaseFirestore.instance
                                                        .collection("Pet")
                                                        .doc(petId)
                                                        .update({
                                                      'visible': true,
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  width: 41,
                                                  height: 33,
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: widget.isVisible!
                                                        ? Colors.pink
                                                        : Colors.white ,
                                                  ),
                                                  child: Image.asset(
                                                    "assets/visiblePet.png",
                                                    height: 15,
                                                    width: 15,
                                                    color: leftIconColor ??
                                                        Colors.white,
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
                                                    rightIconColor =
                                                        Colors.white;
                                                    leftIconColor =
                                                        Colors.black12;
                                                    leftColors = Colors.white;
                                                    widget.isVisible = false;
                                                    FirebaseFirestore.instance
                                                        .collection("User")
                                                        .doc(FirebaseAuth
                                                            .instance
                                                            .currentUser!
                                                            .uid)
                                                        .update({
                                                      'visible': false,
                                                    });
                                                    FirebaseFirestore.instance
                                                        .collection("Pet")
                                                        .doc(petId)
                                                        .update({
                                                      'visible': true,
                                                    });
                                                  });
                                                },
                                                child: Container(
                                                  width: 41,
                                                  height: 33,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            30),
                                                    color: widget.isVisible!
                                                        ? Colors.white
                                                        : Colors.pink ,
                                                  ),
                                                  child: Image.asset(
                                                    "assets/invisiblePet.png",
                                                    height: 15,
                                                    width: 15,
                                                    color: rightIconColor ??
                                                        Colors.black12,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Text(
                                        "Have My Pet",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                          color: Colors.black,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      ListView.builder(
                                          shrinkWrap: true,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemCount: myOwnPets!.docs.length,
                                          itemBuilder: (context, index) {
                                            Map<String, dynamic> data =
                                                myOwnPets!.docs[index].data()
                                                    as Map<String, dynamic>;

                                            return HavePetDialogContent(
                                                e: myOwnPets!.docs[index] as QueryDocumentSnapshot<Map<String, dynamic>>,
                                                isYes: data.containsKey(
                                                        'haveMyPet')
                                                    ? data['haveMyPet']
                                                    : true);
                                          }),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                        /*SimpleDialog(
                          backgroundColor: Colors.white,
                          title: Text(
                            "Don't have my pet",
                            style: TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          elevation: 4,
                          contentPadding: EdgeInsets.all(16),
                          titlePadding: EdgeInsets.all(20),
                          children: myOwnPets.docs.map((e) {
                            return HavePetDialogContent(e: e, isYes: e.data().containsKey('haveMyPet') ? e.data()['haveMyPet'] : true);
                          }).toList(),
                        );*/
                      }).whenComplete(() async {
                    myOwnPets = await FirebaseFirestore.instance
                        .collection("Pet")
                        .where("ownerId",
                            isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                        .get();
                    setState(() {
                      Map<String, dynamic> data =
                          myOwnPets!.docs.first.data() as Map<String, dynamic>;
                      getRadius();
                      widget.isVisible = data['visible'];
                      if (widget.isVisible!) {
                        leftColors = Colors.pink;
                        widget.isVisible = true;
                        rightColors = Colors.white;
                        rightIconColor = Colors.black12;
                        leftIconColor = Colors.white;
                      } else {
                        rightColors = Colors.pink;
                        rightIconColor = Colors.white;
                        leftIconColor = Colors.black12;
                        leftColors = Colors.white;
                        widget.isVisible = false;
                      }
                      cameraUpdate =
                          CameraUpdate.newCameraPosition(CameraPosition(
                        target: const LatLng(0.0, 0.0),
                        zoom: getZoomLevel((GeoUtils.capRadius(
                                double.parse(radius.toString())) *
                            1000))!,
                      ));
                    });
                    _markers.clear();

                    if (widget.isChatSide!) {
                      refresh();
                      await getLoc();
                    } else {
                      refreshForPetDetail();
                    }
                    setState(() {});
                  });
                },
                child: Container(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                  height: 25,
                  width: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          children: [
                            const SizedBox(
                              height: 22,
                              width: 24,
                            ),
                            Image.asset(
                              "assets/man.png",
                              color: Colors.black54,
                              width: 20,
                              height: 20,
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                    // sportsList.any((e) => e.contains('cricket'))
                                    color: myOwnPets != null &&
                                            myOwnPets!.docs.any((element) =>
                                                (element.data() as Map<String,
                                                    dynamic>)['haveMyPet'] ==
                                                true)
                                        ? Colors.green
                                        : Colors.redAccent,
                                    shape: BoxShape.circle),
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.keyboard_arrow_down_sharp,
                          color: Colors.black54,
                          size: 15,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          //drawer: Drawerr(),
          body: Stack(
            children: [
              userLocation == null ? const Center() : GoogleMap(
                // circles: circles,
                onMapCreated: (GoogleMapController controller) {
                  mapController = controller;
                  widget.isChatSide! ? refresh() : refreshForPetDetail();
                 // mapController.animateCamera(cameraUpdate);
                },
                initialCameraPosition: CameraPosition(
                  target: userLocation!,
                  zoom: getZoomLevel(
                      (GeoUtils.capRadius(double.parse(radius.toString())) *
                          1000))!,
                ),
                gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
                mapType: MapType.normal,
                markers: _markers,
                myLocationEnabled: false,
              ),

              /*Positioned(
                left: 10,
                bottom: 10,
                child: FloatingActionButton.extended(
                  heroTag: "chooseDistanceBtn",
                  onPressed: () async{
                    await _showDoubleDialog();
                    getRadius();
                    print("Radius Value : $radius");
                    getLoc(context);
                  },
                  label: Text(
                    'Choose Distance',
                  ),
                  icon: Icon(
                    Icons.location_searching,
                    color: Colors.white,
                  ),
                ),
              )*/
            ],
          )),
    );
  }
}

class HavePetDialogContent extends StatefulWidget {
  QueryDocumentSnapshot<Map<String, dynamic>> e;
  bool isYes;

  HavePetDialogContent({Key? key,required this.e, required this.isYes}) : super(key: key);

  @override
  State createState() => _HavePetDialogContentState();
}

class _HavePetDialogContentState extends State<HavePetDialogContent> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      margin: const EdgeInsets.only(bottom: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.redAccent, width: 1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    bottomLeft: Radius.circular(10))),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(9), bottomLeft: Radius.circular(9)),
              child: Image.network(
                widget.e.data()['images'][0],
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(
            width: 5,
          ),
          Text(
            widget.e.data()['name'],
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isYes ? Colors.green : Colors.transparent,
            ),
            child: Center(
              child: InkWell(
                onTap: () {
                  widget.e.reference.set({
                    'haveMyPet': true,
                  }, SetOptions(merge: true));
                  setState(() {
                    widget.isYes = true;
                  });
                },
                child: Text(
                  "Yes",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: widget.isYes ? Colors.white : Colors.grey,
                      fontSize: 12),
                ),
              ),
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isYes ? Colors.transparent : Colors.redAccent,
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(9),
                bottomRight: Radius.circular(9),
              ),
            ),
            child: Center(
              child: InkWell(
                  onTap: () {
                    widget.e.reference.set({
                      'haveMyPet': false,
                    }, SetOptions(merge: true));
                    setState(() {
                      widget.isYes = false;
                    });
                  },
                  child: Text(
                    "No",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: widget.isYes ? Colors.grey : Colors.white,
                        fontSize: 12),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}

/*Dialog(
                          child: StatefulBuilder(builder: (BuildContext context, StateSetter setState){
                            return Container(
                              width: 400,
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
                                              myOwnPets.docs.forEach((element) async {
                                                await element.reference.set({
                                                  'haveMyPet': true,
                                                }, SetOptions(merge: true));
                                              });
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
                                            myOwnPets.docs.forEach((element) async {
                                              await element.reference.set({
                                                'haveMyPet': false,
                                              }, SetOptions(merge: true));
                                            });
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
                            );
                          },),
                        );*/
