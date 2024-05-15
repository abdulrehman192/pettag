import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../constant.dart';

class MapImageThumbnail extends StatelessWidget {
  MapImageThumbnail({this.url, this.isLeft});

  final String? url;
  final bool? isLeft;
  List<String> latLong = [];

  openMap(BuildContext context, double lat, double lng) async {
    String url = '';
    String urlAppleMaps = '';
    if (Platform.isAndroid) {
      url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    } else {
      urlAppleMaps = 'https://maps.apple.com/?q=$lat,$lng';
      url = 'comgooglemaps://?saddr=&daddr=$lat,$lng&directionsmode=driving';
      if (await launchUrl(Uri.parse(url))) {
        await launchUrl(Uri.parse(url));
      } else {
        throw 'Could not launch $url';
      }
    }

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else if (await canLaunchUrl(Uri.parse(urlAppleMaps))) {
      await launchUrl(Uri.parse(urlAppleMaps));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 10.0, bottom: 10, right: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: isLeft! ? Border.all(color: mainColor) : Border.all(color: Colors.black26,)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: () {
            List<String> firstSplit = url!.split("color%3Ared%7C");
            print(firstSplit.last);
            String temp = firstSplit.last;

            latLong = temp.split("%2C");
            openMap(context, double.parse(latLong.first), double.parse(latLong.last));
            print("${latLong[0]} ${latLong[1]}");
          },
          child: Image.network(
            url!,
            height: 200.0,
            width: 200.0,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
