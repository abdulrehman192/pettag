import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pettag/screens/pet_slide_screen.dart';
import '../constant.dart';

class PetDetailScreen extends StatelessWidget {
  const PetDetailScreen({super.key});

  Container buildAppBarImageIcon(
      {required String image, required VoidCallback onPressed}) {
    return Container(
      color: Colors.blue,
      width: 15,
      height: 15,
      child: InkWell(
        onTap: onPressed,
        child: Image.asset(
          image,
          //height: 10,
          //width: 10,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15, top: 0),
      //color: Colors.blue,
      child: ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount: nameList.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                PetSlideScreen.petSlideScreenRouteName,
              );
            },
            child: SizedBox(
              height: 400,
              //color: Colors.teal,
              child: GestureDetector(
                onTap: (){
                  Navigator.pushNamed(
                    context,
                    PetSlideScreen.petSlideScreenRouteName,
                    //TODO: Send your data to petslide screen from here.
                  );
                },
                child: Card(
                  elevation: 0.0,
                  child: Container(
                    padding:
                        const EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 10),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundImage: AssetImage(images[index]),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 15),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nameList[index],
                                    style: name.copyWith(fontSize: 17),
                                  ),
                                  const Text(
                                    '2 min ago',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const Icon(Icons.more_horiz),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 10, right: 5, bottom: 10),
                          child: const Text(
                            "abajhs jshkd h sjksdhf jkdsfhj kdsfjk ds fesfdjkf dfjhdkfhdk sjfksdjks fjkldksfd",                            style: TextStyle(
                              color: Colors.black38,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          height: 190,
                          padding: const EdgeInsets.only(top: 10, right: 5, bottom: 10),
                          child: Image.asset(
                            "assets/dogsAndCats/dog15.jpeg",
                            fit: BoxFit.cover,
                          ),
                        ),
                        Container(
                          //color: Colors.blue,
                          alignment: Alignment.centerRight,
                          width: double.infinity,
                          //color: Colors.blue,
                          height: 40,
                          padding: const EdgeInsets.only(top: 0, right: 5, bottom: 0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, left: 0, right: 0),
                                child: IconButton(
                                    icon: const Icon(FontAwesomeIcons.solidStar, size: 15, color: Colors.pinkAccent,),
                                    onPressed: () {}),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 8, left: 0, right: 0),
                                child: IconButton(
                                    icon: const Icon(FontAwesomeIcons.solidHeart, size: 15, color: Colors.pinkAccent,),
                                    onPressed: () {}),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, left: 10, right: 0),
                                child: Image.asset(
                                  "assets/Icon simple-hipchat.png",
                                  color: Colors.pinkAccent,
                                  fit: BoxFit.contain,
                                  height: 16,
                                  width: 16,
                                ),
                              ),
                              // IconButton(
                              //     icon: Icon(Icons.message, size: 18),
                              //     onPressed: () {}),
                            ],
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
      ),
    );
  }
}
