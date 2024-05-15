import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String? petImageUrl;
  String? petName;
  String? petAge;
  String? petId;
  String? userId;
  String? postId;
  String? time;
  String? picUrl;
  String? postDescription;

  PostModel({
    this.petId,
    this.userId,
    this.picUrl,
    this.postDescription,
    this.postId,
    this.time,
    this.petAge,
    this.petImageUrl,
    this.petName,
  });

  factory PostModel.fromFirestore(DocumentSnapshot data) {

    return PostModel(
      petId: data['petId'].toString(),
      picUrl: data['postPicture'][0].toString(),
      postDescription: data['postDescription'].toString(),
      postId: data['petId'].toString(),
      time: data['time'].toString(),
      userId: data['userId'].toString(),
      petAge: data['petAge'].toString(),
      petImageUrl: data['petImage'].toString(),
      petName: data['petName'].toString(),
    );
  }
}
