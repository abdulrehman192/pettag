import 'package:flutter/material.dart';

const bg = Color(0xFFFFF6F7);
const mainColor = Color(0xFFFC4048);

const String apiKey = 'AIzaSyAyhBpPOOUcNw1QfFjZPI8Nn0xTNB-h2oo';

const pinkHeadingStyle = TextStyle(
  fontSize: 17,
  color: Colors.redAccent,
  fontWeight: FontWeight.w900,
);

enum ProfileTypes {
  standard,
  pettagPlus,
  breeder,
  shelter,
}

final Shader linearGradient = const LinearGradient(
  colors: <Color>[
    Color(0xFFFF1432),
    Color(0xFFFE9315),
  ],
).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

const dialogTitle = TextStyle(
  color: Colors.white,
  fontSize: 17,
  fontWeight: FontWeight.w600,
);

List<String> images = [
  'assets/dogsAndCats/cat0.png',
  'assets/dogsAndCats/cat1.png',
  'assets/dogsAndCats/cat2.png',
  'assets/dogsAndCats/dog0.png',
  'assets/dogsAndCats/dog1.png',
  'assets/dogsAndCats/dog2.png',
  'assets/dogsAndCats/dog3.png',
  'assets/dogsAndCats/dog4.png',
  'assets/dogsAndCats/dog5.png',
  'assets/dogsAndCats/dog6.png',
  'assets/dogsAndCats/dog7.png',
  'assets/dogsAndCats/dog8.png',
  'assets/dogsAndCats/dog9.png',
  'assets/dogsAndCats/dog10.png',
];

List<String> nameListWithoutAge = [
  'Kitty',
  'Thom',
  'Tom',
  'Huskee',
  'Brouno',
  'Bob',
  'Bobby',
  'Boss',
  'Laoshi',
  'Yakh',
  'Pakh',
  'Bob',
  'Uzi',
  'Macci',
];

List<String> nameList = [
  'Kitty, 8',
  'Thom, 12',
  'Tom, 16',
  'Huskee, 12',
  'Brouno, 8',
  'Bob, 12',
  'Bobby, 12',
  'Boss, 20',
];

const Color bgColor = Color(0xFFFFF6F7);
const Color appBarBgColor = Color(0xFFFC3548);

const hintTextStyle = TextStyle(
  color: Colors.black87,
  fontSize: 17,
  fontWeight: FontWeight.w400,
);

const storyTitle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.w800,
  fontSize: 25,
);

const name = TextStyle(
  color: Colors.black,
  fontSize: 22,
  fontWeight: FontWeight.bold,
);

TextStyle kwordStyle({
  double fontSize = 18,
  FontWeight fontWeight = FontWeight.bold,
  Color color = Colors.white,
}) {
  return TextStyle(
    color: color,
    fontSize: fontSize,
    fontWeight: fontWeight,
  );
}

const petDetailButtonHeadings = TextStyle(
  color: Colors.black26,
  fontWeight: FontWeight.bold,
);

Container getHomeScreenImage(String imageName,
    {double circleRadius = 100,
    double imageWidth = 150,
    double imageHeight = 150,
      Color? color,
    double circleSize = 50,
    bool isFullOpacity = false}) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(circleRadius),
      ),
      border: Border.all(
        color: isFullOpacity
            ? Colors.white.withOpacity(0.0)
            : Colors.white.withOpacity(0.8),
      ),
    ),
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: circleSize,

      //backgroundImage:AssetImage(imageName),
      child: Image.asset(
        imageName,
        width: imageWidth,
        height: imageHeight,
        color: color,

      ),
    ),
  );
}

Container getHomeScreenCircularImage(String imageName,
    {double circleRadius = 100,
    double imageWidth = 150,
    double imageHeight = 150,
    double circleSize = 50,
    bool isFullOpacity = false}) {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.all(
        Radius.circular(circleRadius),
      ),
      border: Border.all(
        color: isFullOpacity
            ? Colors.white.withOpacity(0.0)
            : Colors.white.withOpacity(0.8),
      ),
    ),
    child: CircleAvatar(
      backgroundColor: Colors.transparent,
      radius: circleSize,

      //backgroundImage:AssetImage(imageName),
      child: Image.asset(
        imageName,
        width: imageWidth,
        height: imageHeight,
      ),
    ),
  );
}

SizedBox customSizeBox({required double height,required  double width, required Widget child}) {
  return SizedBox(
    height: height,
    width: width,
    child: child,
  );
}

InputDecoration customInputDecoration({
  bool isDense = true,
  bool isFilled = true,
  Color fillColor = Colors.white,
  String hintText = 'Password',
  double borderRadius = 30,
  Color hintTextColor = Colors.black,
}) {
  return InputDecoration(
    isDense: isDense,
    filled: isFilled,
    fillColor: fillColor,
    hintText: hintText,
    hintStyle: TextStyle(
        fontSize: 15, color: hintTextColor, fontWeight: FontWeight.bold),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    contentPadding: const EdgeInsets.only(top: 10, bottom: 10),
  );
}

double currentMediaWidth(BuildContext ctx) {
  return MediaQuery.of(ctx).size.width;
}

double currentMediaHeight(BuildContext ctx) {
  return MediaQuery.of(ctx).size.height;
}

BoxDecoration customBoxDecoration(
    {required
      ImageProvider<Object> image, BoxFit fit = BoxFit.cover, required LinearGradient gradient}) {
  return BoxDecoration(
    image: DecorationImage(image: image, fit: fit),
    gradient: gradient,
  );
}

Padding setPadding(
    {double top = 0.0,
    double bottom = 0.0,
    double right = 0.0,
    double left = 0.0}) {
  return Padding(
      padding: EdgeInsets.only(
    top: top,
    bottom: bottom,
    left: left,
    right: right,
  ));
}
