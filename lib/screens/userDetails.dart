import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/screens/ownerProfile.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/petMediaDialog.dart';
import 'package:pettag/widgets/reportDialog.dart';

class UserDetails extends StatefulWidget {
  static const String userDetailsRoute = "UserDetails";
  final String? petId;
  final String? ownerId;
  final bool? isMyProfile;

  const UserDetails({super.key,  this.petId, this.ownerId,  this.isMyProfile});

  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  Map<String, dynamic> data = {};
  late Future<DocumentSnapshot> snap;

  List<dynamic> imageList = [];

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void initState() {
    super.initState();
    getSnap();
  }

  Future<DocumentSnapshot> getSnap() {
    snap = FirebaseFirestore.instance.collection('Pet').doc(widget.petId).get();
    return snap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        title: const Text(
          "User Details",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder(
                future: snap,
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.data?.data() != null) {
                    data = snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> images = data['images'] ?? [];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.only(top: 15),
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: CircleAvatar(
                                  radius: 35,
                                  backgroundImage: showImage(data['images'][0]),
                                  backgroundColor: Colors.transparent,
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data['name'],
                                    style: name.copyWith(fontSize: 20),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  buildRichText(
                                      "Age: ", data['age'].toString()),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  buildRichText("Size: ", data['size']),
                                  const SizedBox(
                                    height: 2,
                                  ),
                                  buildRichText("Breed: ", data['breed']),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        buildRichText("Pet Behaviour: ", data['behaviour']),
                        const SizedBox(
                          height: 4,
                        ),
                        buildRichText("Pet Description: ", data['description']),
                      ],
                    );
                  }
                  return const CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.pinkAccent,
                  );
                },
              ),
              const SizedBox(
                height: 30,
                child: Divider(
                  height: 2,
                  color: Colors.pink,
                ),
              ),
              StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('User')
                    .doc(widget.ownerId)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return const Text("Something went wrong");
                  }
                  if (snapshot.data?.data() != null) {
                    Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                    List<dynamic> images =
                        data.containsKey("images") ? data['images'] : [];
                    return SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Owner",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.pink, width: 1),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: InkWell(
                                  child: CircleAvatar(
                                    radius: 35,
                                    backgroundImage: showImage(data['images'][0]),
                                    backgroundColor: Colors.white12,
                                  ),
                                  onTap: () {
                                    if (widget.isMyProfile!) {
                                      Navigator.push(context,
                                          MaterialPageRoute(builder: (context) {
                                        return OwnerProfile(
                                          ownerId: widget.ownerId!,
                                          isPreview: false,
                                        );
                                      }));
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(
                                width: 40,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "${data['firstName']} ${data['lastName']}",
                                    style: name.copyWith(fontSize: 20),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          buildRichText(
                              "Owner Description: ", data['description']),
                          const SizedBox(
                            height: 30,
                            child: Divider(
                              height: 2,
                              color: Colors.pink,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return const CircularProgressIndicator(
                    strokeWidth: 2,
                    backgroundColor: Colors.pinkAccent,
                  );
                },
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pet's Media",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    FutureBuilder(
                      future: snap,
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.hasError) {
                          return const Text("Something went wrong");
                        }
                        if (snapshot.data?.data() != null) {
                          Map<String, dynamic> data = snapshot.data!.data() as Map<String, dynamic>;
                          imageList = data['images'] ?? [];
                          return Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: MediaQuery.of(context).size.width,
                            height: 100,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    imageList != null ? imageList.length : 0,
                                itemBuilder: (BuildContext ctx, index) {
                                  return Container(
                                    width: 90,
                                    height: 90,
                                    padding: const EdgeInsets.only(
                                        left: 12, top: 8, bottom: 10),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return PetMediaDialog(
                                                imagePath: imageList[index],
                                              );
                                            });
                                      },
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: data['images'] != null
                                            ? Image.network(
                                                imageList[index],
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                    ),
                                  );
                                }),
                          );
                        }
                        return const Center(
                            child: CircularProgressIndicator(
                          strokeWidth: 2,
                          backgroundColor: Colors.pinkAccent,
                        ));
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
                child: Divider(
                  height: 2,
                  color: Colors.pink,
                ),
              ),
              Center(
                child: GenericBShadowButton(
                  buttonText: "Report This Profile",
                  width: MediaQuery.of(context).size.width / 2,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return ReportDialog(
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }

  RichText buildRichText(String key, String value) {
    return RichText(
      text: TextSpan(
        text: key,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: TextStyle(
                color: Colors.pink[900], fontWeight: FontWeight.normal),
          ),
        ],
      ),
    );
  }

  showImage(String? url) {
    if(url != null)
      {
        return NetworkImage(url);
      }
    else{
      return const AssetImage("assets/profile.png");
    }
  }
}

/**/
