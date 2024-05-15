import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pettag/models/owner_model.dart';
import 'package:pettag/models/trimmerModel.dart';
import 'package:pettag/models/videoModel.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/addMediaWidget.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:video_trimmer/video_trimmer.dart';

class EditProfileScreen extends StatefulWidget {
  static const String editProfileScreenRoute = "EditProfileScreen";
  final String? id;
  final String? ownerId;
  bool? isPro = false;
  final String? petName;

  EditProfileScreen(
      {Key? key,  this.id, this.ownerId, this.isPro, this.petName})
      : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  File? petImage1;
  File? petImage2;
  File? petImage3;
  File? petImage4;
  File? petImage5;
  File? petImage6;
  File? petImage7;
  File? petImage8;
  File? petImage9;
  File? ownerImage1;
  File? ownerImage2;
  File? ownerImage3;
  bool uploading = false;
  int val = 0;
  int index = 0;
  int ownerIndex = 0;
  bool visibility = false;
  bool ownerVisibility = false;
  int _state = 4;
  int _ownerState = 4;
  bool isLoading = false;
  int mediaCount = 0;
  int videoCount = 0;
  bool videoCancelVisibility = false;
  int videoIndex = 0;
  Uint8List? uint8list;
  String thumbPath = '';

  String videoResult = '';

  CollectionReference? imgRef;

  Trimmer trimmer = Trimmer();

  /*final RoundedLoadingButtonController _btnController =
      new RoundedLoadingButtonController();*/

  final List<File> _images = [];
  final List<File> _ownerImages = [];
  final List<VideoModel> _videos = [];
  List<dynamic> urlsPet = [];
  List<dynamic> urlsOwner = [];
  List<dynamic> imagesPet = [];
  List<dynamic> ownerImages = [];
  List<String> videoUrl = [];
  List<dynamic> petVideos = [];

  final Pet _pet = Pet();

  final FirebaseAuth auth = FirebaseAuth.instance;

  ImagePicker imagePicker = ImagePicker();
  CollectionReference users = FirebaseFirestore.instance.collection('User');
  CollectionReference pet = FirebaseFirestore.instance.collection('Pet');

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCount();
    imgRef = FirebaseFirestore.instance.collection('Pet');
    print("Pet ID : ${widget.id}");
  }

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
            .doc(widget.ownerId)
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

  uploadPetImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      urlsPet.add(value);
      index++;
      if (index == _images.length) {
        _pet.images = urlsPet;
        _images.clear();
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(widget.id)
            .update({'images': FieldValue.arrayUnion(urlsPet)}).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        uploadPetImage(_images[index]);
      }
    });
  }

  getCount() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('packageName')) {
      String? pkg = prefs.getString('packageName');
      if (pkg == 'STANDARD') {
        setState(() {
          mediaCount = 5;
          videoCount = 2;
        });
      } else if (pkg == 'pettagPLUS') {
        setState(() {
          mediaCount = 5 + 5;
          videoCount = 2 + 2;
        });
      } else if (pkg == 'BREEDER') {
        setState(() {
          mediaCount = 30;
        });
      } else if (pkg == 'RESCUER') {
        setState(() {
          mediaCount = 3;
          videoCount = 1;
        });
      }
    }
  }

  uploadVideo(video) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.mp4');
    await reference.putFile(video);
    await reference.getDownloadURL().then((value) async {
      setState(() {
        videoUrl.add(value);
        videoIndex++;
      });
      if (videoIndex == _videos.length) {
        _videos.clear();
        //
        await FirebaseCredentials()
            .db
            .collection('Pet')
            .doc(widget.id)
            .update({'videos': FieldValue.arrayUnion(videoUrl)}).then((value) {
          setState(() {
            isLoading = false;
          });
        });
      } else {
        uploadVideo(File(_videos[videoIndex].path.toString()));
      }
    });
  }

  getThumbnail(url) async {
    await VideoThumbnail.thumbnailFile(
      video: url,
      thumbnailPath: (await getTemporaryDirectory()).path,
      imageFormat: ImageFormat.WEBP,
      maxHeight:
          64, // specify the height of the thumbnail, let the width auto-scaled to keep the source aspect ratio
      quality: 75,
    ).then((value) {
      setState(() {
        thumbPath = value!;
      });
    });

    /*setState(() {
      uint8list;
    });*/
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
            color: Colors.pink,
            size: 22,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: LocaleText(
          widget.isPro! ? "Add ${widget.petName}'s Media" : "add_media",
          style: const TextStyle(
              fontSize: 20, color: Colors.black54, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(
            top: 16.0, right: 20.0, left: 20.0, bottom: 0),
        child: CustomScrollView(
          slivers: <Widget>[
            widget.id!.isEmpty || widget.id == null ?  SliverList(
              delegate: SliverChildListDelegate([
                Container(),
              ]),
            ) :
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const LocaleText(
                    "pet_photo",
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
            widget.id!.isEmpty || widget.id == null ?  SliverList(
              delegate: SliverChildListDelegate([
                Container(),
              ]),
            ) :
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                        .collection('Pet')
                        .doc(widget.id)
                        .snapshots(),
                    builder:
                        (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            backgroundColor: Colors.pink,
                          ),
                        );
                      }

                      if (snapshot.hasData) {
                        print('data : ${snapshot.data!.data()}');
                        Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                        imagesPet = data['images'] ?? [];
                        if (index < imagesPet.length) {
                          visibility = true;
                          _state = 0;
                        } else if (_images.length > index - imagesPet.length) {
                          visibility = true;
                          _state = 1;
                        } else {
                          visibility = false;
                        }
                        return AddMediaWidget(
                          isEmpty: visibility,
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        const Padding(
                                          padding: EdgeInsets.only(left: 10.0),
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
                                              // padding: const EdgeInsets.all(0),
                                              child: const LocaleText(
                                                "cancel",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            ElevatedButton(
                                              onPressed: () async {
                                                var pickedFile =
                                                    await imagePicker.pickImage(
                                                        source: ImageSource
                                                            .gallery);
                                                setState(() {
                                                  visibility = true;
                                                  if (pickedFile != null) {
                                                    petImage1 =
                                                        File(pickedFile.path);
                                                    _images.add(petImage1!);
                                                    print(
                                                        "Images Length : ${_images.length}");
                                                  } else {
                                                    print('No image selected.');
                                                  }
                                                  //_btnController.reset();
                                                });
                                                Navigator.of(context).pop();
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
                                                        source:
                                                            ImageSource.camera);
                                                setState(() {
                                                  visibility = true;
                                                  if (pickedFile != null) {
                                                    petImage1 =
                                                        File(pickedFile.path);
                                                    _images.add(petImage1!);
                                                  } else {
                                                    print('No image captured.');
                                                  }
                                                  //_btnController.reset();
                                                });
                                                Navigator.of(context).pop();
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
                            if (index < imagesPet.length) {
                              print('State : $_state');
                              FirebaseFirestore.instance
                                  .collection("Pet")
                                  .doc(widget.id)
                                  .update({
                                "images":
                                    FieldValue.arrayRemove([imagesPet[index]])
                              });
                              print("Deleted : ${imagesPet[index]}");
                              imagesPet.removeAt(index);
                            } else {
                              print('State : $_state');
                              setState(() {
                                _images.removeAt(index - imagesPet.length);
                              });
                            }
                          },
                          index: index,
                          array: imagesPet,
                          docId: widget.id,
                          child: (index < imagesPet.length)
                              ? imagesPet[index] != null
                                  ? CachedNetworkImage(
                                      imageUrl: imagesPet[index],
                                      fit: BoxFit.cover,
                                    )
                                  : Container()
                              : (_images.isNotEmpty &&
                                      (index - imagesPet.length) <
                                          _images.length)
                                  ? Image.file(
                                      _images[(index) - imagesPet.length],
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
                childCount: mediaCount,
              ),
            ),
            widget.id!.isEmpty || widget.id == null ?  SliverList(
              delegate: SliverChildListDelegate([
                Container(),
              ]),
            ) :
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  const SizedBox(
                    height: 20,
                  ),
                  Divider(
                    height: 1,
                    color: Colors.pink[50],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const LocaleText(
                    "pet_videos",
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
            widget.id!.isEmpty || widget.id == null ?  SliverList(
              delegate: SliverChildListDelegate([
                Container(),
              ]),
            ) :
            SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 15.0,
                crossAxisSpacing: 15.0,
                childAspectRatio: 8.0 / 12.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  int videosLength = _videos.length;
                  return FutureBuilder(
                      future: FirebaseCredentials()
                          .db
                          .collection('Pet')
                          .doc(widget.id)
                          .get(),
                      builder: (context, snapshot) {
                        print("check : ${snapshot.hasData}");
                        if (snapshot.hasData) {

                          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                          petVideos = data['videos'] ?? [];

                          if (index < petVideos.length) {
                            videoCancelVisibility = true;
                            _state = 0;
                          } else if (_videos.length >
                              index - petVideos.length) {
                            videoCancelVisibility = true;
                            _state = 1;
                          } else {
                            videoCancelVisibility = false;
                          }
                          if (index < petVideos.length) {
                            getThumbnail(petVideos[index]);
                            //sleep(Duration(seconds: 3));
                          }

                          /*if(index >= videosLength){
                          videoCancelVisibility = false;
                        }
                        else{
                          videoCancelVisibility = true;
                        }*/
                          return AddMediaWidget(
                            isEmpty: videoCancelVisibility,
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
                                              "upload_video",
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          const Padding(
                                            padding:
                                                EdgeInsets.only(left: 10.0),
                                            child: LocaleText(
                                              "select_video",
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
                                                // padding:const EdgeInsets.all(0),
                                                child: const LocaleText(
                                                  "cancel",
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              const Spacer(),
                                              ElevatedButton(
                                                onPressed: () async {
                                                  var videoFile =
                                                      await imagePicker
                                                          .pickVideo(
                                                              source:
                                                                  ImageSource
                                                                      .gallery);

                                                  if (videoFile != null) {
                                                    await trimmer.loadVideo(
                                                        videoFile: File(
                                                            videoFile.path));
                                                    videoResult =
                                                        (await Navigator.of(
                                                                context)
                                                            .push(TrimmerModel(
                                                                trimmer)))!;
                                                    final uint8list =
                                                        await VideoThumbnail
                                                            .thumbnailData(
                                                      video: videoFile.path,
                                                      imageFormat:
                                                          ImageFormat.JPEG,
                                                      maxHeight: 300,
                                                      maxWidth: 300,
                                                      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                                      quality: 30,
                                                    );
                                                    setState(() {
                                                      _videos.add(VideoModel(
                                                          path: videoResult,
                                                          thumbnail:
                                                              uint8list));
                                                      videoCancelVisibility =
                                                          true;
                                                    });
                                                    print(
                                                        "Video Length : ${_videos.length}");
                                                  } else {
                                                    print('No video selected.');
                                                  }
                                                  //_btnController.reset();
                                                  Navigator.of(context).pop();
                                                },
                                                // padding:const EdgeInsets.all(0),
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
                                                  var videoFile =
                                                      await imagePicker
                                                          .pickVideo(
                                                              source:
                                                                  ImageSource
                                                                      .camera);

                                                  if (videoFile != null) {
                                                    await trimmer.loadVideo(
                                                        videoFile: File(
                                                            videoFile.path));
                                                    videoResult =
                                                        (await Navigator.of(
                                                                context)
                                                            .push(TrimmerModel(
                                                                trimmer)))!;
                                                    final uint8list =
                                                        await VideoThumbnail
                                                            .thumbnailData(
                                                      video: videoFile.path,
                                                      imageFormat:
                                                          ImageFormat.JPEG,
                                                      maxHeight: 300,
                                                      maxWidth: 300,
                                                      // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
                                                      quality: 30,
                                                    );
                                                    setState(() {
                                                      _videos.add(VideoModel(
                                                          path: videoResult,
                                                          thumbnail:
                                                              uint8list));
                                                      videoCancelVisibility =
                                                          true;
                                                    });
                                                    print(
                                                        "Video Length : ${_videos.length}");
                                                  } else {
                                                    print('No video selected.');
                                                  }
                                                  Navigator.of(context).pop();
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
                              _videos.removeAt(index);
                              setState(() {});
                            },
                            index: index,
                            array: imagesPet,
                            docId: widget.id,
                            child: (index < petVideos.length)
                                ? petVideos[index] != null
                                    ? Image.asset(
                                        thumbPath ?? "",
                                        fit: BoxFit.cover,
                                      )
                                    : Container()
                                : (_videos.isNotEmpty &&
                                        (index - petVideos.length) <
                                            _videos.length)
                                    ? Image.memory(
                                        _videos[(index) - petVideos.length]
                                            .thumbnail!,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(),
                          );
                        } else {
                          return const Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.pink,
                              strokeWidth: 2,
                            ),
                          );
                        }
                      });
                },
                childCount: videoCount,
              ),
            ),
            widget.isPro!
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      Container(),
                    ]),
                  )
                : SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        const SizedBox(
                          height: 20,
                        ),
                        Divider(
                          height: 1,
                          color: Colors.pink[50],
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const LocaleText(
                          "owner_image",
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
            widget.isPro!
                ? SliverList(
                    delegate: SliverChildListDelegate([
                      Container(),
                    ]),
                  )
                : SliverGrid(
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
                              .doc(widget.ownerId)
                              .snapshots(),
                          builder: (context,
                              AsyncSnapshot<DocumentSnapshot> snapshot) {
                            if (snapshot.hasData) {
                              Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
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
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(left: 10.0),
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
                                                    // padding: const EdgeInsets.all(0),
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
                                                        ownerVisibility = true;
                                                        if (pickedFile !=
                                                            null) {
                                                          petImage1 = File(
                                                              pickedFile.path);
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
                                                    // padding: const EdgeInsets.all(0),
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
                                                          await imagePicker
                                                              .pickImage(
                                                                  source:
                                                                      ImageSource
                                                                          .camera);
                                                      setState(() {
                                                        ownerVisibility = true;
                                                        if (pickedFile !=
                                                            null) {
                                                          petImage1 = File(
                                                              pickedFile.path);
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
                                                    // padding: const EdgeInsets.all(0),
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
                                        .doc(widget.ownerId)
                                        .update({
                                      "images": FieldValue.arrayRemove(
                                          [ownerImages[index]])
                                    });
                                    print("Deleted : ${ownerImages[index]}");
                                    ownerImages.removeAt(index);
                                  } else {
                                    print('State : $_state');
                                    setState(() {
                                      _ownerImages
                                          .removeAt(index - ownerImages.length);
                                    });
                                  }
                                },
                                index: ownerIndex,
                                array: ownerImages,
                                docId: widget.ownerId,
                                child: (index < ownerImages.length)
                                    ? ownerImages[index] != null
                                        ? CachedNetworkImage(
                                            imageUrl: ownerImages[index],
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
                            onPressed: () {
                              if (_images.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                Timer(const Duration(seconds: 3), () async {
                                  index = 0;
                                  ownerIndex = 0;
                                  await uploadPetImage(_images[0]);
                                  //_btnController.success();
                                });
                              }
                              if (_ownerImages.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                Timer(const Duration(seconds: 3), () async {
                                  index = 0;
                                  ownerIndex = 0;
                                  await uploadOwnerImage(_ownerImages[0]);
                                });
                              }
                              if (_videos.isNotEmpty) {
                                setState(() {
                                  isLoading = true;
                                });
                                uploadVideo(File(_videos[videoIndex].path.toString()));
                              }
                            },
                            buttonText: 'Add Media',
                            width: MediaQuery.of(context).size.width / 2.5,
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
        ),
      ),
    );
  }
}
