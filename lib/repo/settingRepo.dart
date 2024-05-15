import 'dart:async';
import 'dart:convert';
import 'package:pettag/models/address.dart' as adrs;
import 'package:pettag/utilities/maps_util.dart';
import 'package:location/location.dart' as loc;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geocoding/geocoding.dart';

Future<dynamic> setCurrentLocation() async {
  var location = loc.Location();
   MapsUtil mapsUtil = MapsUtil();
  final whenDone = Completer();
  adrs.Address address = adrs.Address();
  location.requestService().then((value) async {
    location.getLocation().then((locationData) async {
     /* String _addressName = await mapsUtil.getAddressName(
          new LatLng(_locationData?.latitude, _locationData?.longitude),
          'AIzaSyC3YYz8jqvHY3Yup1lzIdlU51FsjHKH5yE');*/
      var addresses =
          await placemarkFromCoordinates(locationData.latitude!, locationData.longitude!);
      var first = addresses.first;
      address = adrs.Address.fromJSON({
        'address': first.name,
        'latitude': locationData.latitude,
        'longitude': locationData.longitude
      });
      await changeCurrentLocation(address);
      whenDone.complete(address);
    }).timeout(const Duration(seconds: 10), onTimeout: () async {
      await changeCurrentLocation(address);
      whenDone.complete(address);
      return null;
    }).catchError((e) {
      whenDone.complete(address);
      return null;
    });
  });
  return whenDone.future;
}

Future<adrs.Address> changeCurrentLocation(adrs.Address address) async {
  if (!address.isUnknown()) {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('address', json.encode(address.toMap()));
  }
  return address;
}

Future<adrs.Address> getCurrentLocation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  //await prefs.clear();
  if (prefs.containsKey('address')) {
    return adrs.Address.fromJSON(json.decode(prefs.getString('address') ?? ''));
  } else {
    return adrs.Address.fromJSON({});
  }
}
