import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/models/likedByModel.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/screens/userDetails.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

class PetDate extends StatefulWidget {
  const PetDate({Key? key}) : super(key: key);

  @override
  _PetDateState createState() => _PetDateState();
}

class _PetDateState extends State<PetDate> {
  int length = 0;
  bool isLoading = true;

  Future<List<LikedBy>> getPetDate() async {
    List<LikedBy> list = [];
    QuerySnapshot myLikesDocs = await FirebaseFirestore.instance
        .collection('Pet')
        .where(FirebaseCredentials().auth.currentUser!.uid, isEqualTo: 1)
        .get();
    List<QueryDocumentSnapshot> snap = myLikesDocs.docs;
    list.clear();

    for (QueryDocumentSnapshot doc in snap) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print("the data in petdate $data");
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
              list.add(LikedBy.fromFirebase(data['likedBy'][i]));
            }
          });
        }
      }
    }

    /*snap.forEach((element) {
      element.data()['likedBy'].forEach((value) {
      if(!LikedBy(user_id: value['user_id']).isUserSame()) {
        list.add(LikedBy.fromFirebase(value));}
      });
    });*/
    print("the list in pet date $list and ${list.distinct()}");

    var filterList = list.distinct();
    return filterList;
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
          future: getPetDate(),
          builder: (context, AsyncSnapshot<List<LikedBy>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: Colors.pink,
                ),
              );
            }

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

            if (snapshot.hasData) {
              isLoading = false;
              return isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        backgroundColor: Colors.pink,
                      ),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      itemCount: snapshot.data!.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                      ),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return PetProfileScreen(
                                    docId: snapshot.data![index].petId.toString(),
                                    ownerId: snapshot.data![index].user_id.toString(),
                                    isJustPreview: true,
                                  );
                                },
                              ),
                            );
                            /*Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return UserDetails(
                                ownerId: snapshot.data[index].user_id,
                                petId: snapshot.data[index].petId,
                                isMyProfile: false,
                              );
                            }));*/
                          },
                          child: SizedBox(
                            //padding: EdgeInsets.symmetric(horizontal: 5),
                            width: 200,
                            height: 150,
                            child: Card(
                              shadowColor: Colors.white,
                              elevation: 2.0,
                              child: GridTile(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: 15, bottom: 15, left: 15, right: 15),
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
                                          backgroundImage: NetworkImage(
                                              snapshot.data![index].petImage!),
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
                        );
                      },
                    );
            } else {
              return const Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: Colors.black,
                ),
              );
            }
          },
        ),
      ),
    );
  }
}

class MyLikesList extends StatelessWidget {
  List<QueryDocumentSnapshot> docs = [];

  MyLikesList({Key? key,required this.docs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: docs
            .map((e) {
              return LikedByList(list: e['likedBy']);
            })
            .toSet()
            .toList(),
      ),
    );
  }
}

class LikedByList extends StatefulWidget {
  List<dynamic> list;

  LikedByList({Key? key,required this.list}) : super(key: key);

  @override
  _LikedByListState createState() => _LikedByListState();
}

class _LikedByListState extends State<LikedByList> {
  List<dynamic> mapList = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // final ids = myList.map((e) => e.id).toSet();
    // myList.retainWhere((x) => ids.remove(x.id));

    if (mounted) {
      setState(() {
        var mappList = widget.list.toSet();
        widget.list.retainWhere((x) => mappList.remove(x['user_id']));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    for (var element in mapList) {
      print("${element["user_id"]}");
    }
    return GridView.builder(
      shrinkWrap: true,
      itemCount: mapList.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 2,
        crossAxisSpacing: 2,
        //childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) {
/*        var images = data["images"];
        String petId = data['petId'];
        String ownerId = data['ownerId'];*/

        return GestureDetector(
          onTap: () =>
              Navigator.push(context, MaterialPageRoute(builder: (context) {
            return UserDetails(
              ownerId: mapList[index]["user_id"],
              petId: mapList[index]["petId"],
              isMyProfile: false,
            );
          })),
          child: SizedBox(
            //padding: EdgeInsets.symmetric(horizontal: 5),
            width: 200,
            height: 150,
            child: Card(
              shadowColor: Colors.white,
              elevation: 2.0,
              child: GridTile(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 15, bottom: 15, left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.pink, width: 1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: CircleAvatar(
                          backgroundImage:
                              NetworkImage(mapList[index]["petImage"]),
                          radius: 50,
                        ),
                      ),
                      Text(
                        mapList[index]["petName"],
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
        );
      },
    );
  }
}
