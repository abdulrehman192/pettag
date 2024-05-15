import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../screens/pet_profile.dart';

class Helper {
  static List<Icon> getStarsList(double rate, {double size = 18}) {
    var list = <Icon>[];
    list = List.generate(rate.floor(), (index) {
      return Icon(Icons.star, size: size, color: const Color(0xFFFFB24D));
    });
    if (rate - rate.floor() > 0) {
      list.add(
          Icon(Icons.star_half, size: size, color: const Color(0xFFFFB24D)));
    }
    list.addAll(
        List.generate(5 - rate.floor() - (rate - rate.floor()).ceil(), (index) {
      return Icon(Icons.star_border,
          size: size, color: const Color(0xFFFFB24D));
    }));
    return list;
  }

  static Future<Uint8List> getByteFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<Marker> getMarkerImage(
      point, imageUrl, petId, Color petColor, BuildContext context) async {
    GeoPoint geoPoint =
        GeoPoint(point.data()['latitude'], point.data()['longitude']);
    return Marker(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return PetProfileScreen(
                  ownerId: point.data()['id'],
                  docId: petId,
                  isJustPreview: true,
                );
              }));
        },
        markerId: MarkerId(point.id),
        icon: await getMarkerIcon(
            point, const Size(130, 130), imageUrl, petColor),
        //icon: BitmapDescriptor.fromBytes(await getByteFromAsset('assets/logo.png',100)),
        anchor: const Offset(0.5, 0.5),
        position: LatLng(geoPoint.latitude, geoPoint.longitude));
  }

  static Future<ui.Image> getImageFromPath(point, shopLogo) async {
    final File markerImageFile =
        await DefaultCacheManager().getSingleFile(shopLogo);
    final Uint8List markerImageBytes = await markerImageFile.readAsBytes();
    ui.Codec codec =
        await ui.instantiateImageCodec(markerImageBytes, targetWidth: 150);
    ui.FrameInfo fi = await codec.getNextFrame();
    final Uint8List markerImage =
        (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
            .buffer
            .asUint8List();
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(markerImage, (ui.Image img) {
      return completer.complete(img);
    });
    return completer.future;
  }

  static Future<BitmapDescriptor> getMarkerIcon(
      firebaseUser, Size size, shopLogo, Color myColor) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);

    final Radius radius = Radius.circular(size.width / 1);

    final Paint tagPaint = Paint()..color = const Color(0xFF313c52);
    const double tagWidth = 20.0;

    final Paint shadowPaint = Paint()..color = myColor;
    //final Paint shadowPaint = Paint()..color =Color(0xFFF20554);
    const double shadowWidth = 5.0;

    final Paint borderPaint = Paint()..color = Colors.white;
    const double borderWidth = 1.0;

    const double imageOffset = shadowWidth + borderWidth;

    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(0.0, 0.0, size.width, size.height),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        shadowPaint);

    // Add border circle
    canvas.drawRRect(
        RRect.fromRectAndCorners(
          Rect.fromLTWH(shadowWidth, shadowWidth,
              size.width - (shadowWidth * 2), size.height - (shadowWidth * 2)),
          topLeft: radius,
          topRight: radius,
          bottomLeft: radius,
          bottomRight: radius,
        ),
        borderPaint);
    // Oval for the image
    Rect oval = Rect.fromLTWH(imageOffset, imageOffset,
        size.width - (shadowWidth * 2), size.height - (shadowWidth * 2));

    // Add path for oval image
    canvas.clipPath(Path()..addOval(oval));

    // Add image
    ui.Image image = await getImageFromPath(firebaseUser,
        shopLogo); // Alternatively use your own method to get the image
    paintImage(canvas: canvas, image: image, rect: oval, fit: BoxFit.fitWidth);

    // Convert canvas to image
    final ui.Image markerAsImage = await pictureRecorder
        .endRecording()
        .toImage(size.width.toInt(), size.height.toInt());

    // Convert image to bytes
    final ByteData? byteData =
        await markerAsImage.toByteData(format: ui.ImageByteFormat.png);
    final Uint8List uint8List = byteData!.buffer.asUint8List();

    return BitmapDescriptor.fromBytes(uint8List);
  }
}
