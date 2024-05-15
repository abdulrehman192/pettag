import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pettag/constant.dart';
import 'package:pettag/screens/pet_detail_screen.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';
import 'package:pettag/widgets/petFood_icon_appbar.dart';

class TopPickedPet extends StatefulWidget {
  static const String TopPickedPetScreenRoute = 'TopPickedPet';

  const TopPickedPet({super.key});

  @override
  _TopPickedPetState createState() => _TopPickedPetState();
}

class _TopPickedPetState extends State<TopPickedPet> {
  bool petChangingSwitch = false;
  InkWell buildAppBarImageIcon(
      {required String image, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      child: Image.asset(image),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarBgColor,
        elevation: 0.0,
        // TODO: Implemenetation Left
        leading: GestureDetector(
          child: Container(
              padding: const EdgeInsets.only(
                right: 20,
                left: 15,
              ),
              child: Image.asset(
                "assets/2x/dog (1)@2x.png",
                width: 15,
                height: 15,
              )),
          onTap: () {},
        ),
        centerTitle: true,
        title: const PetFoodIconInAppBar(),
        actions: [
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 15,
                  left: 5,
                ),
                child: Image.asset(
                  "assets/2x/Icon material-location-on@2x.png",
                  width: 15,
                  height: 15,
                )),
            onTap: () {},
          ),
          GestureDetector(
            child: Container(
                padding: const EdgeInsets.only(
                  right: 15,
                  left: 5,
                ),
                child: Image.asset(
                  "assets/2x/Icon simple-hipchat@2x.png",
                  width: 20,
                  height: 20,
                )),
            onTap: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              width: currentMediaWidth(context),
              height: currentMediaHeight(context),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text('Likes'),
                        Text(
                          'Top Picks',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('Pet Date'),
                      ],
                    ),
                  ),
                  // here is the column generating the grid view
                  SizedBox(
                    height: MediaQuery.of(context).size.height-130,
                    child: GridView.builder(
                      shrinkWrap: true,
                      itemCount: nameList.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 2,
                        crossAxisSpacing: 2,
                        //childAspectRatio: 3 / 4,
                      ),
                      itemBuilder: (context, index) {
                        return SizedBox(
                          //padding: EdgeInsets.symmetric(horizontal: 5),
                          width: 200,
                          height: 150,
                          child: Card(
                            shadowColor: Colors.white,
                            elevation: 2.0,
                            child: GridTile(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 10, bottom: 25, left: 15, right: 15),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: AssetImage(images[index]),
                                      radius: 52,
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          nameList[index],
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.pink,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const Icon(
                                          FontAwesomeIcons.solidHeart,
                                          color: Colors.pinkAccent,
                                          size: 15,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                ],
              ),
            ),
            Positioned(
              bottom: 20,
              right: 10,
              left: 10,
              child: GenericBShadowButton(
                buttonText: 'Unlock Top Pics',
                onPressed: () {
                  Navigator.pushNamed(
                      context, PetDetailedScreen.petDetailedScreenRoute);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}



/*

*/