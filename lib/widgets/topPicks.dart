import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/screens/treat_pet_slide_screen.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class TopPicks extends StatefulWidget {
  const TopPicks({Key? key}) : super(key: key);

  @override
  State<TopPicks> createState() => _TopPicksState();
}

class _TopPicksState extends State<TopPicks> {
  String gender = '';
  double startAge = 0;
  double endAge = 0;

  Future<Iterable<QueryDocumentSnapshot>> getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    gender = prefs.getString("preferredGender") ?? "Female";
    startAge = prefs.getDouble("minAge") ?? 1.0;
    endAge = prefs.getDouble("maxAge") ?? 29.0;

    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection("Pet")
        .where('ownerId', isNotEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();
    return snap.docs.where((element) {
      Map<String, dynamic> data = element.data() as Map<String, dynamic>;
      return (data['age'].runtimeType == int &&
              data['age'] >= startAge &&
              data['age'] <= endAge) &&
          data['sex'] == gender &&
          !data.containsKey('block_${FirebaseAuth.instance.currentUser!.uid}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: FutureBuilder(
              future: getData(),
              builder: (context,
                  AsyncSnapshot<Iterable<QueryDocumentSnapshot>> snapshot) {
                if (snapshot.hasError) {
                  return const Text(
                    'Something Went Wrong',
                    style: TextStyle(
                      color: Colors.black38,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.pink,
                    ),
                  );
                }

                if (snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      'Empty',
                      style: TextStyle(
                        color: Colors.black38,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  );
                }
                int length = snapshot.data!.length;
                return GridView.builder(
                  shrinkWrap: true,
                  itemCount: length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 2,
                    crossAxisSpacing: 2,
                    childAspectRatio: 1.0,
                  ),
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data =
                        snapshot.data!.toList()[index].data() as Map<String, dynamic>;
                    var images = data["images"];
                    String petId = data['petId'];
                    String ownerId = data['ownerId'];
                    return appData.isPro!
                        ? GestureDetector(
                            onTap: () async {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return TreatPetSlideScreen(
                                  petId: petId,
                                );
                              }));
                              print(
                                  "Pet id is :::::::::::::::::::::::::::  $petId");
                            },
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: Card(
                                shadowColor: Colors.white,
                                elevation: 2.0,
                                child: GridTile(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                        top: 15,
                                        bottom: 15,
                                        left: 15,
                                        right: 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.pink, width: 1),
                                            borderRadius:
                                                BorderRadius.circular(100),
                                          ),
                                          child: CircleAvatar(
                                            backgroundImage: showImage(images[0]),
                                            radius: 50,
                                          ),
                                        ),
                                        Text(
                                          data['name'],
                                          style: const TextStyle(
                                            fontSize: 17,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return PetProfileScreen(
                                      docId: petId,
                                      ownerId: ownerId,
                                      isJustPreview: true,
                                    );
                                  }));
                                },
                                child: Card(
                                  shadowColor: Colors.white,
                                  elevation: 2.0,
                                  child: GridTile(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 15,
                                          bottom: 15,
                                          left: 15,
                                          right: 15),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.pink, width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(100),
                                            ),
                                            child: CircleAvatar(
                                              backgroundImage: showImage(images[0]),
                                              radius: 50,
                                            ),
                                          ),
                                          Text(
                                            data['name'],
                                            style: const TextStyle(
                                              fontSize: 17,
                                              color: Colors.pink,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Card(
                                color:
                                    const Color(0xFF3A3C3B).withOpacity(0.95),
                                child: GridTile(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                        sigmaX: 1.0, sigmaY: 1.0),
                                    child: Container(),
                                  ),
                                ),
                              ),
                            ],
                          );
                  },
                );
              },
            ),
          ),
        ),
        appData.isPro!
            ? Container()
            : Positioned(
                bottom: 20,
                right: 10,
                left: 10,
                child: GenericBShadowButton(
                  buttonText: 'Unlock Top Picks',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return MySearchDialog();
                      },
                    );
                  },
                ),
              )
      ],
    );
  }

  showImage(String? petImage) {
    if(petImage == null)
    {
      return const AssetImage("assets/profile.png");
    }
    else
    {
      return NetworkImage(petImage);
    }
  }
}
