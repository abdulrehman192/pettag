import 'package:location/location.dart';

class Address {
  String? id;
  String? description;
  String? address;
  double? latitude;
  double? longitude;
  bool? isDefault;
  String? userId;

  Address();

  Address.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      description = jsonMap['description'] != null ? jsonMap['description'].toString() : null;
      address = jsonMap['address'];
      latitude = jsonMap['latitude'];
      longitude = jsonMap['longitude'];
      isDefault = jsonMap['is_default'] ?? false;
    } catch (e) {
      print(e);
    }
  }

  bool isUnknown() {
    return latitude == null || longitude == null;
  }

  Map toMap() {
    var map = <String, dynamic>{};
    map["id"] = id;
    map["description"] = description;
    map["address"] = address;
    map["latitude"] = latitude;
    map["longitude"] = longitude;
    map["is_default"] = isDefault;
    map["user_id"] = userId;
    return map;
  }


  @override
  String toString() {
    return 'Address{id: $id, description: $description, address: $address, latitude: $latitude, longitude: $longitude, isDefault: $isDefault, userId: $userId}';
  }

  LocationData toLocationData() {
    return LocationData.fromMap({
      "latitude": latitude,
      "longitude": longitude,
    });
  }
}
