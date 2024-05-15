import 'dart:typed_data';

class VideoModel{
  String? path;
  Uint8List? thumbnail;
  bool? isFile;

  VideoModel({this.path,this.thumbnail, this.isFile});
}