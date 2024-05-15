import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:pettag/models/packageDetail.dart';
import 'package:shared_preferences/shared_preferences.dart';

ValueNotifier<PackageDetail> pkg = ValueNotifier(PackageDetail.fromJson({}));

Future<PackageDetail> storePkgInfo(PackageDetail packageDetail) async {
  if (packageDetail.isAvailable()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('packageDetail', json.encode(packageDetail.toMap()));

  }
  return packageDetail;
}

Future<PackageDetail> storeProfileInfo(key, PackageDetail packageDetail) async {
  if (packageDetail.isAvailable()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, json.encode(packageDetail.toMap()));
  }
  return packageDetail;
}

Future<PackageDetail> getPkgInfo() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey('packageDetail')) {
    return PackageDetail.fromJson(
        json.decode(prefs.getString('packageDetail') ?? ''));
  } else {
    return PackageDetail.fromJson({});
  }
}
