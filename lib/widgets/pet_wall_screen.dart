import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:inview_notifier_list/inview_notifier_list.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/models/PostModel.dart';
import 'package:pettag/screens/addNewFeed.dart';
import 'package:pettag/widgets/commentWidget.dart';
import 'package:pettag/widgets/wall_card.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

class PetWallScreen extends StatefulWidget {
  const PetWallScreen({Key? key}) : super(key: key);

  @override
  State createState() => _PetWallScreenState();
}

class _PetWallScreenState extends State<PetWallScreen> {
  dialog(BuildContext context, DocumentSnapshot snap) {
    Size size = MediaQuery.of(context).size;
    return showDialog(
        context: context,
        builder: (context) {
          return Center(
            child: Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: Container(
                width: size.width * 0.8,
                height: size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF707070)),
                  color: Colors.white,
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.03),
                      child: const Text(
                        "Are you sure to Delete?",
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              snap.reference.delete();
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: size.width * 0.3,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xFF0f1013)
                                          .withOpacity(0.2)),
                                  color: Colors.white),
                              child: const Center(
                                child: Text(
                                  "Yes",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              width: size.width * 0.3,
                              height: size.height * 0.06,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: const Color(0xFF0f1013)
                                          .withOpacity(0.2)),
                                  color: Colors.white),
                              child: const Center(
                                child: Text(
                                  "No",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }

  List<PostModel> posts = [];
  bool isLoading = false;
  final FirebaseAuth auth = FirebaseAuth.instance;

  List filedata = [];
  List filedataHeavy = [];

  updateStarCounter({postId, status}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('Post').doc(postId).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    int counter = data['stars'] ?? 0;
    if (!data.containsKey(auth.currentUser!.uid)) {
      counter++;
      FirebaseFirestore.instance.collection('Post').doc(postId).update({
        'stars': counter,
      });
      updateInteraction(postId: postId, status: status);
    }
  }

  updateHeartCounter({postId, status}) async {
    DocumentSnapshot snap =
        await FirebaseFirestore.instance.collection('Post').doc(postId).get();
    Map<String, dynamic> data = snap.data() as Map<String, dynamic>;
    int counter = data['hearts'] ?? 0;
    if (!data.containsKey(auth.currentUser!.uid)) {
      counter++;
      FirebaseFirestore.instance.collection('Post').doc(postId).set({
        'hearts': counter,
      }, SetOptions(merge: true));
      updateInteraction(postId: postId, status: status);
    }
  }

  updateInteraction({postId, status}) async {
    FirebaseFirestore.instance.collection('Post').doc(postId).set({
      auth.currentUser!.uid: status,
    }, SetOptions(merge: true));
  }

  updateHeart({postId, status}) async {
    FirebaseFirestore.instance.collection('Post').doc(postId).set({
      auth.currentUser!.uid: status,
    }, SetOptions(merge: true));
  }

  Future<String?> getThumb(videoPathUrl) async {
    return VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      quality: 100,
    );
  }

  Widget commentChild(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 2.0, 8.0),
            child: SizedBox(
              height: 42,
              child: Row(
                children: [
                  Container(
                    height: 40.0,
                    width: 40.0,
                    decoration: const BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.all(Radius.circular(50))),
                    child: CircleAvatar(
                        radius: 50,
                        backgroundImage: showImage(data[i]['pic']),
                  ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 42,
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey[300],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          data[i]['name'],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        Text(
                          data[i]['message'],
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
      ],
    );
  }

  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  String userName = '';
  String userImageUrl = '';
  String userId = '';
  late DocumentSnapshot petDoc;
  late QuerySnapshot myPets;

  late FocusNode myFocusNode;

  getMyData() async {
    FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      final data = value.docs.first.data();
      userName = data['name'];
      userImageUrl = data['images'][0];
      userId = FirebaseAuth.instance.currentUser!.uid;
    });
    // FirebaseFirestore.instance
    //     .collection("User")
    //     .doc(FirebaseAuth.instance.currentUser.uid)
    //     .get()
    //     .then((value) async {
    //   userName = value.data()['firstName'] + " " + value.data()['lastName'];
    //   userImageUrl =
    //       value.data()['images'].length > 0 ? value.data()['images'][0] : "";
    //   userId = value.data()['id'];
    /*petDoc = await FirebaseFirestore.instance
          .collection("Pet")
          .doc(value.data()['pet'][0])
          .get();*/
    // });
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
    if (ownerId == FirebaseAuth.instance.currentUser!.uid) {
      return true;
    }

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
            break;
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
              break;
            }
          }
        }
      });
    });
    return matched && otherMatched;
  }

  @override
  void initState() {
    myFocusNode = FocusNode();
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) async {
      await getMyData();
      setState(() {});
    });
    super.initState();
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: ElevatedButton(
              // elevation: 0,
              // textColor: Colors.black,
              // color: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, AddNewFeed.addNewFeedScreenRoute);
              },
              child: const LocaleText(
                "add_your_new_feed",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.pink,
                      strokeWidth: 2,
                    ),
                  )
                : StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('Post')
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return const Center(
                          child: Text(
                            "Something Went Wrong",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black45,
                              fontSize: 20,
                            ),
                          ),
                        );
                      }
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            backgroundColor: Colors.pink,
                            strokeWidth: 2,
                          ),
                        );
                      }
                      if (snapshot.hasData) {
                        List<DocumentSnapshot> docs = snapshot.data!.docs;
                        print("docsss $docs");
                        print(docs.map((e) => e.data()));

                        return InViewNotifierList(
                          scrollDirection: Axis.vertical,
                          isInViewPortCondition: (double deltaTop,
                              double deltaBottom, double viewPortDimension) {
                            return deltaTop < (0.5 * viewPortDimension) &&
                                deltaBottom > (0.5 * viewPortDimension);
                          },
                          // shrinkWrap: true,
                          itemCount: docs.length,
                          builder: (BuildContext context, int index) {
                            Map<String, dynamic> data =
                                docs[index].data() as Map<String, dynamic>;
                            if (kDebugMode) {
                              print(data);
                            }
                            List<Map<String, dynamic>> comments = [];
                            List<Map<String, dynamic>> limitedComments = [];
                            if (data.containsKey('comments')) {
                              comments.addAll(List.from(data['comments']));
                              comments = comments.reversed.toList();
                              limitedComments.addAll(comments.length >= 5
                                  ? comments.take(5)
                                  : comments);
                            }
                            return FutureBuilder(
                              future: checkMatch(data['userId']),
                              builder: (context, AsyncSnapshot<bool> snapshot) {
                                if (snapshot.data != true) {
                                  return Container();
                                }
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Card(
                                        elevation: 0.0,
                                        color: Colors.white54,
                                        child: Container(
                                          padding: const EdgeInsets.only(
                                              left: 15,
                                              right: 10,
                                              top: 15,
                                              bottom: 10),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 40,
                                                    backgroundImage:
                                                        NetworkImage(
                                                            data['petImage']),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 15),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          data['petName'] ?? "",
                                                          style: name.copyWith(
                                                              fontSize: 17),
                                                        ),
                                                        Text(
                                                          data['time'],
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 13,
                                                            color:
                                                                Colors.black38,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  IconButton(
                                                    onPressed: () {
                                                      if (data['userId'] ==
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              !.uid) {
                                                        dialog(context,
                                                            docs[index]);
                                                      }
                                                    },
                                                    icon: const Icon(
                                                      Icons.more_horiz,
                                                      color: Colors.black26,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.only(
                                                    top: 10,
                                                    right: 5,
                                                    bottom: 10),
                                                child: Text(
                                                  data['postDescription'],
                                                  style: TextStyle(
                                                    color: Colors.pink[900],
                                                    fontSize: 13,
                                                  ),
                                                  textAlign: TextAlign.start,
                                                ),
                                              ),
                                              if (data
                                                  .containsKey('postPicture'))
                                                Container(
                                                  width: double.infinity,
                                                  height: 190.0,
                                                  alignment: Alignment.center,
                                                  margin: const EdgeInsets
                                                          .symmetric(
                                                      vertical: 10.0),
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      return InViewNotifierWidget(
                                                        id: '$index',
                                                        builder: (BuildContext
                                                                context,
                                                            bool isInView,
                                                            Widget? child) {
                                                          return WallCard(
                                                            play: isInView,
                                                            postPicture: data[
                                                                'postPicture'],
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                              Container(
                                                alignment:
                                                    Alignment.centerRight,
                                                width: double.infinity,
                                                height: 40,
                                                padding: const EdgeInsets.only(
                                                    top: 0,
                                                    right: 5,
                                                    bottom: 0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Text(data['stars'] != null
                                                        ? data['stars']
                                                            .toString()
                                                        : "0"),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                        top: 0,
                                                        left: 0,
                                                        right: 0,
                                                      ),
                                                      child: IconButton(
                                                        icon: Container(
                                                          width: 25,
                                                          height: 30,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFFFFAFA),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Image.asset(
                                                            "assets/2x/Icon awesome-star@2x.png",
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          updateStarCounter(
                                                              postId: data[
                                                                  'postId'],
                                                              status: 2);
                                                        },
                                                      ),
                                                    ),
                                                    Text(
                                                      data['hearts'] != null
                                                          ? data['hearts']
                                                              .toString()
                                                          : "0",
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 0,
                                                              left: 0,
                                                              right: 0),
                                                      child: IconButton(
                                                        icon: Container(
                                                          width: 25,
                                                          height: 30,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFFFFAFA),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Image.asset(
                                                            "assets/2x/Icon awesome-heart@2x.png",
                                                          ),
                                                        ),
                                                        onPressed: () {
                                                          updateHeartCounter(
                                                              postId: data[
                                                                  'postId'],
                                                              status: 1);
                                                        },
                                                      ),
                                                    ),
                                                    Text(
                                                      comments.length
                                                          .toString(),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              top: 2,
                                                              left: 10,
                                                              right: 0),
                                                      child: InkWell(
                                                        onTap: () async {
                                                          filedataHeavy.clear();
                                                          DocumentSnapshot
                                                              snapDoc =
                                                              await FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'User')
                                                                  .doc(FirebaseAuth
                                                                      .instance
                                                                      .currentUser!
                                                                      .uid)
                                                                  .get();
                                                          Map<String, dynamic>
                                                              user =
                                                              snapDoc.data()
                                                                  as Map<String,
                                                                      dynamic>;

                                                          if (!user.containsKey(
                                                              'block_${user['userId']}')) {
                                                            showModalBottomSheet(
                                                              context: context,
                                                              isScrollControlled:
                                                                  true,
                                                              elevation: 0,
                                                              shape:
                                                                  RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                              ),
                                                              builder:
                                                                  (builder) {
                                                                final petData = docs[
                                                                            index]
                                                                        .data()
                                                                    as Map<
                                                                        String,
                                                                        dynamic>;

                                                                final bool isMyPost = petData[
                                                                        'ownerId'] ==
                                                                    FirebaseAuth
                                                                        .instance
                                                                        .currentUser!
                                                                        .uid;
                                                                return StatefulBuilder(
                                                                  builder: (BuildContext
                                                                          context,
                                                                      StateSetter
                                                                          setState) {
                                                                    return CommentBottomSheetContent(
                                                                        userImageUrl: isMyPost
                                                                            ? petData['images'][
                                                                                0]
                                                                            : userImageUrl,
                                                                        userName: isMyPost
                                                                            ? petData[
                                                                                'name']
                                                                            : userName,
                                                                        doc: docs[
                                                                            index] as DocumentSnapshot<Map<String, dynamic>>,
                                                                        commentsList:
                                                                            comments);
                                                                  },
                                                                );
                                                              },
                                                            );
                                                          }
                                                        },
                                                        child: Container(
                                                          width: 25,
                                                          height: 25,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(5),
                                                          decoration: BoxDecoration(
                                                              color: const Color(
                                                                  0xFFFFFAFA),
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          child: Image.asset(
                                                            "assets/2x/Icon simple-hipchat@2x.png",
                                                            color: Colors
                                                                .pink[200],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              if (data.containsKey('comments'))
                                                Column(
                                                  children: limitedComments
                                                      .map((e) => Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                        .fromLTRB(
                                                                    0.0,
                                                                    8.0,
                                                                    2.0,
                                                                    8.0),
                                                            child: InkWell(
                                                              onLongPress:
                                                                  () async {
                                                                DocumentSnapshot
                                                                    snapDoc =
                                                                    await FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'User')
                                                                        .doc(FirebaseAuth
                                                                            .instance
                                                                            .currentUser!
                                                                            .uid)
                                                                        .get();
                                                                Map<String,
                                                                        dynamic>
                                                                    user2 =
                                                                    snapDoc.data()
                                                                        as Map<
                                                                            String,
                                                                            dynamic>;
                                                                if (!user2
                                                                    .containsKey(
                                                                        'block_${user2['userId']}')) {
                                                                  showModalBottomSheet(
                                                                    context:
                                                                        context,
                                                                    isScrollControlled:
                                                                        true,
                                                                    elevation:
                                                                        0,
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              10.0),
                                                                    ),
                                                                    builder:
                                                                        (builder) {
                                                                      return StatefulBuilder(
                                                                        builder: (BuildContext
                                                                                context,
                                                                            StateSetter
                                                                                setState) {
                                                                          return CommentBottomSheetContent(
                                                                              userImageUrl: userImageUrl,
                                                                              userName: userName,
                                                                              doc: docs[index] as DocumentSnapshot<Map<String, dynamic>>,
                                                                              commentsList: comments);
                                                                        },
                                                                      );
                                                                    },
                                                                  );
                                                                }
                                                              },
                                                              child: SizedBox(
                                                                height: 42,
                                                                child: Row(
                                                                  children: [
                                                                    Container(
                                                                        height:
                                                                            40.0,
                                                                        width:
                                                                            40.0,
                                                                        decoration: const BoxDecoration(
                                                                            color: Colors
                                                                                .blue,
                                                                            borderRadius: BorderRadius.all(Radius.circular(
                                                                                50))),
                                                                        child:
                                                                            CircleAvatar(
                                                                          radius:
                                                                              50,
                                                                          backgroundImage: showImage(e['pic']),
                                                                        )),
                                                                    const SizedBox(
                                                                      width: 10,
                                                                    ),
                                                                    Container(
                                                                      //height: 42,
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              12.0,
                                                                          vertical:
                                                                              4.0),
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10),
                                                                        color: Colors
                                                                            .grey[300],
                                                                      ),
                                                                      child:
                                                                          Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceEvenly,
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: [
                                                                          Text(
                                                                            e['name'],
                                                                            style:
                                                                                const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                                          ),
                                                                          Container(
                                                                            child:
                                                                                Text(
                                                                              e['message'],
                                                                              style: const TextStyle(fontSize: 11),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ))
                                                      .toList(),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            );
                            /*return checkMatch(docs[index].data()['userId']) ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Card(
                                    elevation: 0.0,
                                    color: Colors.white54,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: 15,
                                          right: 10,
                                          top: 15,
                                          bottom: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              CircleAvatar(
                                                radius: 40,
                                                backgroundImage: NetworkImage(
                                                    docs[index]
                                                        .data()['petImage']),
                                              ),
                                              Padding(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      docs[index]
                                                          .data()['petName'],
                                                      style: name.copyWith(
                                                          fontSize: 17),
                                                    ),
                                                    Text(
                                                      docs[index]
                                                          .data()['time'],
                                                      style: TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.black38,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Spacer(),
                                              IconButton(
                                                onPressed: () {
                                                  if (docs[index]
                                                          .data()['userId'] ==
                                                      FirebaseAuth.instance
                                                          .currentUser.uid) {
                                                    dialog(
                                                        context, docs[index]);
                                                  }
                                                },
                                                icon: Icon(
                                                  Icons.more_horiz,
                                                  color: Colors.black26,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Container(
                                            padding: EdgeInsets.only(
                                                top: 10, right: 5, bottom: 10),
                                            child: Text(
                                              docs[index]
                                                  .data()['postDescription'],
                                              style: TextStyle(
                                                color: Colors.pink[900],
                                                fontSize: 13,
                                              ),
                                              textAlign: TextAlign.start,
                                            ),
                                          ),
                                          docs[index]
                                                  .data()
                                                  .containsKey('postPicture')
                                              ? Container(
                                                  width: double.infinity,
                                                  height: 190.0,
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      return InViewNotifierWidget(
                                                        id: '$index',
                                                        builder: (BuildContext
                                                                context,
                                                            bool isInView,
                                                            Widget child) {
                                                          return Container(
                                                            width:
                                                                double.infinity,
                                                            height: 190.0,
                                                            child: ClipRRect(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                              child:
                                                                  Image.network(
                                                                docs[index]
                                                                        .data()[
                                                                    'postPicture'][0],
                                                                fit: BoxFit
                                                                    .cover,
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                )
                                              : Container(
                                                  width: double.infinity,
                                                  height: 190.0,
                                                  alignment: Alignment.center,
                                                  margin: EdgeInsets.symmetric(
                                                      vertical: 10.0),
                                                  child: LayoutBuilder(
                                                    builder:
                                                        (BuildContext context,
                                                            BoxConstraints
                                                                constraints) {
                                                      return InViewNotifierWidget(
                                                        id: '$index',
                                                        builder: (BuildContext
                                                                context,
                                                            bool isInView,
                                                            Widget child) {
                                                          return ClipRRect(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            child: VideoWidget(
                                                                play: isInView,
                                                                url: docs[index]
                                                                        .data()[
                                                                    'postVideo'][0]),
                                                          );
                                                        },
                                                      );
                                                    },
                                                  ),
                                                ),
                                          Container(
                                            alignment: Alignment.centerRight,
                                            width: double.infinity,
                                            height: 40,
                                            padding: EdgeInsets.only(
                                                top: 0, right: 5, bottom: 0),
                                            child: Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(docs[index]
                                                            .data()['stars'] !=
                                                        null
                                                    ? docs[index]
                                                        .data()['stars']
                                                        .toString()
                                                    : "0"),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                    top: 0,
                                                    left: 0,
                                                    right: 0,
                                                  ),
                                                  child: IconButton(
                                                    icon: Container(
                                                      width: 25,
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFFFFAFA),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Image.asset(
                                                        "assets/2x/Icon awesome-star@2x.png",
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      updateStarCounter(
                                                          postId: docs[index]
                                                              .data()['postId'],
                                                          status: 2);
                                                    },
                                                  ),
                                                ),
                                                Text(docs[index]
                                                            .data()['hearts'] !=
                                                        null
                                                    ? docs[index]
                                                        .data()['hearts']
                                                        .toString()
                                                    : "0"),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 0,
                                                          left: 0,
                                                          right: 0),
                                                  child: IconButton(
                                                    icon: Container(
                                                      width: 25,
                                                      height: 30,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFFFFAFA),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Image.asset(
                                                        "assets/2x/Icon awesome-heart@2x.png",
                                                      ),
                                                    ),
                                                    onPressed: () {
                                                      updateHeartCounter(
                                                          postId: docs[index]
                                                              .data()['postId'],
                                                          status: 1);
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          top: 2,
                                                          left: 10,
                                                          right: 0),
                                                  child: InkWell(
                                                    onTap: () async {
                                                      filedataHeavy.clear();
                                                      DocumentSnapshot snapDoc =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'User')
                                                              .doc(FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid)
                                                              .get();
                                                      if (!snapDoc
                                                          .data()
                                                          .containsKey(
                                                              'block_${docs[index].data()['userId']}')) {
                                                        showModalBottomSheet(
                                                          context: context,
                                                          isScrollControlled:
                                                              true,
                                                          elevation: 0,
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10.0),
                                                          ),
                                                          builder: (builder) {
                                                            return StatefulBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  StateSetter
                                                                      setState) {
                                                                return CommentBottomSheetContent(
                                                                    userImageUrl:
                                                                        userImageUrl,
                                                                    userName:
                                                                        userName,
                                                                    doc: docs[
                                                                        index],
                                                                    commentsList:
                                                                        comments);
                                                              },
                                                            );
                                                          },
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      width: 25,
                                                      height: 25,
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFFFFAFA),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      20)),
                                                      child: Image.asset(
                                                        "assets/2x/Icon simple-hipchat@2x.png",
                                                        color: Colors.pink[200],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          docs[index]
                                                  .data()
                                                  .containsKey('comments')
                                              ? Container(
                                                  child: Column(
                                                    children: limitedComments
                                                        .map((e) => Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .fromLTRB(
                                                                      0.0,
                                                                      8.0,
                                                                      2.0,
                                                                      8.0),
                                                              child: InkWell(
                                                                onLongPress:
                                                                    () async {
                                                                  DocumentSnapshot snapDoc = await FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'User')
                                                                      .doc(FirebaseAuth
                                                                          .instance
                                                                          .currentUser
                                                                          .uid)
                                                                      .get();
                                                                  if (!snapDoc
                                                                      .data()
                                                                      .containsKey(
                                                                          'block_${docs[index].data()['userId']}')) {
                                                                    showModalBottomSheet(
                                                                      context:
                                                                          context,
                                                                      isScrollControlled:
                                                                          true,
                                                                      elevation:
                                                                          0,
                                                                      shape:
                                                                          RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      builder:
                                                                          (builder) {
                                                                        return StatefulBuilder(
                                                                          builder:
                                                                              (BuildContext context, StateSetter setState) {
                                                                            return CommentBottomSheetContent(
                                                                                userImageUrl: userImageUrl,
                                                                                userName: userName,
                                                                                doc: docs[index],
                                                                                commentsList: comments);
                                                                          },
                                                                        );
                                                                      },
                                                                    );
                                                                  }
                                                                },
                                                                child:
                                                                    Container(
                                                                  height: 42,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                          height:
                                                                              40.0,
                                                                          width:
                                                                              40.0,
                                                                          decoration: new BoxDecoration(
                                                                              color: Colors.blue,
                                                                              borderRadius: new BorderRadius.all(Radius.circular(50))),
                                                                          child: CircleAvatar(
                                                                            radius:
                                                                                50,
                                                                            backgroundImage: e['pic'] != null
                                                                                ? NetworkImage(e['pic'])
                                                                                : AssetImage("assets/man.png"),
                                                                          )),
                                                                      SizedBox(
                                                                        width:
                                                                            10,
                                                                      ),
                                                                      Container(
                                                                        //height: 42,
                                                                        padding: EdgeInsets.symmetric(
                                                                            horizontal:
                                                                                12.0,
                                                                            vertical:
                                                                                4.0),
                                                                        decoration:
                                                                            BoxDecoration(
                                                                          borderRadius:
                                                                              BorderRadius.circular(10),
                                                                          color:
                                                                              Colors.grey[300],
                                                                        ),
                                                                        child:
                                                                            Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                            Text(
                                                                              e['name'],
                                                                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                                            ),
                                                                            Container(
                                                                              child: Text(
                                                                                e['message'],
                                                                                style: TextStyle(fontSize: 11),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ))
                                                        .toList(),
                                                  ),
                                                )
                                              : Container(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ) : Container();*/
                          },
                        );
                      }
                      return const Center(
                        child: Text("Something went wrong"),
                      );
                    }),
          ),
        ],
      ),
    );
  }

  showImage(String? url) {
    if(url == null)
      {
        return const AssetImage("assets.man.png");
      }
    else
      {
        return NetworkImage(url);
      }
  }
}
