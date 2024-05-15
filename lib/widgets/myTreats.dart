import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

class MyTreat extends StatefulWidget {
  const MyTreat({Key? key}) : super(key: key);

  @override
  _MyTreatState createState() => _MyTreatState();
}

class _MyTreatState extends State<MyTreat> {

  Future<List<QuerySnapshot>> getData() async {
    QuerySnapshot snapSuperLikes = await FirebaseFirestore.instance
        .collection('Pet')
        .where(FirebaseCredentials().auth.currentUser!.uid, isEqualTo: 2)
        .get();

    snapSuperLikes.docs.removeWhere((element) =>
        (element.data() as Map<String, dynamic>)
            .containsKey('block_${FirebaseAuth.instance.currentUser!.uid}'));

    QuerySnapshot snapLikes = await FirebaseFirestore.instance
        .collection('Pet')
        .where(FirebaseCredentials().auth.currentUser!.uid, isEqualTo: 1)
        .get();

    List<QuerySnapshot> snappy = [snapSuperLikes, snapLikes];

    print(
        "Length of query snapshot :::::::::::::: ${snapSuperLikes.docs.length}");

    return snappy;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height / 1.25,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.5,
        child: FutureBuilder(
            future: getData(),
            builder: (context, AsyncSnapshot<List<QuerySnapshot>> snapshot) {
              List<QueryDocumentSnapshot> myList = [];
              if (snapshot.hasData) {
                for (var element in snapshot.data!) {
                  for (var element in element.docs) {
                    Map<String, dynamic> data =
                        element.data() as Map<String, dynamic>;

                    if (data.containsKey(
                            FirebaseCredentials().auth.currentUser!.uid) &&
                        !data.containsKey(
                            'block_${FirebaseAuth.instance.currentUser!.uid}')) {
                      myList.add(element);
                    }
                  }
                }
                myList.shuffle();
                int length = myList.length;
                return length > 0
                    ? GridView.builder(
                        shrinkWrap: true,
                        itemCount: length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 2,
                          crossAxisSpacing: 2,
                          //childAspectRatio: 3 / 4,
                        ),
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data = myList[index].data() as Map<String, dynamic>;
                          var images = data['images']; //data["images"];
                          String petId = data['petId']; //data['petId'];
                          String ownerId = data['ownerId']; //data['ownerId'];
                          return GestureDetector(
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
                            child: SizedBox(
                              width: 200,
                              height: 150,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Card(
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
                                                    BorderRadius.circular(100),
                                              ),
                                              child: CircleAvatar(
                                                backgroundImage: showImage(images[0]),
                                                radius: 50,
                                              ),
                                            ),
                                            Text(
                                              data['name'].toString(),
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
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: data[FirebaseAuth.instance
                                                    .currentUser!.uid] ==
                                                1
                                            ? Colors.green
                                            : Colors.blue,
                                      ),
                                      child: data[FirebaseAuth
                                                  .instance.currentUser!.uid] ==
                                              1
                                          ? const Text("Like",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold))
                                          : const Text("Super Like",
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Center(
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
                                    color: Colors.pink.shade100,
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
                                )),
                              ),
                            ),
                          ),
                        ),
                      );
              } else if (snapshot.hasError) {
                return const Text(
                  'Something Went Wrong',
                  style: TextStyle(
                    color: Colors.black38,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.pink,
                  ),
                );
              }
            }),
      ),
    );
  }

  showImage(String? url) {
    if(url != null)
      {
        return NetworkImage(url);
      }
    else{
      return const AssetImage("assets/man.png");
    }
  }
}
