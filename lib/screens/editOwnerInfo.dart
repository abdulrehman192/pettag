import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/models/owner_model.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/addMediaWidget.dart';
import 'package:pettag/widgets/customCard.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

class EditOwnerInfoScreen extends StatefulWidget {
  static const String editOwnerInfoScreenRoute = "EditOwnerInfoScreen";

  final String? id;

  const EditOwnerInfoScreen({Key? key, this.id}) : super(key: key);

  @override
  _EditOwnerInfoScreenState createState() => _EditOwnerInfoScreenState();
}

class _EditOwnerInfoScreenState extends State<EditOwnerInfoScreen> {
  int age = 1;
  String? gender;
  String petSize  = '';
  int ownerIndex = 0;
  bool isLoading = false;

  final FirebaseAuth auth = FirebaseAuth.instance;

  ImagePicker imagePicker = ImagePicker();
  final Pet _pet = Pet();

  final TextEditingController userFirstname = TextEditingController();
  final TextEditingController userLastname = TextEditingController();
  final TextEditingController userDescription = TextEditingController();
  final TextEditingController shelterName = TextEditingController();
  final TextEditingController shelterPhone = TextEditingController();
  final TextEditingController shelterEmail = TextEditingController();
  final TextEditingController shelterWeb = TextEditingController();

  List<dynamic> ownerImages = [];
  final List<File> _ownerImages = [];
  List<dynamic> urlsOwner = [];
  File? petImage1;
  bool ownerVisibility = false;
  int _ownerState = 4;
  int index = 0;

  uploadOwnerImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      urlsOwner.add(value);
      ownerIndex++;
      if (ownerIndex == _ownerImages.length) {
        _pet.images = urlsOwner;
        _ownerImages.clear();
        await FirebaseCredentials()
            .db
            .collection('User')
            .doc(widget.id)
            .update({'images': FieldValue.arrayUnion(urlsOwner)}).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        uploadOwnerImage(_ownerImages[ownerIndex]);
      }
    });
  }

  showInSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  getPreviousData() async {
    FirebaseFirestore.instance
        .collection("User")
        .doc(widget.id)
        .get()
        .then((value) {
      setState(() {
        age = value.data()!['age'];
        gender = value.data()!['gender'];
        userDescription.text = value.data()!['description'];
      });
    });
  }

  @override
  void initState() {
    getPreviousData();
    super.initState();
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
            color: Colors.redAccent,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const LocaleText(
          "profile_title",
          style: TextStyle(
              fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 16.0, right: 20.0, left: 20.0, bottom: 0),
        child: FutureBuilder(
            future: FirebaseFirestore.instance
                .collection("User")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic> map =
                    snapshot.data!.data() as Map<String, dynamic>;
                return CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          CustomCard(
                            // height: 105,
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
                                      overlayShape:
                                          const RoundSliderOverlayShape(
                                              overlayRadius: 25.0),
                                    ),
                                    child: Slider(
                                      value: age.toDouble(),
                                      min: 0,
                                      max: 100,
                                      onChanged: (double newValue) {
                                        setState(() {
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
                            // height: 105,
                            child: Padding(
                              padding:
                                  const EdgeInsets.only(top: 14.0, left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const LocaleText(
                                    "gender",
                                    style: pinkHeadingStyle,
                                  ),
                                  DropdownButtonFormField(
                                    isExpanded: false,
                                    decoration: InputDecoration(
                                      fillColor: Colors.white,
                                      filled: true,
                                      hintText: "Female",
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
                                          borderRadius:
                                              BorderRadius.circular(30),
                                          borderSide: const BorderSide(
                                            color: Colors.transparent,
                                          )),
                                    ),
                                    value: gender,
                                    items: ['Male', 'Female']
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
                            // height: 130,
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
                                    padding: const EdgeInsets.only(
                                        left: 4.0, right: 10),
                                    child: TextFormField(
                                      controller: userDescription,
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
                          (map.containsKey('profileType') &&
                                  map['profileType'] == "pettag Rescuer")
                              ? CustomCard(
                                  // height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Shelter Name",
                                          style: pinkHeadingStyle,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 10),
                                          child: TextFormField(
                                            controller: shelterName,
                                            textInputAction:
                                                TextInputAction.next,
                                            maxLength: 100,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    maxLength}) =>
                                                null,
                                            decoration: const InputDecoration(
                                                hintText: "Enter Shelter Name",
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
                                )
                              : Container(),
                          (map.containsKey('profileType') &&
                                  (map['profileType'] == "pettag Rescuer" ||
                                      map['profileType'] == "pettag Breeder"))
                              ? CustomCard(
                                  // height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Shelter Phone",
                                          style: pinkHeadingStyle,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 10),
                                          child: TextFormField(
                                            controller: shelterPhone,
                                            textInputAction:
                                                TextInputAction.next,
                                            maxLength: 100,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    maxLength}) =>
                                                null,
                                            decoration: const InputDecoration(
                                                hintText: "Enter Shelter Phone",
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
                                )
                              : Container(),
                          (map.containsKey('profileType') &&
                                  (map['profileType'] == "pettag Rescuer" ||
                                      map['profileType'] == "pettag Breeder"))
                              ? CustomCard(
                                  // height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "Shelter Email",
                                          style: pinkHeadingStyle,
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 10),
                                          child: TextFormField(
                                            controller: shelterEmail,
                                            textInputAction:
                                                TextInputAction.next,
                                            maxLength: 100,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    maxLength}) =>
                                                null,
                                            decoration: const InputDecoration(
                                                hintText: "Enter Shelter Email",
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
                                )
                              : Container(),
                          (map.containsKey('profileType') &&
                                  (map['profileType'] == "pettag Rescuer" ||
                                      map['profileType'] == "pettag Breeder"))
                              ? CustomCard(
                                  // height: 120,
                                  width: MediaQuery.of(context).size.width,
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: const TextSpan(
                                            text: 'Shelter Website ',
                                            style: pinkHeadingStyle,
                                            children: <TextSpan>[
                                              TextSpan(
                                                  text: '(Optional)',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w300,
                                                      color: Colors.grey,
                                                      fontSize: 13)),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left: 4.0, right: 10),
                                          child: TextFormField(
                                            controller: shelterWeb,
                                            textInputAction:
                                                TextInputAction.next,
                                            maxLength: 100,
                                            buildCounter: (context,
                                                    {required currentLength,
                                                    required isFocused,
                                                    maxLength}) =>
                                                null,
                                            decoration: const InputDecoration(
                                                hintText:
                                                    "Enter Shelter Website",
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
                                )
                              : Container(),
                          const SizedBox(
                            height: 15,
                          ),
                          const LocaleText(
                            "add_media",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFC3548),
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                    SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 15.0,
                        crossAxisSpacing: 15.0,
                        childAspectRatio: 8.0 / 12.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseCredentials()
                                .db
                                .collection('User')
                                .doc(widget.id)
                                .snapshots(),
                            builder: (context,
                                AsyncSnapshot<DocumentSnapshot> snapshot) {
                              if (snapshot.hasData) {
                                Map<String, dynamic> data =
                                    snapshot.data!.data() as Map<String, dynamic>;
                                ownerImages = data['images'] ?? [];
                                if (index < ownerImages.length) {
                                  ownerVisibility = true;
                                  _ownerState = 0;
                                } else if (_ownerImages.length >
                                    index - ownerImages.length) {
                                  ownerVisibility = true;
                                  _ownerState = 1;
                                } else {
                                  ownerVisibility = false;
                                }
                                return AddMediaWidget(
                                  isEmpty: ownerVisibility,
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
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                const Padding(
                                                  padding: EdgeInsets.only(
                                                      left: 10.0),
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
                                                      // padding: const EdgeInsets.all( 0),
                                                      child: const LocaleText(
                                                        "cancel",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                                                    ImageSource
                                                                        .gallery);
                                                        setState(() {
                                                          ownerVisibility =
                                                              true;
                                                          if (pickedFile !=
                                                              null) {
                                                            petImage1 = File(
                                                                pickedFile
                                                                    .path);
                                                            _ownerImages
                                                                .add(petImage1!);
                                                            print(
                                                                "Owner Images Length : ${_ownerImages.length}");
                                                          } else {
                                                            print(
                                                                'No image selected.');
                                                          }
                                                          //_btnController.reset();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const LocaleText(
                                                        "gallery",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.black,
                                                        ),
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        var pickedFile =
                                                            await imagePicker.pickImage(
                                                                source:
                                                                    ImageSource
                                                                        .camera);
                                                        setState(() {
                                                          ownerVisibility =
                                                              true;
                                                          if (pickedFile !=
                                                              null) {
                                                            petImage1 = File(
                                                                pickedFile
                                                                    .path);
                                                            _ownerImages
                                                                .add(petImage1!);
                                                          } else {
                                                            print(
                                                                'No image captured.');
                                                          }
                                                          //_btnController.reset();
                                                        });
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      child: const LocaleText(
                                                        "camera",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
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
                                      },
                                    );
                                  },
                                  onTapCancel: () {
                                    if (index < ownerImages.length) {
                                      print('State : $_ownerState');
                                      FirebaseFirestore.instance
                                          .collection("User")
                                          .doc(widget.id)
                                          .update({
                                        "images": FieldValue.arrayRemove(
                                            [ownerImages[index]])
                                      });
                                      print("Deleted : ${ownerImages[index]}");
                                      ownerImages.removeAt(index);
                                    } else {
                                      setState(() {
                                        _ownerImages.removeAt(
                                            index - ownerImages.length);
                                      });
                                    }
                                  },
                                  index: ownerIndex,
                                  array: ownerImages,
                                  docId: widget.id,
                                  child: (index < ownerImages.length)
                                      ? ownerImages[index] != null
                                          ? Image.network(
                                              ownerImages[index],
                                              fit: BoxFit.cover,
                                            )
                                          : Container()
                                      : (_ownerImages.isNotEmpty &&
                                              (index - ownerImages.length) <
                                                  _ownerImages.length)
                                          ? Image.file(
                                              _ownerImages[
                                                  (index) - ownerImages.length],
                                              fit: BoxFit.cover,
                                            )
                                          : Container(),
                                );
                              }

                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  backgroundColor: Colors.pink,
                                ),
                              );
                            },
                          );
                        },
                        childCount: 3,
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    backgroundColor: Colors.pink,
                                  ))
                                : GenericBShadowButton(
                                    onPressed: () async {
                                      if (map.containsKey('profileType') &&
                                          map['profileType'] ==
                                              'pettag Rescuer') {
                                        if (age == 1 ||
                                            gender == null ||
                                            userDescription.text == null ||
                                            shelterName.text == null ||
                                            shelterPhone.text == null ||
                                            shelterEmail.text == null) {
                                          showInSnackBar(
                                              "Some of the fields are empty");
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await FirebaseFirestore.instance
                                              .collection("User")
                                              .doc(widget.id)
                                              .set({
                                            'age': age,
                                            'gender': gender,
                                            'description': userDescription.text,
                                            'shelterName': shelterName.text,
                                            'shelterPhone': shelterPhone.text,
                                            'shelterEmail': shelterEmail.text,
                                            'shelterWeb': shelterWeb.text
                                          }, SetOptions(merge: true));

                                          if (_ownerImages.isNotEmpty) {
                                            Timer(const Duration(seconds: 3),
                                                () async {
                                              index = 0;
                                              ownerIndex = 0;
                                              await uploadOwnerImage(
                                                  _ownerImages[0]);
                                            });
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      } else if (map
                                              .containsKey('profileType') &&
                                          map['profileType'] ==
                                              'pettag Breeder') {
                                        if (age == 1 ||
                                            gender == null ||
                                            userDescription.text == null ||
                                            shelterPhone.text == null ||
                                            shelterEmail.text == null) {
                                          showInSnackBar(
                                              "Some of the fields are empty");
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await FirebaseFirestore.instance
                                              .collection("User")
                                              .doc(widget.id)
                                              .set({
                                            'age': age,
                                            'gender': gender,
                                            'description': userDescription.text,
                                            'shelterPhone': shelterPhone.text,
                                            'shelterEmail': shelterEmail.text,
                                            'shelterWeb': shelterWeb.text
                                          }, SetOptions(merge: true));

                                          if (_ownerImages.isNotEmpty) {
                                            Timer(const Duration(seconds: 3),
                                                () async {
                                              index = 0;
                                              ownerIndex = 0;
                                              await uploadOwnerImage(
                                                  _ownerImages[0]);
                                            });
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      } else {
                                        if (age == 1 ||
                                            gender == null ||
                                            userDescription.text == null) {
                                          showInSnackBar(
                                              "Some of the fields are empty");
                                        } else {
                                          setState(() {
                                            isLoading = true;
                                          });
                                          await FirebaseFirestore.instance
                                              .collection("User")
                                              .doc(widget.id)
                                              .set({
                                            'age': age,
                                            'gender': gender,
                                            'description': userDescription.text
                                          }, SetOptions(merge: true));

                                          if (_ownerImages.isNotEmpty) {
                                            Timer(const Duration(seconds: 3),
                                                () async {
                                              index = 0;
                                              ownerIndex = 0;
                                              await uploadOwnerImage(
                                                  _ownerImages[0]);
                                            });
                                          } else {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }
                                        }
                                      }
                                    },
                                    buttonText:
                                        Locales.string(context, 'save_changes'),
                                    width:
                                        MediaQuery.of(context).size.width / 2.5,
                                    height: 50,
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ]),
                    ),
                  ],
                );
              } else {
                return Container();
              }
            }),
      ),
      /*SingleChildScrollView(
        padding: EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              */ /*CustomCard(
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left:12.0, top:14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "FirstName",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:4.0, right:10),
                        child: TextFormField(
                          controller: userFirstname,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: "FirstName",
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
                height: 90,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(left:12.0, top:14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "LastName",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left:4.0, right:10),
                        child: TextFormField(
                          controller: userLastname,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: "LastName",
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
              ),*/ /*
              CustomCard(
                height: 92,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, right: 15, left: 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            "Owner Age",
                            style: pinkHeadingStyle,
                          ),
                          Spacer(),
                          Text(
                            "${age.toDouble().toString()} yr.",
                            style: TextStyle(
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
                          thumbShape:
                          RoundSliderThumbShape(enabledThumbRadius: 10.0),
                          overlayShape:
                          RoundSliderOverlayShape(overlayRadius: 25.0),
                        ),
                        child: Slider(
                          value: age.toDouble(),
                          min: 1,
                          max: 100,
                          onChanged: (double newValue) {
                            setState(() {
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
                height: 90,
                child: Padding(
                  padding: const EdgeInsets.only(top: 14.0, left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Gender",
                        style: pinkHeadingStyle,
                      ),
                      DropdownButtonFormField(
                        isExpanded: false,
                        decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          hintText: "Female",
                          contentPadding: EdgeInsets.all(8.0),
                          hintStyle: hintTextStyle.copyWith(
                            color: Colors.black87,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Colors.transparent,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                              borderSide: BorderSide(
                                color: Colors.transparent,
                              )),
                        ),
                        value: gender,
                        items: ['Male', 'Female']
                            .map<DropdownMenuItem<String>>(
                                (String value) => DropdownMenuItem(
                              child: Text(value),
                              value: value,
                            ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            gender = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              CustomCard(
                height: 120,
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description",
                        style: pinkHeadingStyle,
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: userDescription,
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                              {currentLength, isFocused, maxLength}) =>
                          null,
                          decoration: InputDecoration(
                              hintText: "Enter Description (Max 100 characters)",
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
              SizedBox(height: 10,),
              InkWell(
                onTap: () async{
                   if(age!=0 && userDescription.text!=null && gender!=null){
                     FirebaseCredentials().db.collection("User").doc(widget.id).update(
                         {
                           'age': age,
                           'description': userDescription.text,
                           'gender' : gender,
                         }).then((value) => Navigator.pop(context,));
                   }
                   else{

                   }
                },
                child: CustomCard(
                  height: 60,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: Text(
                      "Save Changes",
                      style: TextStyle(
                          color: Colors.redAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),*/
    );
  }
}

class petDropdownWidgetCard extends StatefulWidget {
  petDropdownWidgetCard({
    Key? key,
    required this.variable,
    required this.title,
    required this.hintText,
    required this.list,
  }) : super(key: key);

  dynamic variable;
  String title;
  String hintText;
  List<String> list;

  @override
  _petDropdownWidgetCardState createState() => _petDropdownWidgetCardState();
}

class _petDropdownWidgetCardState extends State<petDropdownWidgetCard> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      width: MediaQuery.of(context).size.width,
      // height: 95,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, left: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: pinkHeadingStyle,
            ),
            DropdownButtonFormField(
              isExpanded: false,
              decoration: InputDecoration(
                fillColor: Colors.white,
                filled: true,
                hintText: widget.hintText,
                contentPadding: const EdgeInsets.all(8.0),
                hintStyle: hintTextStyle.copyWith(
                  color: Colors.black38,
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
              value: widget.variable,
              items: widget.list
                  .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem(
                            value: value,
                            child: Text(value),
                          ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  widget.variable = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class petAgeSliderWidget extends StatefulWidget {
  petAgeSliderWidget({
    Key? key,
    required this.age,
  }) : super(key: key);

  int age;

  @override
  _petAgeSliderWidgetState createState() => _petAgeSliderWidgetState();
}

class _petAgeSliderWidgetState extends State<petAgeSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      // height: 100,
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0, right: 15, left: 10),
        child: Column(
          children: [
            Row(
              children: [
                const Text(
                  "Preferable Age",
                  style: pinkHeadingStyle,
                ),
                const Spacer(),
                Text(
                  "${widget.age.toString()} yr.",
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
                activeTrackColor: appBarBgColor,
                trackHeight: 2,
                inactiveTrackColor: Colors.black26,
                thumbColor: const Color(0xFFEB1555),
                //overlayColor: Color(0x29EB1555),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 10.0),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 25.0),
              ),
              child: Slider(
                value: widget.age.toDouble(),
                min: 1,
                max: 100,
                onChanged: (double newValue) {
                  setState(() {
                    widget.age = newValue.round();
                  });
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
