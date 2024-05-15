import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:geocoding/geocoding.dart';
import 'package:pettag/widgets/small_action_buttons.dart';
import 'package:pettag/widgets/reportDialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' show cos, sqrt, asin;
import 'package:maps_toolkit/maps_toolkit.dart' as mp;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../constant.dart';
import 'ownerProfile.dart';

class PetProfileScreen extends StatefulWidget {
  static const String petProfileScreenRouteName = 'PetProfileScreen';
  final String? docId;
  final String? ownerId;
  final bool? isJustPreview;

  const PetProfileScreen({this.docId, this.ownerId,  this.isJustPreview});

  @override
  _PetProfileScreenState createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends State<PetProfileScreen> {
  final controller = PageController(viewportFraction: 1, keepPage: true);
  String _linkMessage = '';
  final bool _isCreatingLink = false;
  List<Placemark> placemarks = [Placemark(locality: "-", country: "-")];
  var lat = 0.0;
  var lng = 0.0;
  double distance = 0.0;
  String ownerName = '';
  FirebaseAuth auth = FirebaseAuth.instance;

  late OwnerMod _ownerMod;

  TextEditingController shelterName = TextEditingController();
  TextEditingController shelterPhone = TextEditingController();
  TextEditingController shelterEmail = TextEditingController();
  TextEditingController shelterWeb = TextEditingController();
  FirebaseDynamicLinks dynamicLinks = FirebaseDynamicLinks.instance;

  createUrl(String imageUrl) async {
    final DynamicLinkParameters parameters = DynamicLinkParameters(
      uriPrefix: 'https://socialapppettag.page.link',
      link: Uri.parse(
          "https://pettag-d02f6.web.app?petId=${widget.docId}&ownerId=${widget.ownerId}"),
      androidParameters: const AndroidParameters(
        packageName: "com.utechware.socialapppettag",
      ),
      iosParameters: const IOSParameters(
        bundleId: "com.utechware.socialapppettag",
      ),
      socialMetaTagParameters: SocialMetaTagParameters(
        title: "PetTag",
        imageUrl: Uri.parse(
          imageUrl,
        ),
      ),
    );
    dynamicLinks.buildShortLink(parameters).then((ShortDynamicLink value) async {
      if (value != null) {
        await FlutterShare.share(
            title: "PetTag",
            linkUrl: value.shortUrl.toString(),
            chooserTitle: 'Share with');
      }
    });
  }

  getAddress(Map<String, dynamic> data) async {
    var lat = data['latitude'];
    var lng = data['longitude'];
    placemarks = await placemarkFromCoordinates(lat, lng);
    setState(() {});
  }

  final List imgList = [
    'assets/3x/Icon awesome-star@3x.png',
    'assets/3x/Icon awesome-heart@3x.png',
    'assets/2x/cross-sign@2x.png'
  ];

  updateInteraction({status}) {
    FirebaseFirestore.instance
        .collection('Pet')
        .doc(widget.docId)
        .set({auth.currentUser!.uid: status}, SetOptions(merge: true));
  }

  calculateDistance(lat2, lon2, lat1, lon1) {
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

  getLatLng() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    lat = data['latitude'];
    lng = data['longitude'];
    ownerName = data['firstName'];

    getAddress(data);
  }

  Future<List<DocumentSnapshot<Map<String, dynamic>>>> getData() async {
    List<DocumentSnapshot<Map<String, dynamic>>> dataSnapshots = [];
    await FirebaseFirestore.instance
        .collection('User')
        .doc(widget.ownerId)
        .get()
        .then((value) {
      dataSnapshots.add(value);
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection('Pet')
          .doc(widget.docId)
          .get()
          .then((value) {
        dataSnapshots.add(value);
      });
    });
    return dataSnapshots;
  }

  late SharedPreferences prefs;
  Future<void> initializeSharedPreferences()async {
    prefs = await SharedPreferences.getInstance();
  }


  @override
  void initState() {
    super.initState();
    initializeSharedPreferences();
    getLatLng();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: widget.isJustPreview == null || widget.isJustPreview == true
          ? Container()
          : Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  height: 30,
                  width: double.infinity,
                  decoration: const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.white,
                      blurRadius: 15,
                      spreadRadius: 15,
                      offset: Offset(1, 1),
                    )
                  ]),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SmallActionButtons(
                      onPressed: () {
                        //updateInteraction(status: 0);
                        Navigator.pop(context, true);
                      },
                      height: 50,
                      width: 50,
                      icon: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(2),
                        child: Image.asset("assets/2x/cross-sign@2x.png"),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SmallActionButtons(
                      onPressed: () {
                        //updateInteraction(status: 2);
                        Navigator.pop(context, true);
                      },
                      height: 50,
                      width: 50,
                      icon: Container(
                        height: 40,
                        width: 40,
                        padding: const EdgeInsets.all(2),
                        child:
                            Image.asset("assets/3x/Icon awesome-star@3x.png"),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    SmallActionButtons(
                      width: 50,
                      height: 50,
                      onPressed: () {
                        //updateInteraction(status: 1);
                        Navigator.pop(context, true);
                      },
                      icon: Container(
                        width: 40,
                        height: 40,
                        padding: const EdgeInsets.all(2),
                        child:
                            Image.asset("assets/3x/Icon awesome-heart@3x.png"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
      body: SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                    future: getData(),
                    builder: (context,
                        AsyncSnapshot<List<DocumentSnapshot<Map<String, dynamic>>>> snapshot) {
                      if (snapshot.data?.last.data() != null) {
                        Map<String, dynamic> data = snapshot.data?.last.data() as Map<String, dynamic>;
                        Map<String, dynamic>? first = snapshot.data?.first.data() as Map<String, dynamic>;
                        _ownerMod = OwnerMod(
                          bio: first["description"] ?? '',
                          ownerImages: first["images"] ?? [],
                          id: snapshot.data!.first.id ?? '',
                          name: first["firstName"] ?? '',
                          shelterEmail: first['shelterEmail'] ?? "",
                          ownerImage:  first['owner_image'] ?? "",
                          shelterName: first['shelterName'] ?? "",
                          shelterPhone: first['shelterPhone'] ?? "",
                          shelterWeb:first['shelterWeb'] ??  "",
                        );
                        shelterName.text = _ownerMod.shelterName!;
                        shelterPhone.text = _ownerMod.shelterPhone!;
                        shelterEmail.text = _ownerMod.shelterEmail!;
                        shelterWeb.text = _ownerMod.shelterWeb!;
                        List<dynamic> images = data['images'] ?? [];
                        if (data.containsKey('Latitude') ||
                            data.containsKey('longitude')) {
                          distance = mp.SphericalUtil.computeDistanceBetween(
                            mp.LatLng(data['latitude'], data['longitude']),
                            mp.LatLng(lat, lng),
                          ).toDouble();
                          //distance = calculateDistance(lat, lng, data['latitude'], data['longitude']);
                          distance = (distance / 1000);
                        }
                        return Stack(
                          children: [
                            Column(
                              children: [
                                SizedBox(
                                  height: 500,
                                  width: MediaQuery.of(context).size.width,
                                  child: PageView.builder(
                                    controller: controller,
                                    itemCount: images.length,
                                    itemBuilder: (_, index) {
                                      return Image.network(
                                              images[index],
                                              fit: BoxFit.cover,
                                            );
                                    },
                                  ),
                                ),
                                SmoothPageIndicator(
                                  controller: controller,
                                  count:  images.length,
                                  effect: const WormEffect(),
                                ),
                                Container(
                                  // height: 800,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: RichText(
                                          text: TextSpan(
                                              text: '${data['name']}, ',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              children: <TextSpan>[
                                                TextSpan(
                                                    text: '${data['age']}',
                                                    style: const TextStyle(
                                                      color: Colors.black54,
                                                      fontSize: 25,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                    ))
                                              ]),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          children: [
                                            const Icon(
                                              Icons.location_on,
                                              size: 13,
                                              color: Colors.black38,
                                            ),
                                            Text(
                                              getCardDistance(data),
                                              style: const TextStyle(
                                                  color: Colors.black45,
                                                  fontSize: 15),
                                            )
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 10.0),
                                        child: Text(
                                          "${placemarks.first.locality} ${placemarks.first.country}",
                                          style: const TextStyle(
                                              color: Colors.black45,
                                              fontSize: 15),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            border: Border.all(
                                                color: Colors.redAccent,
                                                width: 2),
                                          ),
                                          child: Text(
                                            data['profileType'],
                                            style: const TextStyle(
                                                color: Colors.redAccent,
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 16.0, right: 16.0, top: 16.0),
                                        child: LocaleText(
                                          "about",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Container(
                                          child: Text(
                                            "${data['description']}",
                                            style: const TextStyle(
                                                color: Colors.black45,
                                                fontSize: 15),
                                          ),
                                        ),
                                      ),
                                      /*Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          color: Colors.black38,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          createUrl(images[0]);
                                        },
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                    "SHARE ${data['name']}'s PROFILE",
                                                    style: TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                Text(
                                                  "SEE WHAT A FRIEND THINKS",
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          color: Colors.black38,
                                        ),
                                      ),
                                      Center(
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return ReportDialog();
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text("REPORT ${data['name'].toString().toUpperCase()}",
                                                style: TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ),*/
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          color: Colors.black38,
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: LocaleText(
                                          "owner_info",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          print("OWNER ID :::::::::::::::::::::::::: ${_ownerMod.id}");
                                          print("Owner Images : ${_ownerMod.ownerImages}");
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return OwnerProfile(
                                              ownerId: _ownerMod.id!,
                                              isPreview: true,
                                            );
                                          }));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 10),
                                          child: Container(
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      child: Container(
                                                        width:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                        height:
                                                            MediaQuery.of(context)
                                                                    .size
                                                                    .width *
                                                                0.2,
                                                        decoration: BoxDecoration(
                                                          image: DecorationImage(
                                                            image: NetworkImage(_ownerMod.ownerImages!.isNotEmpty
                                                              ? _ownerMod.ownerImages!.first.toString()
                                                              : "https://as2.ftcdn.net/v2/jpg/00/65/77/27/500_F_65772719_A1UV5kLi5nCEWI0BNLLiFaBPEkUbv5Fv.jpg"), fit: BoxFit.cover,),
                                                          color: Colors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(15),
                                                          border: Border.all(color: mainColor, width: 1)
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 20,
                                                    ),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          _ownerMod.name!,
                                                          style: const TextStyle(
                                                              color: Colors.black,
                                                              fontSize: 18,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        SizedBox(
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width -
                                                              150,
                                                          child: Text(
                                                            _ownerMod.bio ??
                                                                "Description",
                                                            style: const TextStyle(
                                                                color: Colors
                                                                    .black45,
                                                                fontSize: 13,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .normal),
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      (data.containsKey('profileType') && data['profileType'] == 'pettag Rescuer') ? const Padding(
                                        padding: EdgeInsets.only(
                                            left: 16, right: 16, bottom: 10),
                                        child: Text(
                                          "Shelter Info",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ) : Container(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 5),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            (data.containsKey('profileType') && data['profileType'] == 'pettag Rescuer') ? SizedBox(
                                              height: 40,
                                              width: MediaQuery.of(context).size.width*0.45,
                                              child: TextField(
                                                controller: shelterName,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                                  filled: false,
                                                  labelText: 'Name',
                                                  hintText: _ownerMod.shelterName,
                                                  hintStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(width: 1, color: mainColor)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(width: 1, color: mainColor)
                                                  ),
                                                ),
                                              ),
                                            ) : Container(),
                                            (data.containsKey('profileType') && (data['profileType'] == 'pettag Rescuer')) ? SizedBox(
                                              height: 40,
                                              width: MediaQuery.of(context).size.width*0.45,
                                              child: TextField(
                                                controller: shelterPhone,
                                                readOnly: true,
                                                decoration: InputDecoration(
                                                  contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                                  filled: false,
                                                  labelText: 'Phone',
                                                  hintText: _ownerMod.shelterPhone,
                                                  hintStyle: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 16,
                                                  ),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(width: 1, color: mainColor)
                                                  ),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(10),
                                                      borderSide: const BorderSide(width: 1, color: mainColor)
                                                  ),
                                                ),
                                              ),
                                            ) : Container(),
                                          ],
                                        ),
                                      ),
                                      (data.containsKey('profileType') && (data['profileType'] == 'pettag Breeder')) ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 5),
                                        child: SizedBox(
                                         height: 40,
                                         width: MediaQuery.of(context).size.width*0.45,
                                         child: TextField(
                                           controller: shelterPhone,
                                           readOnly: true,
                                           decoration: InputDecoration(
                                             contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                             filled: false,
                                             labelText: 'Phone',
                                             hintText: _ownerMod.shelterPhone,
                                             hintStyle: const TextStyle(
                                               color: Colors.black,
                                               fontSize: 16,
                                             ),
                                             enabledBorder: OutlineInputBorder(
                                                 borderRadius: BorderRadius.circular(10),
                                                 borderSide: const BorderSide(width: 1, color: mainColor)
                                             ),
                                             focusedBorder: OutlineInputBorder(
                                                 borderRadius: BorderRadius.circular(10),
                                                 borderSide: const BorderSide(width: 1, color: mainColor)
                                             ),
                                           ),
                                         ),
                                            ),
                                      ) :Container(),
                                      (data.containsKey('profileType') && (data['profileType'] == 'pettag Rescuer' || data['profileType'] == 'pettag Breeder')) ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 5),
                                        child: SizedBox(
                                          height: 40,
                                          child: TextField(
                                            controller: shelterEmail,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                              filled: false,
                                              labelText: 'Email',
                                              hintText: _ownerMod.shelterEmail,
                                              hintStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(width: 1, color: mainColor)
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(width: 1, color: mainColor)
                                              ),
                                            ),
                                          ),
                                        ),
                                      ) : Container(),
                                      (data.containsKey('profileType') && (data['profileType'] == 'pettag Rescuer' || data['profileType'] == 'pettag Breeder')) ? Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16.0, vertical: 5),
                                        child: SizedBox(
                                          height: 40,
                                          child: TextField(
                                            controller: shelterWeb,
                                            readOnly: true,
                                            decoration: InputDecoration(
                                              contentPadding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 15),
                                              filled: false,
                                              labelText: 'Website',
                                              hintText: _ownerMod.shelterWeb,
                                              hintStyle: const TextStyle(
                                                color: Colors.black,
                                                fontSize: 16,
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(width: 1, color: mainColor)
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                  borderSide: const BorderSide(width: 1, color: mainColor)
                                              ),
                                            ),
                                          ),
                                        ),
                                      ) : Container(),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 10),
                                        child: LocaleText(
                                          "image_gallery",
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      _ownerMod.ownerImages!.isEmpty
                                          ? const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 16),
                                              child: Center(
                                                  child: LocaleText("no_image_found")),
                                            )
                                          : Padding(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 16.0, vertical: 10),
                                              child: SizedBox(
                                                height: _ownerMod.ownerImages!
                                                                .length %
                                                            3 ==
                                                        0
                                                    ? 150 *
                                                        (_ownerMod.ownerImages!
                                                                .length /
                                                            3)
                                                    : 150 *
                                                        ((_ownerMod.ownerImages!
                                                                    .length /
                                                                3) +
                                                            1),
                                                child: GridView.builder(
                                                    shrinkWrap: true,
                                                    physics:
                                                        const NeverScrollableScrollPhysics(),
                                                    gridDelegate:
                                                        const SliverGridDelegateWithMaxCrossAxisExtent(
                                                            maxCrossAxisExtent:
                                                                140,
                                                            childAspectRatio:
                                                                3 / 4,
                                                            crossAxisSpacing: 10,
                                                            mainAxisSpacing: 10),
                                                    itemCount: _ownerMod
                                                        .ownerImages!.length,
                                                    itemBuilder:
                                                        (BuildContext ctx,
                                                            index) {
                                                      return ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                20),
                                                        child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20),
                                                            ),
                                                            child: Image.network(
                                                              _ownerMod
                                                                      .ownerImages![
                                                                  index],
                                                              fit: BoxFit.cover,
                                                            )),
                                                      );
                                                    }),
                                              ),
                                            ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          color: Colors.black38,
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () {
                                          createUrl(images[0]);
                                        },
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              children: [
                                                Text(
                                                    "SHARE ${data['name']}'s PROFILE",
                                                    style: const TextStyle(
                                                        color: Colors.redAccent,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold)),
                                                const LocaleText(
                                                  "see_what_friend_thinks",
                                                  style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Divider(
                                          color: Colors.black38,
                                        ),
                                      ),
                                      FirebaseAuth.instance.currentUser!.uid != _ownerMod.id ? Center(
                                        child: InkWell(
                                          onTap: () {
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return ReportDialog(ownerId: _ownerMod.id, petId: data['petId'],);
                                              },
                                            );
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                                "REPORT ${data['name'].toString().toUpperCase()}",
                                                style: const TextStyle(
                                                    color: Colors.black45,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        ),
                                      ) : Container(),
                                      const SizedBox(
                                        height: 70,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              right: 16,
                              top: 470,
                              child: FloatingActionButton(
                                backgroundColor: Colors.redAccent,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Image.asset(
                                    "assets/icon/down-arrow.png",
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }
                      return  Container(
                        alignment: Alignment.center,
                        width: double.maxFinite,
                        height: MediaQuery.of(context).size.height,
                        child: const SizedBox(
                          width: 50,
                          height: 50,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.pinkAccent,
                          ),
                        ),
                      );
                    }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: key,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
              color: Colors.pink[900],
            ),
          ),
        ],
      ),
    );
  }

  Row buildRowActionButton(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //mainAxisSize: MainAxisSize.max,
      children: [
        /*SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            height: 30,
            width: 30,
            padding: EdgeInsets.all(2),
            child: Icon(
              FontAwesomeIcons.redo,
              color: Colors.black26,
            ),
          ),
        ),*/
        SmallActionButtons(
          onPressed: () {},
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
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            height: 40,
            width: 40,
            padding: const EdgeInsets.all(2),
            child: Image.asset("assets/3x/Icon awesome-star@3x.png"),
          ),
        ),
        SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            width: 40,
            height: 40,
            padding: const EdgeInsets.all(2),
            child: Image.asset("assets/icon/Group 381.png"),
            //child: Image.asset("assets/3x/Icon awesome-heart@3x.png"),
          ),
        ),
        /*SmallActionButtons(
          onPressed: () {},
          height: 40,
          width: 40,
          icon: Container(
            padding: EdgeInsets.all(2),
            child: Image.asset("assets/2x/flash@2x.png"),
          ),
        ),*/
      ],
    );
  }

  String getCardDistance(Map<String, dynamic> data) {

    final distanceType = prefs.getString('distUnit') ?? 'Km';
    print('---> distance is: $distanceType');
    if(distanceType.contains('Km')) {
      return "${(mp.SphericalUtil.computeDistanceBetween(
          mp.LatLng(lat, lng), mp.LatLng(data['latitude'], data['longitude'])) /
          1000).round().toStringAsFixed(2)} Km Away";
    }else {

      return "${(mp.SphericalUtil.computeDistanceBetween(
          mp.LatLng(lat, lng), mp.LatLng(data['latitude'], data['longitude'])) /
          1609).round().toStringAsFixed(2)} Miles Away";
    }
  }

}

class OwnerMod {
  String? name;
  String? id;
  String? bio;
  List<dynamic>? ownerImages;
  String? shelterName;
  String? shelterPhone;
  String? shelterEmail;
  String? shelterWeb;
  String? ownerImage;

  OwnerMod(
      {this.name,
      this.bio,
      this.id,
      this.ownerImages,
      this.shelterEmail,
      this.shelterName,
      this.shelterPhone,
      this.shelterWeb,
      this.ownerImage});
}
