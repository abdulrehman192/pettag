import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

extension Distinct<T> on Iterable<T>{
  List<T> distinct() {
    return toSet()
        .toList();
  }
}

class LikedBy {
  String? user_id;
  String? petImage;
  String? petName;
  String? petId;

  LikedBy({this.petId, this.petName, this.petImage, this.user_id});

  factory LikedBy.fromFirebase(Map<String, dynamic> element){
    return LikedBy(
      petId: element["petId"].toString(),
      petName: element['petName'].toString(),
      petImage: element['petImage'].toString(),
      user_id: element["user_id"].toString(),
    );
  }


  isUserSame() {
    return user_id == FirebaseAuth.instance.currentUser!.uid;
  }

  Future<bool> isUserBlocked()async{
    bool block = false;
    await FirebaseFirestore.instance.collection('User').doc(user_id).get().then((value){
      block = value.data()!.containsKey('block_${FirebaseAuth.instance.currentUser!.uid}');
    });
    return block;
  }

  @override
  bool operator == (Object other) {
    if (other is! LikedBy) {
      return false;
    }
    // ignore: test_types_in_equals
    return petId == (other as LikedBy).petId;
  }
  int? _hashCode;

  @override
  int get hashCode {
    _hashCode ??= petId.hashCode;
    return _hashCode!;
  }
}