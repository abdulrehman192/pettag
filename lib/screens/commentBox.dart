import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../constant.dart';

class CommentPage extends StatefulWidget {
  final String? userImageUrl;
  final String? userName;
  final DocumentSnapshot? snap;

  const CommentPage({Key? key, this.snap, this.userImageUrl, this.userName})
      : super(key: key);

  @override
  State createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  List filedata = [];

  Widget commentChild(data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  // Display the image in large form.
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: NetworkImage(data[i]['pic'])),
                ),
              ),
              title: Text(
                data[i]['name'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['message']),
            ),
          )
      ],
    );
  }

  @override
  void initState() {
    if(widget.snap?.data() != null)
      {
        Map<String, dynamic> map = widget.snap!.data() as Map<String, dynamic>;
        filedata.addAll(map['comments']);
      }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Comment Page"),
        backgroundColor: mainColor,
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: CommentBox(
          userImage: NetworkImage(widget.userImageUrl ?? ""),
          labelText: 'Write a comment...',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () {
            if (formKey.currentState!.validate()) {
              print(commentController.text);
              setState(() {
                var value = {
                  'name': widget.userName,
                  'pic': widget.userImageUrl,
                  'message': commentController.text,
                  'commentorId': FirebaseAuth.instance.currentUser!.uid
                };
                filedata.insert(0, value);
                widget.snap!.reference.set({
                  'comments': FieldValue.arrayUnion([value])
                }, SetOptions(merge: true));
              });
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.black,
          textColor: Colors.black,
          sendWidget: const Icon(Icons.send_sharp, size: 23, color: mainColor),
          child: commentChild(filedata),
        ),
      ),
    );
  }
}
