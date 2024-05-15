import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettag/chat/widgets/full_size_photo.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import '../constant.dart';

class OwnerProfile extends StatefulWidget {
  static const String ownerProfileScreenRoute = 'OwnerProfileScreen';

  const OwnerProfile({Key? key,  this.ownerId,  this.isPreview}) : super(key: key);

  final String? ownerId;
  final bool? isPreview;

  @override
  _OwnerProfileState createState() => _OwnerProfileState();
}

class _OwnerProfileState extends State<OwnerProfile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  File? _imagesToUpload;
  ImagePicker imagePicker = ImagePicker();
  bool isUploading = false;

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: "$key : ",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.bold,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
                color: Colors.pink[900],
                fontWeight: FontWeight.normal,
                fontSize: 15),
          ),
        ],
      ),
    );
  }

  uploadImage(image) async {
    var reference = firebase_storage.FirebaseStorage.instance
        .ref()
        .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
    await reference.putFile(image);
    await reference.getDownloadURL().then((value) async {
      FirebaseCredentials()
          .db
          .collection('User')
          .doc(auth.currentUser!.uid)
          .update({
        'images': FieldValue.arrayUnion([value])
      }).then((value) {
        setState(() {
          isUploading = false;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.pink,
            size: 22,
          ),
        ),
        title: const LocaleText(
          "owner_description",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          /*ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(
                builder: (context){
                  return EditOwnerInfoScreen(id: widget.ownerId,);
                }
              ));
            },
            child: Text(
              "EDIT",
              style: TextStyle(
                  color: Colors.black45,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),*/
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 0.0),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(widget.ownerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text("Something went wrong");
                }
                if (snapshot.data?.data() != null) {
                  Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic> ;
                  List<dynamic> images = data['images'] ?? [];
                  print('images : $images');
                  return CustomScrollView(
                    slivers: [
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: InkWell(
                                  child: CircleAvatar(
                                    radius: 60,
                                    backgroundImage: showImage(images.isNotEmpty ? images.first : null),
                                    backgroundColor: Colors.white12,
                                  ),
                                  
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 30.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${data['firstName']} ${data['lastName']}",
                                      style: name.copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '${Locales.string(context, 'age')}  ',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "${data['age']}",
                                            style: TextStyle(
                                                color: Colors.pink[900],
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),
                                    RichText(
                                      text: TextSpan(
                                        text: '${Locales.string(context, 'interested_in')} : ',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: <TextSpan>[
                                          TextSpan(
                                            text: "${data['interest']}",
                                            style: TextStyle(
                                                color: Colors.pink[900],
                                                fontWeight: FontWeight.normal,
                                                fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ),

                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.pink[100],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Container(
                            child: buildRichText(Locales.string(context, 'owner_description'),
                                "${data['description']}"),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Divider(
                            height: 1,
                            color: Colors.pink[100],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const LocaleText(
                            "owner_media",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                      SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 15.0,
                          crossAxisSpacing: 15.0,
                          childAspectRatio: 8.0 / 12.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: InkWell(
                                    onTap: (){
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context){
                                        return FullSizeImage(url: images[index],);
                                      }));
                                    },
                                    child: Container(
                                      height: 190,
                                      width: 120,
                                      color: Colors.black12,
                                      child: Image.network(
                                        images[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                widget.isPreview == null || widget.isPreview == true ? Container(): Positioned(
                                  top: 0,
                                  left: 0,
                                  child: InkWell(
                                      onTap: () {
                                        FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(auth.currentUser!.uid)
                                            .update({
                                          'images': FieldValue.arrayRemove(
                                              [images[index]])
                                        });
                                      },
                                      child: const Icon(
                                        Icons.highlight_remove_sharp,
                                        color: Colors.black,
                                      )),
                                ),
                              ],
                            );
                          },
                          childCount: images.length ?? 1,
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(
                            height: 20,
                          ),
                          widget.isPreview == null || widget.isPreview == true ? Container() : isUploading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    backgroundColor: Colors.pink,
                                    strokeWidth: 2,
                                  ),
                                )
                              : GenericBShadowButton(
                                  buttonText: 'Add Owner Media',
                                  height: 50,
                                  width: 300,
                                  onPressed: () async {
                                    await showDialog(
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
                                                    padding:
                                                        EdgeInsets.only(
                                                            left: 10.0,
                                                            top: 10),
                                                    child: Text(
                                                      "Upload Image",
                                                      style: TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 17,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(
                                                    height: 10,
                                                  ),
                                                  const Padding(
                                                    padding:
                                                        EdgeInsets.only(
                                                            left: 10.0),
                                                    child: Text(
                                                      "Select a Photo..",
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
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                          "CANCEL",
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
                                                              await imagePicker
                                                                  .pickImage(
                                                                      source: ImageSource
                                                                          .gallery);
                                                          setState(() {
                                                            //visibility = true;
                                                            if (pickedFile !=
                                                                null) {
                                                              _imagesToUpload =
                                                                  File(pickedFile
                                                                      .path);

                                                              print(
                                                                  "Images Length : $_imagesToUpload");
                                                            } else {
                                                              print(
                                                                  'No image selected.');
                                                            }
                                                            //_btnController.reset();
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                        child: const Text(
                                                          "GALLERY",
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
                                                                      source: ImageSource
                                                                          .camera);
                                                          setState(() {
                                                            //visibility = true;
                                                            if (pickedFile !=
                                                                null) {
                                                              _imagesToUpload =
                                                                  File(pickedFile
                                                                      .path);
                                                            } else {
                                                              print(
                                                                  'No image captured.');
                                                            }
                                                            //_btnController.reset();
                                                          });
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                         child: const Text(
                                                          "CAMERA",
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
                                        });
                                    if (_imagesToUpload != null) {
                                      setState(() {
                                        isUploading = true;
                                      });
                                      uploadImage(_imagesToUpload);
                                    }
                                  },
                                ),
                          const SizedBox(
                            height: 20,
                          ),
                        ]),
                      ),
                    ],
                  );
                }
                return const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              }),
        ),
      ),
    );
  }

  showImage(String? url) {
    if(url == null)
    {
      return const AssetImage("assets/ownerProfile.png");
    }
    else
    {
      return NetworkImage(url);
    }
  }
}
/*StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .doc(auth.currentUser.uid)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text("Something went wrong");
                }
                if(snapshot.hasData){
                  Map<String, dynamic> data = snapshot.data.data();
                  List<dynamic> _images = data['images'] ?? [];
                  return Column(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.pink, width: 1),
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: InkWell(
                              child: CircleAvatar(
                                radius: 60,
                                backgroundImage: _images.isNotEmpty ? NetworkImage(_images[0]) : AssetImage('assets/ownerProfile.png'),
                                backgroundColor: Colors.white12,
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, OwnerProfile.ownerProfileScreenRoute);
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${data['firstName']} ${data['lastName']}",
                                  style: name.copyWith(fontSize: 20),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                buildRichText('Age', "${data['age'] ?? 0}"),
                                buildRichText('Interested In', "${data['interest']}"),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(height: 1, color: Colors.pink[100],),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        child: buildRichText("Description", "SJWE WEJNWE FNWEJNFJWE NEFJNWJKF JKWNFJ NWJKFN WJKN"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Divider(height: 1, color: Colors.pink[100],),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 300,
                        child: GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 15.0,
                            crossAxisSpacing: 15.0,
                            childAspectRatio: 8.0 / 12.0,
                          ),
                          scrollDirection: Axis.vertical,
                          itemCount: _images.length,
                          itemBuilder: (BuildContext context, int index){
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 190,
                                width: 120,
                                color: Colors.black12,
                                child: Image.network(_images[index], fit: BoxFit.cover,),
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  );
                }
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.pink,
                    strokeWidth: 2,
                  ),
                );
              }
            )*/
