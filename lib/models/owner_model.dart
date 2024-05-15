import 'package:cloud_firestore/cloud_firestore.dart';

class Person {
  Person(
      {this.age,
      this.description,
      this.email,
      this.firstname,
      this.images,
      this.petId,
      this.lastname,
      this.location,
      this.interest,
      this.gender});

  String? firstname;
  String? lastname;
  String? location;
  int? age;
  String? description;
  List<dynamic>? images;
  String? email;
  String? petId;
  String? interest;
  String? gender;

  toMap() {
    Map<String, dynamic> map = {};
    map['firstname'] = firstname;
    map['lastname'] = lastname;
    map['age'] = age;
    map['description'] = description;
    map['email'] = email;
    map['interest'] = interest;
    map['pet'] = petId;
    map['imagePath'] = images;
    map['gender'] = gender;
  }
}

class Pet {
  Pet({
    this.profileType,
    this.type,
    this.name,
    this.age,
    this.behaviour,
    this.breed,
    this.description,
    this.sex,
    this.size,
    this.ownerId,
    this.petId,
    this.images,
    this.longitude,
    this.latitude,
    this.lockStatus,
    this.visible,
  });

  String? profileType;
  String? type;
  bool? visible;
  bool? haveMyPet;
  String? name;
  String? ownerId;
  String? petId;
  int? age;
  int? ownerAge;
  String? sex;
  String? ownerGender;
  String? size;
  String? breed;
  String? behaviour;
  String? description;
  List<dynamic>? images;
  double? latitude;
  double? longitude;
  bool? lockStatus;
  String? geoHash;
  GeoPoint? location;

  toMap() {
    Map<String, dynamic> map = {};
    map['profileType'] = profileType;
    map['type'] = type;
    map['name'] = name;
    map['age'] = age;
    map['ownerAge'] = ownerAge;
    map['ownerGender'] = ownerGender;
    map['sex'] = sex;
    map['size'] = size;
    map['breed'] = breed;
    map['behaviour'] = behaviour;
    map['description'] = description;
    map['ownerId'] = ownerId;
    map['images'] = images;
    map['petId'] = petId;
    map['latitude'] = latitude;
    map['longitude'] = longitude;
    map['lockStatus'] = lockStatus ?? false;
    map['visible'] = visible;
    map['haveMyPet'] = haveMyPet;
    map['geoHash'] = geoHash;
    return map;
  }
}
