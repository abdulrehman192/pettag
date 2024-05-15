import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/models/likedByModel.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/screens/treat_pet_slide_screen.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

import '../main.dart';
import 'generic_shadow_button.dart';
import 'mySearchDialog.dart';

class Treat extends StatefulWidget {
  const Treat({Key? key}) : super(key: key);

  @override
  State<Treat> createState() => _TreatState();
}

class _TreatState extends State<Treat> {
  List<dynamic> likedBy = [];

  int length = 0;

  // getTreatLength()async{
  //   await FirebaseFirestore.instance.collection("User").doc(FirebaseAuth.instance.currentUser.uid).get().then((value) {
  //     value.data().containsKey("treats") ? length = value.data()['treats'] : length = 0;
  //   });
  //   setState(() {
  //
  //   });
  // }

  Future<List<LikedBy>> getTreatList() async {
    List<LikedBy> detailList = [];
    QuerySnapshot myLikesDocs = await FirebaseCredentials()
        .db
        .collection('Pet')
        .where('ownerId', isEqualTo: FirebaseCredentials().auth.currentUser!.uid)
        .get();
    List<QueryDocumentSnapshot> snap = myLikesDocs.docs;

    for (QueryDocumentSnapshot doc in snap) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      int length = data.containsKey('likedBy') ? data['likedBy'].length : 0;
      for (int i = 0; i < length; i++) {
        if (!LikedBy(user_id: data['likedBy'][i]['user_id']).isUserSame()) {
          await FirebaseFirestore.instance
              .collection('User')
              .doc(data['likedBy'][i]['user_id'])
              .get()
              .then((value) {
            if (value.data()!.containsKey(
                'block_${FirebaseAuth.instance.currentUser!.uid}')) {
              print("$i");
            } else {
              detailList.add(LikedBy.fromFirebase(data['likedBy'][i]));
            }
          });
        }
      }
    }

    /*snap.forEach((element) async {
      int length = element.data().containsKey('likedBy') ? element.data()['likedBy'].length : 0;

      for(int i=0; i< length ; i++){
        if(!LikedBy(user_id: element.data()['likedBy'][i]['user_id']).isUserSame()){
          await FirebaseFirestore.instance.collection('User').doc(element.data()['likedBy'][i]['user_id']).get().then((value) {
            if(value.data().containsKey('block_${FirebaseAuth.instance.currentUser.uid}')){
              print("$i");
            }else{
              detailList.add(LikedBy.fromFirebase(element.data()['likedBy'][i]));
            }
          });
        }
      }

      element.data()['likedBy'].forEach((value) async {
        if(!LikedBy(user_id: value['user_id']).isUserSame()) {
          detailList.add(LikedBy.fromFirebase(value));}
      });
    });*/

    return detailList;
    /*if(likedBy!=null){
      await likedBy.forEach((element) async{
        QuerySnapshot snap = await FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: element["user_id"]).get();
        detailList.add();
      });
    }*/
    detailList = detailList.toSet().toList();
    return detailList;
    /* if(mounted){
      Future.delayed(Duration(seconds: 1)).whenComplete((){
        if(detailList.length>0){
          setState(() {});
        }
      });
    }*/
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    appData.isPro ??= false;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height / 1.25,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.5,
            child: FutureBuilder(
              future: getTreatList(),
              builder: (context, AsyncSnapshot<List<LikedBy>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.blue,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.brown[300],
                              border: Border.all(
                                color: Colors.pink[100]!,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "Looks like we got an error please try again later.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                if (snapshot.hasData) {
                  if (snapshot.data == null) {
                    return Center(
                      child: SizedBox(
                        height: 50,
                        width: MediaQuery.of(context).size.width / 2,
                        child: Center(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.brown[300],
                              border: Border.all(
                                color: Colors.pink[100]!,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Text(
                                "You don't have any Treat.",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (snapshot.data!.length >= 15) {
                    length = 15;
                  } else {
                    length = snapshot.data!.length;
                  }
                  print("DetailsList Length : ${snapshot.data!.length}");
                  return GridView.builder(
                    shrinkWrap: true,
                    itemCount: length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 1.0,
                    ),
                    itemBuilder: (context, index) {
                      var images = snapshot.data![index].petImage;
                      String? petId =
                          snapshot.data![index].petId; //data['petId'];
                      String? ownerId =
                          snapshot.data![index].user_id; //data['ownerId'];
                      return appData.isPro!
                          ? GestureDetector(
                              onTap: () async {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return TreatPetSlideScreen(
                                    petId: petId!,
                                  );
                                }));
                                print(
                                    "Pet id is :::::::::::::::::::::::::::  $petId");
                              },
                              child: Container(
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
                                              backgroundImage: showImage(snapshot .data![index].petImage),
                                              radius: 50,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data![index].petName.toString(),
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
                          : Stack(
                              fit: StackFit.passthrough,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return PetProfileScreen(
                                        docId: snapshot.data![index].petId.toString(),
                                        ownerId: snapshot.data![index].user_id.toString(),
                                        isJustPreview: true,
                                      );
                                    }));
                                  },
                                  child: Container(
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
                                                      color: Colors.pink,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundImage: showImage(snapshot.data![index].petImage),
                                                  radius: 50,
                                                ),
                                              ),
                                              Text(
                                                snapshot.data![index].petName.toString(),
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
                                ),
                                Container(
                                  child: Card(
                                    color: const Color(0xFF3A3C3B)
                                        .withOpacity(0.95),
                                    child: GridTile(
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(
                                            sigmaX: 1.0, sigmaY: 1.0),
                                        child: Container(),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                    },
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.pink,
                    ),
                  );
                }
              },
            ),
          ),
        ),
        if (appData.isPro!)
          Positioned(
            bottom: 20,
            right: 10,
            left: 10,
            child: GenericBShadowButton(
              buttonText: Locales.string(context, 'unlock_top_picks'),
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
