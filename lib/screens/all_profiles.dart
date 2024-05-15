/*
import 'package:flutter/material.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/repo/paymentRepo.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/pet_chat_screen.dart';
import 'package:pettag/widgets/petFood_icon_appbar.dart';
import 'package:pettag/screens/addNewProfile.dart';
import 'package:responsive_grid/responsive_grid.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pettag/repo/paymentRepo.dart' as repo;
import 'package:pettag/models/packageDetail.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'my_map.dart';
import 'ptPlus.dart';
import 'package:pettag/loc/home.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllProfiles extends StatefulWidget {
  static const String allProfilesScreenRoute = "AllProfiles";

  @override
  _AllProfilesState createState() => _AllProfilesState();
}

class _AllProfilesState extends State<AllProfiles> {
  int itemsCount = 0;
  int limit;
  int remaining;
  bool lockStatus = false;
  List<Widget> profileWidgetList = [];

  PageController pageController = PageController();

  @override
  void initState() {
    super.initState();
    getPackage();
    repo.pkg.addListener(() {
      print(repo.pkg.value.remaining);
      updateProfile(repo.pkg.value);
    });
  }

  updateProfile(PackageDetail value) {
    profileWidgetList.clear();
    for (int i = 0; i <= (value.profileCount - value.remaining); i++) {
      profileWidgetList.add(Container(
        height: 200,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        color: Colors.white,
        child: FutureBuilder(
            future: FirebaseCredentials()
                .db
                .collection('Pet')
                .where('ownerId',
                    isEqualTo: FirebaseCredentials().auth.currentUser.uid)
                .get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasData) {
                print(
                    "Length of List : ${snapshot.data.docs[i].data().length}");
                Map<String, dynamic> data = snapshot.data.docs[i].data();
                String ownerId = data['ownerId'];
                String petId = data['petId'];
                bool lock = data.containsKey('lockStatus')
                    ? data['lockStatus']
                    : true;
                lockStatus = lock;
                return InkWell(
                  onTap: () {
                    lock
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return MySearchDialog();
                            },
                          )
                        : Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                            return PTPlus(
                              ownerId: ownerId,
                              petId: petId,
                            );
                          }));
                  },
                  child: lock
                      ? Icon(
                          Icons.lock,
                          size: 40,
                          color: Colors.black38,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return PetProfileScreen(
                                    ownerId: ownerId,
                                    docId: petId,
                                    isJustPreview: true,
                                  );
                                }));
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.pink, width: 2),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Colors.white,
                                  backgroundImage: data['images'].isNotEmpty
                                      ? NetworkImage(data['images'][0])
                                      : AssetImage('assets/profile.png'),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Text(
                              data['name'],
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            */
/*CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          data['images'][0],
                        ),
                      ),
                      Text(data['name'], style: TextStyle(color: Colors.pink, fontSize: 20)),*/ /*

                          ],
                        ),
                );
              } else {
                return Container();
              }
            }),
      ));
    }
    */
/*profileWidgetList.add(ResponsiveGridCol(
      xs: 6,
      md: 3,
      child: Container(
        height: 100,
        margin: EdgeInsets.all(5),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              //    color: Theme.of(context).focusColor.withOpacity(0.2),
            ),
            borderRadius: BorderRadius.circular(4)),
        child: FutureBuilder(
            future: FirebaseCredentials().db.collection('Pet').where('ownerId', isEqualTo: FirebaseCredentials().auth.currentUser.uid).get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if(snapshot.hasData){
                Map<String, dynamic> data = snapshot.data.docs[0].data();
                String ownerId = data['ownerId'];
                String petId = data['petId'];
                print("PetId To Be Sent To PTPlus : $petId");
                return InkWell(
                  onTap: ()async{
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context){
                        return PTPlus(ownerId: ownerId, petId: petId,);
                      }
                    ));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(
                          data['images'][0],
                        ),
                      ),
                      Text(data['name'], style: TextStyle(color: Colors.pink, fontSize: 20)),
                    ],
                  ),
                );
              }
              else{
                return Container();
              }
            }
        )
      ),
    ));*/ /*

    profileWidgetList.add(Container(
      height: 200,
      margin: EdgeInsets.all(5),
      padding: EdgeInsets.all(12),
      color: Colors.white,
      child: InkWell(
          onTap: () async {
            if (repo.pkg.value.isNonZero()) {
              lockStatus
                  ? showDialog(
                      context: context,
                      builder: (context) {
                        return MySearchDialog();
                      },
                    )
                  : await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                      return AddNewProfileScreen(
                        package: repo.pkg.value,
                      );
                    }));
              setState(() {});
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return MySearchDialog();
                },
              );
            }
          },
          child: Center(child: Icon(Icons.add))),
    ));
    if (mounted) {
      setState(() {});
    }
  }

  getPackage() async {
    await repo.getPkgInfo().then((value) {
      repo.pkg.value = value;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      repo.pkg.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0.0,
        leading: GestureDetector(
          child: Container(
              padding: EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 20,
                height: 20,
              )),
          onTap: () {
            Navigator.pushNamed(
                context, PetSlideScreen.petSlideScreenRouteName);
          },
        ),
        centerTitle: true,
        title: PetFoodIconInAppBar(
          isLeft: true,
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                  right: 30,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 17,
                  height: 17,
                )),
            onTap: () {
              */
/*Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Home();
              }));*/ /*

              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyMap(
                  isVisible: true,
                );
              }));
            },
          ),
          GestureDetector(
            child: Container(
                padding: EdgeInsets.only(
                  right: 20,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon simple-hipchat@2x.png",
                  width: 22,
                  height: 22,
                )),
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.all(16),
        child:Container(
          height: 300,
          width: 200,
          color: Colors.black,
          child: PageView(
            controller: pageController,
            scrollDirection: Axis.horizontal,
            children:
              profileWidgetList.isEmpty ? [Container(
                height: 200,
                margin: EdgeInsets.all(5),
                padding: EdgeInsets.all(12),
                color: Colors.white,
                child: InkWell(
                  onTap: () async {
                    if (repo.pkg.value.isNonZero()) {
                      lockStatus
                          ? showDialog(
                        context: context,
                        builder: (context) {
                          return MySearchDialog();
                        },
                      )
                          : Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                            return AddNewProfileScreen(
                              package: repo.pkg.value,
                            );
                          }));
                    }
                    */
/*if (package.isFirst()) {
                      limit = package.remaining;
                    } else {
                      if (package.isNonZero()) {
                        limit = package.remaining - 1;
                      }
                      setState(() {});
                      print(limit);
                    }*/ /*

                    // storeProfileInfo('')
                  },
                  child: Center(
                    child: CircleAvatar(
                      radius: 40,
                      child: Icon(Icons.add),
                    ),
                  ),
                ),
              ),] : profileWidgetList,
          ),
        ),
        */
/*ResponsiveGridRow(
            children: profileWidgetList.isEmpty
                ? [
                    ResponsiveGridCol(
                      xs: 6,
                      md: 3,
                      child: Container(
                        height: 200,
                        margin: EdgeInsets.all(5),
                        padding: EdgeInsets.all(12),
                        color: Colors.white,
                        child: InkWell(
                          onTap: () async {
                            if (repo.pkg.value.isNonZero()) {
                              lockStatus
                                  ? showDialog(
                                      context: context,
                                      builder: (context) {
                                        return MySearchDialog();
                                      },
                                    )
                                  : Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                      return AddNewProfileScreen(
                                        package: repo.pkg.value,
                                      );
                                    }));
                            }
                            */ /*
*/
/* if (package.isFirst()) {
                        limit = package.remaining;
                      } else {
                        if (package.isNonZero()) {
                          limit = package.remaining - 1;
                        }
                        setState(() {});
                        print(limit);
                      }*/ /*
*/
/*
                            // storeProfileInfo('')
                          },
                          child: Center(
                            child: CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.add),
                            ),
                          ),
                        ),
                      ),
                    )
                  ]
                : profileWidgetList),*/ /*

      ),
    );
  }
}

class Cards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {}
}
*/
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/screens/pet_profile.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import 'package:pettag/screens/pet_chat_screen.dart';
import 'package:pettag/screens/settings_screen.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/petFood_icon_appbar.dart';
import 'package:pettag/screens/addNewProfile.dart';
import 'package:pettag/repo/paymentRepo.dart' as repo;
import 'package:pettag/models/packageDetail.dart';
import 'package:pettag/widgets/mySearchDialog.dart';
import 'package:url_launcher/url_launcher.dart';
import '../main.dart';
import 'editOwnerInfo.dart';
import 'edit_info.dart';
import 'edit_profile.dart';
import 'my_map.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';

class AllProfiles extends StatefulWidget {
  static const String allProfilesScreenRoute = "AllProfiles";

  const AllProfiles({super.key});

  @override
  _AllProfilesState createState() => _AllProfilesState();
}

class _AllProfilesState extends State<AllProfiles> {
  int itemsCount = 0;
  int _current = 0;
  int limit =0;
  int remaining =0;
  bool lockStatus = false;
  List<Widget> profileWidgetList = [];
  List<String> petIds = [];
  List<String> petNames = [];

  String petId = '';
  String ownerId = '';
  String petName = '';

  PageController pageController = PageController();
  final CarouselController _controller = CarouselController();

  @override
  void initState() {
    super.initState();

    getPackage();
    repo.pkg.addListener(() {
      print(repo.pkg.value.remaining);
      updateProfile(repo.pkg.value);
    });
  }

  updateProfile(PackageDetail value) {
    profileWidgetList.clear();
    for (int i = 0; i <= (value.profileCount! - value.remaining!); i++) {
      profileWidgetList.add(Container(
        width: 300,
        height: 300,
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: FutureBuilder(
            future: FirebaseCredentials().db.collection('Pet')
                .where('ownerId',
                    isEqualTo: FirebaseCredentials().auth.currentUser!.uid)
                .get(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.data!.docs.isNotEmpty) {
                print(snapshot.data!.docs.length);
                Map<String, dynamic> data = snapshot.data!.docs[i].data() as Map<String, dynamic>;
                /*ownerId = data['ownerId'];*/
                bool lock = data.containsKey('lockStatus') ? data['lockStatus'] : true;
                lockStatus = lock;
                return InkWell(
                  onTap: () {
                    lock
                        ? showDialog(
                            context: context,
                            builder: (context) {
                              return MySearchDialog();
                            },
                          )
                        : Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                            return PetProfileScreen(
                              ownerId: FirebaseCredentials().auth.currentUser!.uid,
                              docId: petIds[i],
                              isJustPreview: true,
                            );
                          }));
                  },
                  child: lock
                      ? const Icon(
                          Icons.lock,
                          size: 40,
                          color: Colors.black38,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Colors.pink, width: 2),
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    backgroundImage: showImage(data['images'][0]),
                                  ),
                                ),
                                Positioned(
                                  top: 5,
                                  right: 5,
                                  child: InkWell(
                                    onTap: () {
                                      if (repo.pkg.value.isNonZero()) {
                                        lockStatus
                                            ? showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return MySearchDialog();
                                                },
                                              )
                                            : Navigator.push(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                                return AddNewProfileScreen(
                                                  package: repo.pkg.value,
                                                );
                                              }));
                                      } else {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return MySearchDialog();
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      height: 25,
                                      width: 25,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white,
                                      ),
                                      child: const Icon(
                                        Icons.add,
                                        color: Colors.black,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              data['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                );
              } else {
                return Container();
              }
            }),
      ));
    }
    /*profileWidgetList.add(Container(
      width: 300,
      height: 300,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
          onTap: () async {
            if (repo.pkg.value.isNonZero()) {
              lockStatus
                  ? showDialog(
                      context: context,
                      builder: (context) {
                        return MySearchDialog();
                      },
                    )
                  : await Navigator.push(context,
                      MaterialPageRoute(builder: (context) {
                      return AddNewProfileScreen(
                        package: repo.pkg.value,
                      );
                    }));
              setState(() {});
            } else {
              showDialog(
                context: context,
                builder: (context) {
                  return MySearchDialog();
                },
              );
            }
          },
          child: Center(child: Icon(Icons.add))),
    ));*/
    if (mounted) {
      setState(() {});
    }
  }

  getPackage() async {
    await repo.getPkgInfo().then((value) {
      repo.pkg.value = value;
      // ignore: invalid_use_of_visible_for_testing_member, invalid_use_of_protected_member
      repo.pkg.notifyListeners();
    });
  }
  final privacyPolicyLink = "https://pettagcom-95658f.ingress-erytho.easywp.com/";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: sharedPrefs.currentUserPetType == 'Cat'
            ? Colors.blue[600]
            : const Color(0xFFFC4048),
        elevation: 0.0,
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(
                right: 15,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 20,
                height: 20,
              )),
          onTap: () {
            Navigator.pushNamed(
                context, PetSlideScreen.petSlideScreenRouteName);
          },
        ),
        centerTitle: true,
        title: const PetFoodIconInAppBar(
          isLeft: true,
        ),
        actions: [
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 30,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 17,
                  height: 17,
                )),
            onTap: () {
              /*Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Home();
              }));*/
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return MyMap(
                  isVisible: true,
                  isChatSide: false,
                  peerId: '',
                );
              }));
            },
          ),
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 20,
                  left: 15,
                ),
                child: Image.asset(
                  "assets/2x/Icon simple-hipchat@2x.png",
                  width: 22,
                  height: 22,
                )),
            onTap: () {
              Navigator.pushNamed(context, PetChatScreen.petChatScreenRoute);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CarouselSlider(
              carouselController: _controller,
              options: CarouselOptions(
                onPageChanged: (index, reason) {
                  setState(() {
                    _current = index;
                    petId = petIds[index];
                    petName = petNames[index];
                    print("Pet Id on Scroll ::::::::::::: $petId");
                    print("Pet Name on Scroll ::::::::::::: $petName");
                  });
                },
                height: 250,
                autoPlayInterval: const Duration(seconds: 3),
                aspectRatio: 16 / 9,
                autoPlay: false,
                enlargeCenterPage: true,
                reverse: false,
                disableCenter: true,
                enableInfiniteScroll: false,
              ),
              items: profileWidgetList.isEmpty
                  ? [
                      Container(),
                    ]
                  : profileWidgetList,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: FutureBuilder(
                  future: FirebaseCredentials()
                      .db
                      .collection('Pet')
                      .where('ownerId',
                          isEqualTo: FirebaseCredentials().auth.currentUser!.uid)
                      .get(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasData) {

                      List<String> imageUrls = [];
                      for (var element in snapshot.data!.docs) {
                        Map<String, dynamic> map = element.data() as Map<String, dynamic>;

                        imageUrls.add(map['images'][0]);
                        petIds.add(map['petId']);
                        petNames.add(map['name']);
                      }
                      double dimensions = 50;
                      return Wrap(
                        direction: Axis.horizontal,
                        spacing: MediaQuery.of(context).size.width*0.1,
                        children: imageUrls.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () {
                              dimensions = 50.0;
                              setState(() {
                                petId = petIds[_current];
                                petName = petNames[_current];
                              });
                              _controller.animateToPage(entry.key);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: _current == entry.key ? dimensions : 40.0,
                              height: _current == entry.key ? dimensions : 40.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 0.0),
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: NetworkImage(imageUrls[entry.key]),
                                      fit: BoxFit.cover),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      width: 1,
                                      color: _current == entry.key
                                          ? mainColor
                                          : Colors.transparent)),
                            ),
                          );
                        }).toList(),
                      );
                    } else {
                      return Wrap(
                        direction: Axis.horizontal,
                        children: profileWidgetList.asMap().entries.map((entry) {
                          return GestureDetector(
                            onTap: () => _controller.animateToPage(entry.key),
                            child: Container(
                              width: 12.0,
                              height: 12.0,
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 4.0),
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: (Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.yellow
                                          : Colors.black)
                                      .withOpacity(
                                          _current == entry.key ? 0.9 : 0.4)),
                            ),
                          );
                        }).toList(),
                      );
                    }
                  }),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      child: Container(
                        padding: const EdgeInsets.all(15),
                        height: 70,
                        width: 70,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: Image.asset(
                          "assets/2x/Icon ionic-ios-settings@2x.png",
                        ),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                            context, SettingsScreen.settingsScreenRoute);
                      },
                    ),
                    Stack(
                      children: [
                        InkWell(
                          //radius: 30,
                          child: Container(
                            width: 70,
                            height: 70,
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                                color: const Color(0xFFF22C6D),
                                borderRadius: BorderRadius.circular(100),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: Offset(0, 0),
                                  ),
                                ]),
                            child: Image.asset(
                                "assets/2x/Icon material-linked-camera@2x.png"),
                          ),
                          onTap: () {
                            print("Pet Id On Profile Edit ::::::::: $petId");
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return EditProfileScreen(
                                id: petId,
                                ownerId: FirebaseAuth.instance.currentUser!.uid,
                                isPro: true,
                                petName: petName,
                              );
                            }));
                          },
                        ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: Image.asset(
                                "assets/2x/Icon feather-plus-circle@2x.png"),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      child: Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                                offset: Offset(0, 0),
                              ),
                            ]),
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            "assets/2x/Icon awesome-pencil-alt@2x.png",
                          ),
                        ),
                      ),
                      onTap: () async {
                        print("Pet Id On Info Edit ::::::::: $petId");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return EditInfoScreen(
                            id: petId,
                            ownerId: FirebaseAuth.instance.currentUser!.uid,
                            isPro: true,
                            petName: petName,
                          );
                        }));
                      },
                    ),
                    InkWell(
                      child: Container(
                        height: 70,
                        width: 70,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(100), boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                            spreadRadius: 1,
                            offset: Offset(0, 0),
                          ),
                        ]),
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: Image.asset(
                            "assets/bag.png",
                            color: const Color(0xFFF22C6D),
                          ),
                        ),
                      ),
                      onTap: () async {
                        if (await canLaunch(privacyPolicyLink)) {
                          await launch(privacyPolicyLink);
                        } else {
                          throw 'Could not launch $privacyPolicyLink';
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            GenericBShadowButton(
              buttonText: Locales.string(context, 'edit_owner_profile'),
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return EditOwnerInfoScreen(
                    id: FirebaseAuth.instance.currentUser!.uid,
                  );
                }));
              },
            ),
          ],
        ),
      ),
    );
  }

  showImage(String? url) {
    if(url == null)
      {
        return const AssetImage("assets/profile.png");
      }
    else
      {
        return NetworkImage(url);
      }
  }
}


