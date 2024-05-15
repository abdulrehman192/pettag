import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/main.dart';
import 'package:pettag/models/owner_model.dart';
import 'package:pettag/models/packageDetail.dart';
import 'package:pettag/repo/paymentRepo.dart' as repo;
import 'package:pettag/screens/all_profiles.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/register_screen.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/customCard.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddNewProfileScreen extends StatefulWidget {
  static const String addNewProfileScreenRoute = "AddNewProfileScreen";

  const AddNewProfileScreen({this.package});

  final PackageDetail? package;

  @override
  _AddNewProfileScreenState createState() => _AddNewProfileScreenState();
}

class _AddNewProfileScreenState extends State<AddNewProfileScreen> {
  int age = 1;
  int ownerAge = 1;
  int index = 0;
  String? gender;
  String? ownerGender;
  String? petSize;
  String petVal = '';
  String type = '';
  double val = 0;
  File? petImage1;
  File? ownerImage;
  File? petImage2;
  File? petImage3;
  File? petImage4;
  File? petImage5;
  File? petImage6;
  File? petImage7;
  File? petImage8;
  File? petImage9;
  bool isLoading = false;
  var lat = 0.0;
  var lng = 0.0;

  final List<File> _images = [];
  List<String> urls = [];

  ImagePicker imagePicker = ImagePicker();

//  Person  _person = Person();
  final Pet _pet = Pet();
  LocationNotifier locationNotifier = LocationNotifier(<String, dynamic>{});
  Map<String, dynamic> locMap = {};

  final FirebaseAuth auth = FirebaseAuth.instance;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  List<String> uploadedImages = [];

  final TextEditingController userFirstname = TextEditingController();
  final TextEditingController userLastname = TextEditingController();
  final TextEditingController userDescription = TextEditingController();
  final TextEditingController petName = TextEditingController();
  final TextEditingController petAge = TextEditingController();
  final TextEditingController petBreed = TextEditingController();
  final TextEditingController petBehaviour = TextEditingController();
  final TextEditingController petDescription = TextEditingController();
  final TextEditingController ownerDescription = TextEditingController();

  storeRemaining(int remaining) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("Remaining", remaining);
  }

  getPetType() async {
    type = sharedPrefs.petType;
  }

  getLatLng() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    lat = data['latitude'];
    lng = data['longitude'];
    _pet.geoHash = data['geoHash'];
  }

  deleteCurrentUser() async {
    try {
      await FirebaseFirestore.instance
          .collection("User")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .delete();
      await FirebaseAuth.instance.currentUser!.delete();
    }catch(e){
      debugPrint('Delete user exception: $e');
    }
  }

  getPreviousData() async {
    FirebaseFirestore.instance
        .collection("User")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      setState(() {
        ownerAge = value.data()!['age'];
        gender = value.data()!['gender'];
        userDescription.text = value.data()!['description'];
      });
    });
  }

  Future<bool> _onWillPop() async {
    return widget.package == null
        ? (await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () async {
                    if (widget.package == null) {
                      await deleteCurrentUser();
                      Navigator.of(context).pop(true);
                    }
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ))
        : false;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPetType();
    getLatLng();
    locationNotifier.addListener(() {
      locMap = locationNotifier.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(
            splashColor: Colors.transparent,
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.pink,
              size: 22,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const LocaleText(
            "add_new_profile",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black54,
                fontWeight: FontWeight.bold),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: CustomScrollView(
              slivers: <Widget>[
                SliverList(
                  delegate: SliverChildListDelegate([
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LocaleText(
                        "add_pet_detail",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_name",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petName,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.name = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                    hintText: "Pet-Name",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 14.0, right: 15, left: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const LocaleText(
                                  "pet_age",
                                  style: pinkHeadingStyle,
                                ),
                                const Spacer(),
                                Text(
                                  "${age.toDouble().toString()} yr.",
                                  style: const TextStyle(
                                    color: Colors.black38,
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
                              child: Slider(
                                value: age.toDouble(),
                                min: 1,
                                max: 29,
                                onChanged: (double newValue) {
                                  setState(() {
                                    _pet.age = newValue.round();
                                    age = newValue.round();
                                  });
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_sex",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value) {
                                return value == null ? "Required Field*" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: Locales.string(context, 'pet_sex'),
                                contentPadding: const EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: gender,
                              items: ['Male', 'Female']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            value: value,
                                            child:
                                                LocaleText(value.toLowerCase()),
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.sex = value.toString();
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
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_size",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value) {
                                return value == null ? "Required Field*" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: Locales.string(context, 'small'),
                                contentPadding: const EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: petSize,
                              items: ['Small', 'Medium', 'Large', 'extra_large']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            value: value,
                                            child:
                                                LocaleText(value.toLowerCase()),
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.size = value.toString();
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
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_type",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value) {
                                return value == null ? "Required Field*" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: Locales.string(context, 'dog'),
                                contentPadding: const EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: petSize,
                              items: ['Dog', 'Cat']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            value: value,
                                            child:
                                                LocaleText(value.toLowerCase()),
                                          ))
                                  .toList(),
                              onChanged: (value) {
                                setState(() {
                                  _pet.type = value.toString();
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
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_breed",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petBreed,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.breed = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                    hintText: "Pet-Breed",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_behaviour",
                              style: pinkHeadingStyle,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: petBehaviour,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                onChanged: (value) {
                                  setState(() {
                                    _pet.behaviour = value;
                                  });
                                },
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                decoration: const InputDecoration(
                                    hintText:
                                        "Pet-Behaviour (Max 100 characters)",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "pet_description",
                              style: pinkHeadingStyle,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TextFormField(
                              controller: petDescription,
                              validator: (value) {
                                return value!.isEmpty ? "Required Field*" : null;
                              },
                              onChanged: (value) {
                                setState(() {
                                  _pet.description = value;
                                });
                              },
                              textInputAction: TextInputAction.next,
                              maxLength: 100,
                              buildCounter: (context,
                                      {required currentLength, required isFocused, maxLength}) =>
                                  null,
                              decoration: const InputDecoration(
                                hintText:
                                    "Enter Description (Max 100 characters)",
                                hintStyle: TextStyle(
                                  fontWeight: FontWeight.normal,
                                ),
                                border: InputBorder.none,
                              ),
                              textAlign: TextAlign.left,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LocaleText(
                        "add_owner_detail",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, left: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "owner_gender",
                              style: pinkHeadingStyle,
                            ),
                            DropdownButtonFormField(
                              isExpanded: false,
                              validator: (value) {
                                return value == null ? "Required Field*" : null;
                              },
                              decoration: InputDecoration(
                                fillColor: Colors.white,
                                filled: true,
                                hintText: Locales.string(context, 'owner_sex'),
                                contentPadding: const EdgeInsets.all(8.0),
                                hintStyle: hintTextStyle.copyWith(
                                  color: Colors.black87,
                                ),
                                border: InputBorder.none,
                              ),
                              value: ownerGender,
                              items: ['Male', 'Female']
                                  .map<DropdownMenuItem<String>>(
                                      (String value) => DropdownMenuItem(
                                            value: value,
                                            child:
                                                LocaleText(value.toLowerCase()),
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
                    const SizedBox(
                      height: 10,
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 14.0, right: 15, left: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                const LocaleText(
                                  "owner_age",
                                  style: pinkHeadingStyle,
                                ),
                                const Spacer(),
                                Text(
                                  "${ownerAge.toDouble().floor().toString()} yr.",
                                  style: const TextStyle(
                                    color: Colors.black38,
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
                              child: Slider(
                                value: ownerAge.toDouble(),
                                min: 0.0,
                                max: 100.0,
                                onChanged: (double newValue) {
                                  setState(() {
                                    ownerAge = newValue.round();
                                  });
                                  // _person.age = newValue.round().floor();
                                },
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "owner_description",
                              style: pinkHeadingStyle,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: ownerDescription,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                /* onChanged: (value) {
                                  setState(() {
                                    _person.description = value;
                                  });
                                },*/
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                decoration: const InputDecoration(
                                    hintText:
                                        "Enter Description (Max 100 characters)",
                                    hintStyle: TextStyle(
                                      fontWeight: FontWeight.normal,
                                    ),
                                    border: InputBorder.none),
                                textAlign: TextAlign.left,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "owner_image",
                              style: pinkHeadingStyle,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.only(left: 4.0, right: 10),
                              child:  InkWell(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return Dialog(
                                          backgroundColor: Colors.white,
                                          elevation: 5,
                                          insetPadding: const EdgeInsets.symmetric(
                                              horizontal: 30.0, vertical: 24.0),
                                          child: Container(
                                            height: 150,
                                            //  width: double.infinity,
                                            padding: const EdgeInsets.all(10),
                                            child: Column(
                                              crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                              children: [
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0, top: 10),
                                                  child: LocaleText(
                                                    "upload_image",
                                                    style: TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 17,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(left: 10.0),
                                                  child: LocaleText(
                                                    "select_photo",
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                ),
                                                const Spacer(),
                                                Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      // padding: const EdgeInsets.all(0),
                                                      child: const LocaleText(
                                                        "cancel",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var pickedFile =
                                                        await imagePicker.pickImage(
                                                            source:
                                                            ImageSource.gallery);
                                                        setState(() {
                                                          if (pickedFile != null) {
                                                            ownerImage =
                                                                File(pickedFile.path);
                                                          } else {
                                                            print('No image selected.');
                                                          }
                                                        });
                                                        Navigator.of(context).pop();
                                                      },
                                                      // padding: const EdgeInsets.all(0),
                                                      child: const LocaleText(
                                                        "gallery",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var pickedFile =
                                                        await imagePicker.pickImage(
                                                            source:
                                                            ImageSource.camera);
                                                        setState(() {
                                                          if (pickedFile != null) {
                                                            ownerImage =
                                                                File(pickedFile.path);
                                                          } else {
                                                            print('No image captured.');
                                                          }
                                                        });
                                                        Navigator.of(context).pop();
                                                      },
                                                      // padding: const EdgeInsets.all(0),
                                                      child: const LocaleText(
                                                        "camera",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            ),
                                          ),
                                        );
                                      });
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(11),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black45,
                                        width: 1,
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: ownerImage != null
                                        ? SizedBox(
                                      height: 100.0,
                                          width: 150.0,
                                          child: Image.file(
                                      ownerImage!,
                                      fit: BoxFit.cover,
                                    ),
                                        )
                                        : const Icon(
                                      Icons.add,
                                      color: Colors.black,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: LocaleText(
                        "add_pet_media",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 25,
                          foreground: Paint()..shader = linearGradient,
                        ),
                      ),
                    ),
                  ]),
                ),
                SliverGrid.count(
                  crossAxisCount: 3,
                  childAspectRatio: 4 / 3,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  children: [
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                insetPadding: const EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 24.0),
                                child: Container(
                                  height: 150,
                                  //  width: double.infinity,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: LocaleText(
                                          "upload_image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: LocaleText(
                                          "select_photo",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1!);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "gallery",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage1 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage1!);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "camera",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(11),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage1 != null
                              ? Image.file(
                                  petImage1!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: LocaleText(
                                          "upload_image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: LocaleText(
                                          "select_photo",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage2 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage2!);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "gallery",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage2 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage2!);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "camera",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage2 != null
                              ? Image.file(
                                  petImage2!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: LocaleText(
                                          "upload_image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: LocaleText(
                                          "select_photo",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage3 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage3!);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "gallery",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage3 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage3!);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "camera",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage3 != null
                              ? Image.file(
                                  petImage3!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: LocaleText(
                                          "upload_image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: LocaleText(
                                          "select_photo",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage4 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage4!);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "gallery",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage4 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage4!);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "camera",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage4 != null
                              ? Image.file(
                                  petImage4!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return Dialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                child: Container(
                                  height: 150,
                                  width: 350,
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.only(
                                            left: 10.0, top: 10),
                                        child: LocaleText(
                                          "upload_image",
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 17,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.only(left: 10.0),
                                        child: LocaleText(
                                          "select_photo",
                                          style: TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "cancel",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.gallery);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage5 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage5!);
                                                } else {
                                                  print('No image selected.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "gallery",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          ElevatedButton(
                                            onPressed: () async {
                                              var pickedFile =
                                                  await imagePicker.pickImage(
                                                      source:
                                                          ImageSource.camera);
                                              setState(() {
                                                if (pickedFile != null) {
                                                  petImage5 =
                                                      File(pickedFile.path);
                                                  _images.add(petImage5!);
                                                } else {
                                                  print('No image captured.');
                                                }
                                              });
                                              Navigator.of(context).pop();
                                            },
                                            // padding: const EdgeInsets.all(0),
                                            child: const LocaleText(
                                              "camera",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            });
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.black45,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: petImage5 != null
                              ? Image.file(
                                  petImage5!,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(
                                  Icons.add,
                                  color: Colors.black,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                              strokeWidth: 2,
                              backgroundColor: Colors.red,
                            ))
                          : GenericBShadowButton(
                              buttonText:
                                  Locales.string(context, 'save_changes'),
                              onPressed: () async {
                                if (_images.isEmpty) {
                                  Fluttertoast.showToast(
                                      msg:
                                          "Atleast select one image of your pet.");
                                }
                                if (_formKey.currentState!.validate() &&
                                    _images.isNotEmpty) {
                                  if (widget.package != null) {
                                    Map<String, dynamic> myMap = {
                                      "pkgName": widget.package!.pkgName,
                                      "price": widget.package!.price,
                                      "profileCount":
                                          widget.package!.profileCount,
                                      "time": widget.package!.time,
                                      "remaining": widget.package!.remaining! - 1,
                                    };
                                    PackageDetail pkgDetail =
                                        PackageDetail.fromJson(myMap);
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final User? user = auth.currentUser;
                                    final uid = user!.uid;
                                    _pet.ownerId = uid;
                                    //_pet.type = type;
                                    repo.storePkgInfo(pkgDetail);
                                    repo.pkg.value = pkgDetail;
                                    repo.pkg.notifyListeners();
                                    debugPrint('---> ownerImage: $ownerImage');
                                    if(ownerImage != null) {
                                     await uploadOwnerImage(ownerImage!);
                                    }
                                    await uploadImageForAllProfile(_images[0]);
                                  } else {
                                    setState(() {
                                      isLoading = true;
                                    });
                                    final User? user = auth.currentUser;
                                    final uid = user!.uid;
                                    _pet.ownerId = uid;
                                    _pet.type = type;
                                    SharedPreferences prefs =
                                        await SharedPreferences.getInstance();
                                    if (prefs.containsKey("packageDetail")) {
                                      prefs.remove("packageDetail");
                                    }
                                    await uploadImage(_images[0]);
                                  }
                                }
                                //Navigator.popAndPushNamed(context, AllProfiles.allProfilesScreenRoute);
                              },
                              width: MediaQuery.of(context).size.width / 1.4,
                              height: 50,
                            ),
                    ),
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  uploadOwnerImage(File image) async {
    String fileName = image.path.split('/').last;

    var reference =
    firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {

        _pet.images = urls;
        var id = FirebaseCredentials().db.collection('Pet').doc().id;
        _pet.petId = id;
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(auth.currentUser!.uid)
            .set({
          "pet": FieldValue.arrayUnion([id]),
          "profileType": widget.package!.pkgName,
          'age': ownerAge,
          'gender': ownerGender,
          'owner_image' : value.toString(),
          'description': ownerDescription.text,
        }, SetOptions(merge: true));



    });
  }

  uploadImageForAllProfile(File image) async {
    String fileName = image.path.split('/').last;

    var reference =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      //setState(() {
      urls.add(value);
      index++;
      //});
      if (index == _images.length) {
        _pet.images = urls;
        var id = FirebaseCredentials().db.collection('Pet').doc().id;
        _pet.petId = id;
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(auth.currentUser!.uid)
            .set({
          "pet": FieldValue.arrayUnion([id]),
          "profileType": widget.package!.pkgName,
          'age': ownerAge,
          'gender': ownerGender,
          'description': ownerDescription.text,
        }, SetOptions(merge: true));

        await FirebaseCredentials()
            .db
            .collection('Pet')
            .where("ownerId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
            .get()
            .then((value) {
          for (var element in value.docs) {
            element.reference.update({'profileType': widget.package!.pkgName});
          }
        });
        _pet.latitude = lat;
        _pet.longitude = lng;
        _pet.lockStatus = false;
        _pet.visible = true;
        _pet.haveMyPet = true;
        _pet.profileType = widget.package!.pkgName;
        _pet.ownerGender = ownerGender;
        _pet.ownerAge = ownerAge;
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(id)
            .set(_pet.toMap(), SetOptions(merge: true))
            .whenComplete(() {
          Navigator.pushReplacementNamed(
              context, AllProfiles.allProfilesScreenRoute);
        });
      } else {
        uploadImageForAllProfile(_images[index]);
      }
    });
  }

  uploadImage(File image) async {
    String fileName = image.path.split('/').last;

    var reference =
        firebase_storage.FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      urls.add(value);
      index++;
      if (index == _images.length) {
        _pet.images = urls;
        var id = FirebaseCredentials().db.collection('Pet').doc().id;
        _pet.petId = id;
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(auth.currentUser!.uid)
            .set({
          'pet': FieldValue.arrayUnion([id]),
          'age': ownerAge,
          'gender': ownerGender,
          'description': ownerDescription.text,
        }, SetOptions(merge: true));

        _pet.latitude = lat;
        _pet.longitude = lng;
        _pet.visible = true;
        _pet.haveMyPet = true;
        _pet.lockStatus = false;
        _pet.profileType = "PetTag Standard";
        _pet.ownerGender = ownerGender;
        _pet.ownerAge = ownerAge;
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(id)
            .set(_pet.toMap(), SetOptions(merge: true))
            .whenComplete(() => Navigator.pushReplacementNamed(
                context, PetSlideScreen.petSlideScreenRouteName));
      } else {
        uploadImage(_images[index]);
      }
    });
  }
}
