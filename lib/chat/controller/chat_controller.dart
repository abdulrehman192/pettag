import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pettag/chat/app_colors.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pettag/chat/widgets/mapThumbnail.dart';
import 'package:pettag/chat/widgets/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:pettag/chat/widgets/full_size_photo.dart';

import '../../constant.dart';

class ChatController extends ControllerMVC {

  String? id;
  String? opponentId;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> listMessage = [];
  int _limit = 20;
  final int _limitIncrement = 20;
  String? groupChatId;
  SharedPreferences? prefs;

  File? imageFile;
  File? videoFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String? fileUrl;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();



  init(peerId, peerPetId) {
    groupChatId = '';
    isLoading = false;
    isShowSticker = false;
    fileUrl = '';
    opponentId = peerId;
    readLocal(peerId, peerPetId);
  }

  scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the bottom");
      setState(() {
        print("reach the bottom");
        _limit += _limitIncrement;
      });
    }
    if (listScrollController.offset <=
            listScrollController.position.minScrollExtent &&
        !listScrollController.position.outOfRange) {
      print("reach the top");
      setState(() {
        print("reach the top");
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        isShowSticker = false;
      });
    }
  }

  readLocal(peerId, peerPetId) async {
    prefs = await SharedPreferences.getInstance();
    id = prefs!.getString('id') ?? '';
    if (id.hashCode <= peerId.hashCode) {
      groupChatId = '$id-$peerId';
    } else {
      groupChatId = '$peerId-$id';
    }
    prefs!.setString("groupChatId", groupChatId!);
    FirebaseFirestore.instance
        .collection('User')
        .doc(id)
        .update({'chattingWith': peerId});
    FirebaseFirestore.instance
        .collection('User')
        .doc(peerId)
        .update({'chattingWith': id});
    FirebaseFirestore.instance.collection('User').doc(id).update({
      'chattedWith': FieldValue.arrayUnion([peerId])
    });
    FirebaseFirestore.instance.collection('User').doc(peerId).update({
      'chattedWith': FieldValue.arrayUnion([id])
    });
    QuerySnapshot snappy = await FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: id)
        .get();
    Map<String, dynamic> data = snappy.docs.first.data() as Map<String, dynamic>;
    String petId = data['petId'];
    await FirebaseFirestore.instance.collection('Pet').doc(petId).update({
      'chattedWith': FieldValue.arrayUnion([peerId])
    });
    /*if (snappy.docs.isNotEmpty) {
      snappy.docs.forEach((element) {
        String petId =
            element.data().containsKey('petId') ? element.data()['petId'] : '';

        FirebaseFirestore.instance.collection('Pet').doc(petId).update({
          'chattedWith': FieldValue.arrayUnion([peerId])
        });
      });
    }*/
    QuerySnapshot snap = await FirebaseFirestore.instance
        .collection('Pet')
        .where('ownerId', isEqualTo: peerId)
        .get();
    if (snap.docs.isNotEmpty) {
      for (var element in snap.docs) {
        Map<String, dynamic> data = element.data() as Map<String, dynamic>;
        String petId =
            data.containsKey('petId') ? data['petId'] : '';
        print("Pet Id :::: $petId ______________ PeerPetId :::: $peerPetId");
        petId == peerPetId ? FirebaseFirestore.instance.collection('Pet').doc(petId).update({
          'chattedWith': FieldValue.arrayUnion([id])
        }) : null;
      }
    }
    setState(() {});
  }

  Future getImage(peerId) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    imageFile = File(pickedFile!.path);

    setState(() {
      isLoading = true;
    });
    uploadFile(peerId, 1);
  }

  Future getVideo(peerId) async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    videoFile = File(pickedFile!.path);

    if (videoFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(peerId, 2);
    }
  }

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
  }

  Future uploadFile(peerId, type) async {
    String fileName = type == 1
        ? '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg'
        : '${DateTime.now().millisecondsSinceEpoch.toString()}.mp4';
    var reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(
        type == 1 ? imageFile! : videoFile!,
        type == 2
            ? SettableMetadata(contentType: 'video/mp4')
            : SettableMetadata(contentType: 'image/jpeg'));
    await reference.getDownloadURL().then((downloadUrl) async {
      fileUrl = downloadUrl;
      setState(() {
        isLoading = false;
        onSendMessage(fileUrl!, type, peerId);
      });
    }, onError: (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> uploadThumbFile(file, time) async {
    String fileName = '${DateTime.now().millisecondsSinceEpoch.toString()}.jpg';
    var reference = FirebaseStorage.instance.ref().child(fileName);
    await reference.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    await reference.getDownloadURL().then((downloadUrl) {
      FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId!)
          .doc(time)
          .update({'thumb': downloadUrl});
    }, onError: (err) {
      print(err);
      setState(() {
        isLoading = false;
      });
    });
  }

  void onSendMessage(String content, int type, peerId) {
    if (content.trim() != '') {
      textEditingController.clear();
      var time = DateTime.now().millisecondsSinceEpoch.toString();
      var documentReference = FirebaseFirestore.instance
          .collection('messages')
          .doc(groupChatId)
          .collection(groupChatId!)
          .doc(time);

      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          documentReference,
          {
            'idFrom': id,
            'idTo': peerId,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
            'content': content,
            'type': type,
            'thumb': 'N/A'
          },
        );
      }).whenComplete(() async {
        if (type == 2) {
          getThumb(content, time);
        }
      });
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {}
  }

  Widget buildItem(int index, DocumentSnapshot document, peerAvatar) {

    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    if (data['idFrom'] == id) {
      // Right (my message)
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          (data['type'] == 0)
              // Text
              ? Container(
                  padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                  width: 200.0,
                  decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(8.0)),
                  margin: EdgeInsets.only(
                      bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                      right: 10.0),
                  child: Text(
                    data['content'],
                  ),
                )
              : data['type'] == 1
                  // Image
                  ? Container(
                      margin: EdgeInsets.only(
                          bottom: isLastMessageRight(index) ? 20.0 : 10.0,
                          right: 10.0),
                      padding: const EdgeInsets.all(0),
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                              state!.context,
                              MaterialPageRoute(
                                  builder: (context) => FullSizeImage(
                                      url: data['content'])));
                        },

                        child: Material(
                          borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                          clipBehavior: Clip.hardEdge,
                          child: CachedNetworkImage(
                            placeholder: (context, url) => Container(
                              width: 200.0,
                              height: 200.0,
                              padding: const EdgeInsets.all(70.0),
                              decoration: const BoxDecoration(
                                color:Colors.black26,
                                borderRadius: BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                              ),
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryColor),
                              ),
                            ),
                            errorWidget: (context, url, error) => Material(
                              borderRadius: const BorderRadius.all(
                                Radius.circular(8.0),
                              ),
                              clipBehavior: Clip.hardEdge,
                              child: Image.asset(
                                'images/img_not_available.jpeg',
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                            ),
                            imageUrl: data['content'],
                            width: 200.0,
                            height: 200.0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    )
                  : data['type'] == 2
                      // video
                      ? Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  bottom:
                                      isLastMessageRight(index) ? 20.0 : 10.0,
                                  right: 10.0),
                              padding: const EdgeInsets.all(0),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                      state!.context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              VideoPlayerScreen(
                                                videoUrl:
                                                data['content'],
                                              )));
                                },

                                child: Material(
                                  borderRadius:
                                      const BorderRadius.all(Radius.circular(8.0)),
                                  clipBehavior: Clip.hardEdge,
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) => Container(
                                      width: 200.0,
                                      height: 200.0,
                                      padding: const EdgeInsets.all(70.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.black26,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                      ),
                                      child: const CircularProgressIndicator(
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                AppColors.primaryColor),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Material(
                                      borderRadius: const BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: Image.asset(
                                        'images/img_not_available.jpeg',
                                        width: 200.0,
                                        height: 200.0,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    imageUrl: data['thumb'],
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width: 200.0,
                                height: 200.0,
                                child: Center(
                                  child: Icon(
                                    Icons.play_circle_filled,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ))
                          ],
                        )
                      : data['type'] == 3
                          ? MapImageThumbnail(
                              isLeft: false,
                              url: data['content'],
                            )
                          : Container(),
        ],
      );
    } else {
      // Left (peer message)
      return Container(
        margin: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                //isLastMessageLeft(index)
                Material(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(18.0),
                  ),
                  clipBehavior: Clip.hardEdge,
                  child: CachedNetworkImage(
                    placeholder: (context, url) => Container(
                      width: 35.0,
                      height: 35.0,
                      padding: const EdgeInsets.all(10.0),
                      child: const CircularProgressIndicator(
                        strokeWidth: 1.0,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primaryColor),
                      ),
                    ),
                    imageUrl: peerAvatar,
                    width: 35.0,
                    height: 35.0,
                    fit: BoxFit.cover,
                  ),
                ),

                data['type'] == 0
                    ? Container(
                        padding: const EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8.0)),
                        margin: const EdgeInsets.only(left: 10.0),
                        child: Text(
                          data['content'],
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : data['type'] == 1
                        ? Container(
                            margin: const EdgeInsets.only(left: 10.0),
                        padding: const EdgeInsets.all(0),
                        child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                    state!.context,
                                    MaterialPageRoute(
                                        builder: (context) => FullSizeImage(
                                            url: data['content'])));
                              },

                              child: Material(
                                borderRadius: const BorderRadius.all(
                                  Radius.circular(8.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                                child: CachedNetworkImage(
                                  placeholder: (context, url) => Container(
                                    width: 200.0,
                                    height: 200.0,
                                    padding: const EdgeInsets.all(70.0),
                                    decoration: const BoxDecoration(
                                      color: Colors.grey,
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                    child: const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          AppColors.primaryColor),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Material(
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                    clipBehavior: Clip.hardEdge,
                                    child: Image.asset(
                                      'images/img_not_available.jpeg',
                                      width: 200.0,
                                      height: 200.0,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  imageUrl: data['content'],
                                  width: 200.0,
                                  height: 200.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : data['type'] == 2
                            ? Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10.0),
                                    padding: const EdgeInsets.all(0),
                                    child: ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                            state!.context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    VideoPlayerScreen(
                                                      videoUrl: data['content'],
                                                    )));
                                      },

                                      child: Material(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(8.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            width: 200.0,
                                            height: 200.0,
                                            padding: const EdgeInsets.all(70.0),
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              borderRadius: BorderRadius.all(
                                                Radius.circular(8.0),
                                              ),
                                            ),
                                            child: const CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      AppColors.primaryColor),
                                            ),
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Material(
                                            borderRadius: const BorderRadius.all(
                                              Radius.circular(8.0),
                                            ),
                                            clipBehavior: Clip.hardEdge,
                                            child: Image.asset(
                                              'images/img_not_available.jpeg',
                                              width: 200.0,
                                              height: 200.0,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                          imageUrl: data['thumb'],
                                          width: 200.0,
                                          height: 200.0,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 200.0,
                                    height: 200.0,
                                    child: Center(
                                      child: Icon(
                                        Icons.play_circle_filled,
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ],
                              )
                            : data['type'] == 3
                                ? MapImageThumbnail(
                                    url: data['content'],
                  isLeft: true,
                                  )
                                : Container(),
              ],
            ),
            // Time
            isLastMessageLeft(index)
                ? Container(
                    margin: const EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    child: Text(
                      DateFormat('dd MMM kk:mm').format(
                          DateTime.fromMillisecondsSinceEpoch(int.parse(
                              data['timestamp'].toString()))),
                      style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic),
                    ),
                  )
                : Container()
          ],
        ),
      );
    }
  }

  getThumb(videoPathUrl, time) async {
    final uint8list = await VideoThumbnail.thumbnailFile(
      video: videoPathUrl,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.JPEG,
      quality: 60,
    );
    uploadThumbFile(File(uint8list!), time);
    print('thumb $uint8list');
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] == id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 &&
            listMessage != null &&
            listMessage[index - 1].data()['idFrom'] != id) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    FirebaseFirestore.instance
        .collection("User")
        .doc(opponentId)
        .update({'chattingWith': null});
    FirebaseFirestore.instance
        .collection("User")
        .doc(id)
        .update({'isLocationShared': false});
    /*FirebaseFirestore.instance.collection("User").doc(opponentId).update({
      'isLocationShared':false
    });*/
    FirebaseFirestore.instance
        .collection('User')
        .doc(id)
        .update({'chattingWith': null});
    FirebaseFirestore.instance
        .collection("User")
        .doc(opponentId)
        .update({id!: FieldValue.delete()});
    //Navigator.pop(context);
    return Future.value(false);
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                backgroundColor: Colors.pink,
              ),
            )
          : Container(),
    );
  }

  Widget buildInput(peerId) {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey, width: 0.5)),
          color: Colors.white),
      child: Row(
        children: <Widget>[
          // Button send image
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: const Icon(Icons.perm_media),
                onPressed: () {
                  showBottomSheet(
                      context: state!.context,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20)),
                      builder: (context) => Container(
                            height: 190,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20)),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 3,
                                    offset: Offset(0, 0),
                                    spreadRadius: 1)
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Padding(
                                  padding: EdgeInsets.only(left: 20.0),
                                  child: Text(
                                    'Pick Image',
                                    style: TextStyle(
                                        color: mainColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    InkWell(
                                      onTap: () {
                                        getImage(peerId);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          /*boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueGrey[200],
                                              spreadRadius: 3,
                                              offset: Offset(0, 0),
                                              blurRadius: 3,
                                            )
                                          ],*/
                                        ),
                                        child: const Icon(
                                          Icons.image,
                                          size: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        getVideo(peerId);
                                        Navigator.pop(context);
                                      },
                                      child: Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: mainColor,
                                          borderRadius:
                                              BorderRadius.circular(15),
                                          /*boxShadow: [
                                            BoxShadow(
                                              color: Colors.blueGrey[200],
                                              spreadRadius: 3,
                                              offset: Offset(0, 0),
                                              blurRadius: 3,
                                            )
                                          ],*/
                                        ),
                                        child: const Icon(
                                          Icons.video_library,
                                          size: 38,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ));
                },
                color: mainColor,
              ),
            ),
          ),
          // Edit text
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0, peerId);
                },
                style: const TextStyle(fontSize: 15.0),
                controller: textEditingController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: Colors.grey),
                ),
                focusNode: focusNode,
              ),
            ),
          ),

          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () =>
                    onSendMessage(textEditingController.text, 0, peerId),
                color: mainColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListMessage(peerAvatar) {
    return Flexible(
      child: groupChatId == ''
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppColors.primaryColor)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('messages')
                  .doc(groupChatId)
                  .collection(groupChatId!)
                  .orderBy('timestamp', descending: true)
                  .limit(_limit)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryColor)));
                } else {
                  listMessage.addAll(snapshot.data!.docs);
                  return ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(
                        index, snapshot.data!.docs[index], peerAvatar),
                    itemCount: snapshot.data!.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }
}
