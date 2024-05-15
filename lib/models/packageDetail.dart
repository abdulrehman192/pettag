import 'dart:collection';

class PackageDetail {
  String? pkgName;
  String? price;
  int? profileCount;
  int? time;
  int? remaining;

  PackageDetail({this.pkgName, this.price, this.profileCount, this.time, this.remaining});

  toMap(){
    Map<String, dynamic>  map = HashMap<String, dynamic>();
    map['pkgName'] = pkgName;
    map['price'] = price;
    map['profileCount'] = profileCount;
    map['time'] = time;
    map['remaining'] = remaining;
    return map;
  }

  PackageDetail.fromJson(Map<String, dynamic> map){
    pkgName =  map['pkgName'];
    price = map['price'];
    profileCount = map['profileCount'] ?? 0;
    time = map['time'];
    remaining = map['remaining'] ?? 0;
  }

  bool isAvailable() {
    return pkgName != null &&
        price != null &&
        profileCount != null &&
        time != null &&
        remaining != null;
  }

  bool isFirst() {
    return profileCount!>0 && remaining!>0 && profileCount==remaining;
  }

  bool isNonZero() {
    return profileCount!>0 && remaining!>0;
  }
}
