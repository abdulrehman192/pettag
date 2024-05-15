import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/customCard.dart';

class EditInfoScreen extends StatefulWidget {
  static const String editInfoScreenRoute = "EditInfoScreen";

  String? id;
  String? ownerId;
  bool? isPro = false;
  String? petName;

  EditInfoScreen({super.key,  this.id,  this.ownerId,  this.isPro,  this.petName});

  @override
  _EditInfoScreenState createState() => _EditInfoScreenState();
}

class _EditInfoScreenState extends State<EditInfoScreen> {
  int age = 1;
  int ownerAge = 18;
  String? gender;
  String? petSize;
  String name = '';
  String breed = '';
  String behaviour = '';
  String description = '';
  bool isLoading = false;
  String firstName = '';
  String lastName = '';
  String ownerDescription = '';

  final FirebaseAuth auth = FirebaseAuth.instance;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController userFirstname = TextEditingController();
  final TextEditingController userLastname = TextEditingController();
  final TextEditingController userDescription = TextEditingController();
  final TextEditingController petNameController = TextEditingController();
  final TextEditingController petAge = TextEditingController();
  final TextEditingController petBreed = TextEditingController();
  final TextEditingController petBehaviour = TextEditingController();
  final TextEditingController petDescription = TextEditingController();

  getPreviousPetData() async {
    await FirebaseCredentials()
        .db
        .collection("Pet")
        .doc(widget.id)
        .get()
        .then((value) {
      setState(() {
        age = value.data()!['age'];
        gender = value.data()!['sex'];
        petSize = value.data()!['size'];
        name = value.data()!['name'];
        petNameController.text = name;
        breed = value.data()!['breed'];
        petBreed.text = breed;
        behaviour = value.data()!['behaviour'];
        petBehaviour.text = behaviour;
        description = value.data()!['description'];
        petDescription.text = description;
      });
    });
  }

  getPreviousOwnerData() async {
    await FirebaseFirestore.instance
        .collection("User")
        .doc(widget.ownerId)
        .get()
        .then((value) {
      ownerAge = value.data()!['age'] < 18 ? 18 : value.data()!['age'];
      userFirstname.text = value.data()!['firstName'];
      userLastname.text = value.data()!['lastName'];
      userDescription.text = value.data()!["description"];
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPreviousPetData();
    getPreviousOwnerData();
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16, bottom: 0, left: 16, right: 16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const LocaleText(
                "profile_title",
                style: pinkHeadingStyle,
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
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petNameController,
                          validator: (value) {
                            return value!.isEmpty ? "Required Field*" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: name,
                              hintStyle: const TextStyle(
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
              /*petAgeSliderWidget(
                age: age,
              ),*/
              CustomCard(
                width: MediaQuery.of(context).size.width,
                child: Padding(
                  padding:
                      const EdgeInsets.only(top: 14.0, right: 15, left: 12),
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
                          value: age.toDouble() ?? 1,
                          min: 1,
                          max: 29,
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
                          hintText: gender,
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
                                      child: Text(Locales.string(
                                          context, value.toLowerCase())),
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
                          hintText: petSize ?? "Select Size",
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
                                      child: Text(Locales.string(
                                          context, value.toLowerCase())),
                                    ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            petSize = value.toString();
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
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petBreed,
                          validator: (value) {
                            return value!.isEmpty ? "Required Field*" : null;
                          },
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                              hintText: breed,
                              hintStyle: const TextStyle(
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
                  padding: const EdgeInsets.only(left: 12.0, top: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LocaleText(
                        "pet_behaviour",
                        style: pinkHeadingStyle,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petBehaviour,
                          validator: (value) {
                            return value!.isEmpty ? "Required Field*" : null;
                          },
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                                  {required currentLength, required isFocused, maxLength}) =>
                              null,
                          decoration: InputDecoration(
                              hintText: behaviour ??
                                  "Pet-Behaviour (Max 100 characters)",
                              hintStyle: const TextStyle(
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
                      Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 10),
                        child: TextFormField(
                          controller: petDescription,
                          validator: (value) {
                            return value!.isEmpty ? "Required Field*" : null;
                          },
                          textInputAction: TextInputAction.next,
                          maxLength: 100,
                          buildCounter: (context,
                                  {required currentLength, required isFocused, maxLength}) =>
                              null,
                          decoration: InputDecoration(
                              hintText: description ??
                                  "Enter Description (Max 100 characters)",
                              hintStyle: const TextStyle(
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
              widget.isPro!
                  ? Container()
                  : CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "owner_firstname",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: userFirstname,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: firstName,
                                    hintStyle: const TextStyle(
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
              widget.isPro!
                  ? Container()
                  : CustomCard(
                      width: MediaQuery.of(context).size.width,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 12.0, top: 14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocaleText(
                              "owner_lastname",
                              style: pinkHeadingStyle,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 4.0, right: 10),
                              child: TextFormField(
                                controller: userLastname,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                    hintText: lastName,
                                    hintStyle: const TextStyle(
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
              widget.isPro!
                  ? Container()
                  : CustomCard(
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
                                controller: userDescription,
                                validator: (value) {
                                  return value!.isEmpty
                                      ? "Required Field*"
                                      : null;
                                },
                                textInputAction: TextInputAction.next,
                                maxLength: 100,
                                buildCounter: (context,
                                        {required currentLength,
                                        required isFocused,
                                        maxLength}) =>
                                    null,
                                decoration: InputDecoration(
                                    hintText: ownerDescription ??
                                        "Enter Description (Max 100 characters)",
                                    hintStyle: const TextStyle(
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
              widget.isPro!
                  ? Container()
                  : CustomCard(
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
                                  "${ownerAge.toDouble().toString()} yr.",
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
                                min: 18,
                                max: 100,
                                onChanged: (double newValue) {
                                  setState(() {
                                    ownerAge = newValue.round();
                                  });
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
              isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: Colors.pink,
                      ),
                    )
                  : InkWell(
                      onTap: () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            isLoading = true;
                          });
                          await FirebaseCredentials()
                              .db
                              .collection("Pet")
                              .doc(widget.id)
                              .update({
                            'age': age,
                            'description': petDescription.text,
                            'breed': petBreed.text,
                            'behaviour': petBehaviour.text,
                            'name': petNameController.text,
                            'sex': gender,
                            'size': petSize,
                          });
                          widget.isPro!
                              ? setState(() {
                                  isLoading = false;
                                })
                              : FirebaseCredentials()
                                  .db
                                  .collection("User")
                                  .doc(widget.ownerId)
                                  .update({
                                  'age': ownerAge,
                                  'firstName': userFirstname.text,
                                  'lastName': userLastname.text,
                                  'description': userDescription.text,
                                }).then((value) {
                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                        }
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
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class petDropdownWidgetCard extends StatefulWidget {
  petDropdownWidgetCard({
    required this.variable,
    required this.title,
    required this.hintText,
    required this.list,
  });

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
      height: 95,
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
    super.key,
    required this.age,
  });

  int age;

  @override
  _petAgeSliderWidgetState createState() => _petAgeSliderWidgetState();
}

class _petAgeSliderWidgetState extends State<petAgeSliderWidget> {
  @override
  Widget build(BuildContext context) {
    return CustomCard(
      height: 100,
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
                min: 18,
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
