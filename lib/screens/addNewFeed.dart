import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/models/videoModel.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:video_player/video_player.dart';
import 'package:video_trimmer/video_trimmer.dart';

class AddNewFeed extends StatefulWidget {
  static const String addNewFeedScreenRoute = "AddNewFeed";

  const AddNewFeed({Key? key}) : super(key: key);

  @override
  State createState() => _AddNewFeedState();
}

class _AddNewFeedState extends State<AddNewFeed> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isUploading = false;
  File? _images;
  List<dynamic> urlsPet = [];
  ImagePicker imagePicker = ImagePicker();
  bool isVisible = true;
  String userId = '';
  String petId = '';
  String postPicUrl = '';
  String postId = '';
  String petImageUrl = '';
  String petAge = '';
  String petName = '';

  Trimmer trimmer = Trimmer();

  final _formKey = GlobalKey<FormState>();
  TextEditingController description = TextEditingController();
  VideoPlayerController? _controller;
  Future<void>? _video;
  String videopath = '';
  String videoUrl = '';

  late VideoModel videoModel;

  getKeys() async {
    QuerySnapshot snap = await FirebaseCredentials()
        .db
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser!.uid)
        .get();
    Map<String, dynamic> data = snap.docs.first.data() as Map<String, dynamic>;
    if (snap.docs.isNotEmpty) {
      userId = data['ownerId'];
      petId = data['petId'];
      petImageUrl = data['images'][0];
      petName = data['name'];
      petAge = data['age'].toString();
    }
  }

  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      FirebaseCredentials().db.collection('Post').doc(postId).set({
        'petImage': petImageUrl,
        'petName': petName,
        'petAge': petAge,
        'petId': petId,
        'userId': userId,
        'time': dateFormat.format(DateTime.now()),
        'postId': postId,
        'postPicture': value,
        'postDescription': description.text,
      }, SetOptions(merge: true)).then((value) {
        setState(() {
          isUploading = false;
          Navigator.of(context).pop();
        });
      });
    });
  }

  uploadVideo(video) async {
    var reference = FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
    await reference.putFile(video);
    await reference.getDownloadURL().then((value) async {
      DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
      FirebaseCredentials().db.collection('Post').doc(postId).set({
        'petImage': petImageUrl,
        'petName': petName,
        'petAge': petAge,
        'petId': petId,
        'userId': userId,
        'time': dateFormat.format(DateTime.now()),
        'postId': postId,
        'postPicture': value,
        'postDescription': description.text,
      }, SetOptions(merge: true)).then((val) {
        setState(() {
          isUploading = false;
          videoUrl = value;
        });
        Navigator.of(context).pop();
      });
    });
  }

  getPostId() {
    postId = FirebaseCredentials().db.collection('Post').doc().id;
    print(postId);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getKeys();
    getPostId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.redAccent,
            size: 22,
          ),
        ),
        title: const LocaleText(
          "add_your_feed",
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 40,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    videopath == null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              height: 200,
                              width: MediaQuery.of(context).size.width / 1.4,
                              decoration: BoxDecoration(
                                  color: Colors.black12.withOpacity(0.1)),
                              child: _images != null
                                  ? Image.file(
                                      _images!,
                                      fit: BoxFit.cover,
                                    )
                                  : const Center(),
                            ),
                          )
                        : FutureBuilder(
                            future: _video,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                return SizedBox(
                                  height: 200,
                                  width:
                                      MediaQuery.of(context).size.width / 1.4,
                                  child: InkWell(
                                    onTap: () {
                                      if (_controller!.value.isPlaying) {
                                        setState(() {
                                          _controller!.pause();
                                        });
                                      } else {
                                        setState(() {
                                          _controller!.play();
                                        });
                                      }
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: AspectRatio(
                                        aspectRatio:
                                            _controller!.value.aspectRatio,
                                        child: VideoPlayer(_controller!),
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const Center(
                                  child: CircularProgressIndicator(),
                                );
                              }
                            },
                          ),
                    Visibility(
                      visible: isVisible,
                      child: Container(
                        height: 50,
                        width: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black12.withOpacity(0.1),
                        ),
                        child: const Center(child: LocaleText("add_your_feed")),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                title: const LocaleText(
                                  "upload_image",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                content: const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: LocaleText(
                                    "select_photo",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      var pickedFile =
                                          await imagePicker.pickImage(
                                              source: ImageSource.gallery);
                                      setState(() {
                                        isVisible = false;
                                        videopath = '';
                                        if (pickedFile != null) {
                                          _images = File(pickedFile.path);
                                          print(
                                              "Images Length : ${_images!.length}");
                                        } else {
                                          print('No image selected.');
                                        }
                                        //_btnController.reset();
                                      });
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
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
                                              source: ImageSource.camera);
                                      setState(() {
                                        isVisible = false;
                                        videopath = '';
                                        if (pickedFile != null) {
                                          _images = File(pickedFile.path);
                                        } else {
                                          print('No image captured.');
                                        }
                                        //_btnController.reset();
                                      });
                                      if (mounted) {
                                        Navigator.of(context).pop();
                                      }
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
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 29,
                          width: 25,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(
                            Icons.image,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 48,
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: Colors.white,
                                elevation: 5,
                                title: const Padding(
                                  padding: EdgeInsets.only(left: 10.0, top: 10),
                                  child: LocaleText(
                                    "upload_video",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                content: const Padding(
                                  padding: EdgeInsets.only(left: 10.0),
                                  child: LocaleText(
                                    "select_video",
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                                actions: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      var pickedFile =
                                          await imagePicker.pickVideo(
                                              source: ImageSource.gallery,
                                              maxDuration:
                                                  const Duration(minutes: 1));
                                      setState(() async {
                                        isVisible = false;
                                        _images = null;
                                        if (pickedFile != null) {
                                          videopath = pickedFile.path;
                                        } else {
                                          print('No image selected.');
                                        }
                                        _controller =
                                            VideoPlayerController.file(
                                                File(videopath));
                                        _video = _controller!
                                            .initialize()
                                            .then((value) {
                                          setState(() {
                                            _controller!.play();
                                            Navigator.of(context).pop();
                                          });
                                        });
                                      });
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
                                          await imagePicker.pickVideo(
                                        source: ImageSource.camera,
                                        maxDuration: const Duration(seconds: 5),
                                      );
                                      setState(() {
                                        isVisible = false;
                                        _images = null;
                                        if (pickedFile != null) {
                                          videopath = pickedFile.path;
                                        } else {
                                          print('No image captured.');
                                        }
                                      });
                                      _controller = VideoPlayerController.file(
                                          File(videopath));
                                      _video = _controller!
                                          .initialize()
                                          .then((value) {
                                        setState(() {
                                          _controller!.play();
                                          Navigator.of(context).pop();
                                        });
                                      });
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
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          height: 29,
                          width: 25,
                          decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(5)),
                          child: const Icon(
                            Icons.video_camera_back,
                            size: 23,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const SizedBox(
                  height: 20,
                ),
                const LocaleText("feed_description", style: pinkHeadingStyle),
                const SizedBox(
                  height: 10,
                ),
                Container(
                  height: 100,
                  width: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                  ),
                  child: Center(
                    child: TextFormField(
                      keyboardType: TextInputType.visiblePassword,
                      textAlign: TextAlign.center,
                      controller: description,
                      maxLength: 100,
                      buildCounter: (context,
                              {required currentLength, required isFocused, maxLength}) =>
                          null,
                      decoration: InputDecoration(
                        hintText: Locales.string(context, 'feeds_dep'),
                        filled: true,
                        fillColor: Colors.white,
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                isUploading
                    ? const Center(
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.pink,
                          strokeWidth: 2,
                        ),
                      )
                    : GenericBShadowButton(
                        buttonText: Locales.string(context, 'saves'),
                        height: 45,
                        width: 160,
                        onPressed: () async {
                          if (_images != null) {
                            setState(() => isUploading = true);
                            await uploadImage(_images);
                          } else if (videopath != null) {
                            setState(() => isUploading = true);
                            await uploadVideo(File(videopath));
                          }
                        },
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    super.dispose();
  }
}
