import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:flutter_multi_select_items/flutter_multi_select_items.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:fsearch/fsearch.dart';
import 'package:pettag/chat/repo/route_argument.dart';
import 'package:pettag/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MessageContainerWithSearchBar extends StatefulWidget {
  const MessageContainerWithSearchBar({Key? key}) : super(key: key);

  @override
  _MessageContainerWithSearchBarState createState() =>
      _MessageContainerWithSearchBarState();
}

class _MessageContainerWithSearchBarState
    extends State<MessageContainerWithSearchBar> {
  FirebaseAuth auth = FirebaseAuth.instance;
  MultiSelectController<String> controller = MultiSelectController(
      deSelectPerpetualSelectedItems: true
  );
  var chattedWith = '';
  String userId = '';
  Color tileColor = bgColor;
  List<QueryDocumentSnapshot> chatHistory = [];
  DocumentSnapshot? petDoc;

  @override
  void initState() {
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
        await FirebaseFirestore.instance
            .collection("User")
            .doc(auth.currentUser!.uid)
            .get()
            .then((value) async {
          petDoc = await FirebaseFirestore.instance
              .collection("Pet")
              .doc(value.data()!['pet'][0])
              .get();
        });
        setState(() {});
      });
    }
    super.initState();
    userId = auth.currentUser!.uid;
  }

  void selectAll() {
    setState(() {
      controller.selectAll();
      tileColor = Colors.grey;
    });
  }

  deleteAll() async {
    for (var element in chatHistory) {
      Map<String, dynamic> data = element.data() as Map<String, dynamic>;

      await FirebaseFirestore.instance
          .collection("Pet")
          .doc(data['petId'])
          .update({
        'chattedWith': FieldValue.arrayRemove([userId])
      });
      String groupChatId = '${data['ownerId']}-$userId';
      print("GroupChatId : $groupChatId");
      QuerySnapshot snappy = await FirebaseFirestore.instance
          .collection("messages")
          .doc(groupChatId)
          .collection(groupChatId)
          .get();
      for (var element in snappy.docs) {
        element.reference.delete();
      }
    }
    chatHistory.clear();
    setState(() {
      controller.deselectAll();
      tileColor = bgColor;
    });
    Navigator.pop(context);
  }

  getChatHistory() async {
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('User')
        .doc(auth.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    chattedWith = data.containsKey('chattedWith') ? data['chattedWith'] : [];
  }

  Stream<QuerySnapshot> getMatches() {
    Stream<QuerySnapshot> snap = FirebaseFirestore.instance
        .collection('Pet')
        .where(auth.currentUser!.uid, isEqualTo: 1)
        .snapshots();
    return snap;
  }

  Future<bool> checkMatch(String ownerId) async {
    /*if(petDoc != null){
      return petDoc.data().containsKey(
          ownerId) && petDoc.data()[ownerId] == 1;
    }
    return true;*/
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

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // height: MediaQuery.of(context).size.height / 1.25,
      // width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
            child: FSearch(
              height: 40.0,
              backgroundColor: Colors.white,
              suffixes: [
                Padding(
                  padding: const EdgeInsets.only(right: 3, left: 10),
                  child: LocaleText(
                    'recent',
                    style: TextStyle(
                      color: Colors.grey.withOpacity(0.7),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 0),
                  child: Icon(
                    Icons.arrow_downward,
                    size: 12,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                ),
              ],
              prefixes: [
                Padding(
                  padding: const EdgeInsets.only(right: 10, left: 10),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey.withOpacity(0.7),
                  ),
                )
              ],
              style: TextStyle(color: Colors.grey.withOpacity(0.7)),
              onSearch: (value) {
                /// do something
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
            child: LocaleText(
              'recent_matches',
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.pink[900]),
            ),
          ),
          Container(
              padding: const EdgeInsets.only(left: 16, right: 10),
              color: const Color.fromRGBO(255, 246, 247, 1),
              height: 120,
              width: double.maxFinite,
              child: StreamBuilder(
                stream: getMatches(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    int length = snapshot.data!.docs.length;
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> data =
                            snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        var images = data["images"];
                        /*bool didThisLikedMe = petDoc.data().containsKey(
                            snapshot.data.docs[index].data()['ownerId']) && petDoc.data()[snapshot.data.docs[index].data()['ownerId']] == 1;*/
                        return FutureBuilder(
                            future: checkMatch(data['ownerId']),
                            builder: (context, AsyncSnapshot<bool> snapshot) {
                              if (snapshot.hasData) {
                                if (snapshot.data != null) {
                                  return SizedBox(
                                    height: 100,
                                    width: 80,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Stack(
                                          alignment: Alignment.bottomRight,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                User? user = FirebaseAuth
                                                    .instance.currentUser;
                                                String userId = user!.uid;
                                                SharedPreferences prefs =
                                                    await SharedPreferences
                                                        .getInstance();
                                                await prefs.setString(
                                                    'id', userId);
                                                DocumentSnapshot doc =
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('User')
                                                        .doc(data['ownerId'])
                                                        .get();
                                                var ownerImage = doc['images'];
                                                if (kDebugMode) {
                                                  print(
                                                      "the images $ownerImage");
                                                }
                                                if (mounted) {
                                                  Navigator.of(context).pushNamed(
                                                      '/chat',
                                                      arguments: RouteArgument(
                                                          param1:
                                                              data['ownerId'],
                                                          param2: ownerImage
                                                                      .length >
                                                                  0
                                                              ? ownerImage[0]
                                                              : 'default',
                                                          param3:
                                                              doc['firstName'] ??
                                                                  'User',
                                                          param4:
                                                              data['petId']));
                                                }
                                              },
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.pink,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100),
                                                ),
                                                child: CircleAvatar(
                                                  backgroundImage:
                                                      NetworkImage(images[0]),
                                                  radius: 30,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: 20,
                                              height: 20,
                                              padding: const EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20)),
                                              child: Image.asset(
                                                "assets/2x/Icon awesome-heart@2x.png",
                                              ),
                                            ),
                                          ],
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 5, left: 10, bottom: 5),
                                          child: Text(
                                            data['name'],
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                } else {
                                  return Container();
                                }
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.pink,
                                  ),
                                );
                              }
                            });
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      backgroundColor: Colors.pink,
                    ),
                  );
                },
              )),
          const Divider(
            height: 2,
            color: Colors.black12,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, left: 16, bottom: 10),
            child: Row(
              children: [
                LocaleText(
                  'chats',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.pink[900]),
                ),
                const Spacer(),
                Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.select_all_sharp),
                            onPressed: selectAll,
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: const Text(
                                        "Delete Chats",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      content: const Text(
                                        "Are your Sure",
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontSize: 15,
                                        ),
                                      ),
                                      elevation: 5,
                                      contentPadding: const EdgeInsets.all(10),
                                      actions: [
                                        ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              tileColor = bgColor;
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text(
                                            "No",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: deleteAll,
                                          // color: Colors.white,
                                          // height: 40,
                                          child: const Text(
                                            "Yes",
                                            style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  });
                            },
                          ),
                        ],
                      )

              ],
            ),
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('Pet')
                .where('chattedWith', arrayContains: userId)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                print("data : ${snapshot.data}");
              if (snapshot.hasData) {
                chatHistory = snapshot.data!.docs;
                int length = chatHistory.length;
                int i = 0;
                print("Chat History Length : $length");
                return
                length <= 0 ? const SizedBox.shrink() :
                 MultiSelectContainer(
                  controller: controller,
                   items: chatHistory.map((e) {

                     int index = i % (chatHistory.length);
                     i++;
                     print("index : ${e.data()}");
                     Map<String, dynamic> data =  chatHistory[index].data() as Map<String, dynamic>;
                     var petImages = data['images'];
                     return MultiSelectCard(
                         value: e.get('petId').toString(),
                         child: Expanded(
                           child: Slidable(
                             key: Key(e.get('petId').toString()),
                             dismissal: SlidableDismissal(
                               child: const SlidableDrawerDismissal(),
                               onDismissed: (actionType) {
                                 setState(() {
                                   snapshot.data!.docs.removeAt(index);
                                 });
                               },
                             ),
                             secondaryActions: <Widget>[
                               Container(
                                 padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                                 child: IconSlideAction(
                                   caption: 'Delete',
                                   color: Colors.red,
                                   icon: Icons.delete,
                                   onTap: () async {
                                     //showDeleteDialog();
                                     await FirebaseFirestore.instance
                                         .collection("Pet")
                                         .doc(data['petId'])
                                         .update({
                                       'chattedWith':
                                       FieldValue.arrayRemove([userId])
                                     });
                                     String groupChatId =
                                         '${data['ownerId']}-$userId';
                                     print("GroupChatId : $groupChatId");
                                     QuerySnapshot snappy = await FirebaseFirestore
                                         .instance
                                         .collection("messages")
                                         .doc(groupChatId)
                                         .collection(groupChatId)
                                         .get();
                                     for (var element in snappy.docs) {
                                       element.reference.delete();
                                     }
                                     setState(() {
                                       snapshot.data!.docs.removeAt(index);
                                     });
                                   },
                                 ),
                               ),
                             ],
                             actionPane: const SlidableBehindActionPane(),
                             child: InkWell(
                               onTap: () async {
                                 User? user = FirebaseAuth.instance.currentUser;
                                 String userId = user!.uid;
                                 SharedPreferences prefs =
                                 await SharedPreferences.getInstance();
                                 await prefs.setString('id', userId);
                                 DocumentSnapshot doc = await FirebaseFirestore
                                     .instance
                                     .collection('User')
                                     .doc(data['ownerId'])
                                     .get();
                                 var ownerImage = doc['images'];
                                 if (kDebugMode) {
                                   print("the images $ownerImage");
                                 }
                                 if (mounted) {
                                   Navigator.of(context).pushNamed('/chat',
                                       arguments: RouteArgument(
                                           param1: data['ownerId'],
                                           param2: doc['images'].length > 0
                                               ? doc['images'][0]
                                               : 'default',
                                           param3: doc['firstName'] ?? 'User'));
                                 }
                               },
                               child: Column(
                                 children: [
                                   ListTile(
                                     tileColor: tileColor,
                                     trailing: IconButton(
                                       icon: const Icon(Icons.delete),
                                       onPressed: () async {
                                         await FirebaseFirestore.instance
                                             .collection("Pet")
                                             .doc(data['petId'])
                                             .update({
                                           'chattedWith':
                                           FieldValue.arrayRemove([userId])
                                         });
                                         String groupChatId =
                                             '${data['ownerId']}-$userId';
                                         print("GroupChatId : $groupChatId");
                                         QuerySnapshot snappy =
                                         await FirebaseFirestore.instance
                                             .collection("messages")
                                             .doc(groupChatId)
                                             .collection(groupChatId)
                                             .get();
                                         for (var element in snappy.docs) {
                                           element.reference.delete();
                                         }
                                         setState(() {
                                           snapshot.data!.docs.removeAt(index);
                                         });
                                       },
                                     ),
                                     title: Text(
                                       data['name'],
                                       style: const TextStyle(
                                         fontWeight: FontWeight.bold,
                                       ),
                                     ),
                                     /*subtitle: Text(
                                   'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                                   style: TextStyle(
                                     fontSize: 13,
                                   ),
                                 ),*/
                                     leading: SizedBox(
                                       height: 100,
                                       width: 55,
                                       child: Stack(
                                         alignment: Alignment.bottomRight,
                                         children: [
                                           Container(
                                             decoration: BoxDecoration(
                                               border: Border.all(
                                                   color: Colors.pink, width: 1),
                                               borderRadius:
                                               BorderRadius.circular(100),
                                             ),
                                             child: CircleAvatar(
                                               radius: 60,
                                               backgroundImage:
                                               NetworkImage(petImages[0]),
                                             ),
                                           ),
                                           Container(
                                             width: 20,
                                             height: 20,
                                             padding: const EdgeInsets.all(3),
                                             decoration: BoxDecoration(
                                                 color: Colors.white,
                                                 borderRadius:
                                                 BorderRadius.circular(20)),
                                             child: Image.asset(
                                               "assets/2x/Icon awesome-heart@2x.png",
                                             ),
                                           ),
                                         ],
                                       ),
                                     ),
                                   ),
                                   const SizedBox(
                                     height: 3,
                                   ),
                                 ],
                               ),
                             ),
                           ),
                         )
                     );

                   }).toList(),
                   onChange: (List<dynamic> selectedItems, selectedItem)
                   {

                   },
                 );
              } else if (snapshot.hasError) {
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              } else {
                return Container();
              }
            },
          ),
        ],
      ),
    );
  }
}

/*Dismissible(
                        key: UniqueKey(),
                        background: Container(color: Colors.red[700]),
                        direction: DismissDirection.horizontal,
                        onDismissed: (direction)async{
                          await FirebaseFirestore.instance.collection("Pet").doc(snapshot.data.docs[index].data()['petId']).update(
                              {
                                'chattedWith' : FieldValue.arrayRemove([userId])
                              });
                          //setState(() {
                            snapshot.data.docs.removeAt(index);
                          //});
                        },
                        child: InkWell(
                          onTap: ()async{
                            User user =
                                FirebaseAuth.instance.currentUser;
                            String userId = await user.uid;
                            SharedPreferences prefs =
                            await SharedPreferences.getInstance();
                            await prefs.setString('id', userId);
                            DocumentSnapshot doc =
                            await FirebaseFirestore.instance
                                .collection('User')
                                .doc(data['ownerId'])
                                .get();
                            var ownerImage = doc['images'];
                            Navigator.of(context).pushNamed('/chat',
                                arguments: RouteArgument(
                                    param1: data['ownerId'],
                                    param2: ownerImage.length > 0
                                        ? doc['images'][0]
                                        : 'default',
                                    param3:
                                    doc['firstName'] ?? 'User'));
                          },
                          child: Container(
                            // width: double.infinity,
                            height: 70,
                            child: ListTile(
                              title: Text(
                                data['name'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              /*subtitle: Text(
                                'Lorem Ipsum is simply dummy text of the printing and typesetting industry. ',
                                style: TextStyle(
                                  fontSize: 13,
                                ),
                              ),*/
                              leading: SizedBox(
                                height: 100,
                                width: 55,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.pink, width: 1),
                                        borderRadius: BorderRadius.circular(100),
                                      ),
                                      child: CircleAvatar(
                                        radius: 60,
                                        backgroundImage: NetworkImage(petImages[0]),
                                      ),
                                    ),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(20)),
                                      child: Image.asset(
                                        "assets/2x/Icon awesome-heart@2x.png",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );*/
