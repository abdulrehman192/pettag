import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ImageZoomScreen extends StatefulWidget {
  const ImageZoomScreen({Key? key}) : super(key: key);
  static const String imageZoomScreenRoute = "EmailNotification";
  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  @override
  Widget build(BuildContext context) {

    final arguments = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CachedNetworkImage(imageUrl: arguments,)),
    );
  }
}
