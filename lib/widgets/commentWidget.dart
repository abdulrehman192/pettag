import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/widgets/reportComment.dart';

import '../constant.dart';

class CommentBottomSheetContent extends StatefulWidget {
  final String? userImageUrl;
  final String? userName;
  final DocumentSnapshot<Map<String, dynamic>>? doc;
  final List<Map<String, dynamic>>? commentsList;

  const CommentBottomSheetContent(
      {Key? key, this.userImageUrl, this.userName, this.doc, this.commentsList})
      : super(key: key);

  @override
  State createState() => _CommentBottomSheetContentState();
}

class _CommentBottomSheetContentState extends State<CommentBottomSheetContent> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  List<Map<String, dynamic>> comments = [];

  Widget commentChild(List<Map<String, dynamic>> data) {
    return ListView(
      children: [
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 2.0, 8.0),
            child: InkWell(
              onLongPress: () {
                if (FirebaseAuth.instance.currentUser!.uid ==
                    data[i]['commentorId']) {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {
                        return Wrap(
                          children: <Widget>[
                            ListTile(
                                leading: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                title: const Text('Delete'),
                                onTap: () {
                                  widget.doc!.reference.set({
                                    'comments':
                                        FieldValue.arrayRemove([data[i]])
                                  }, SetOptions(merge: true));
                                  data.removeAt(i);
                                  setState(() {});
                                  //showInSnackBar("Comment Has Been Deleted.");
                                  Navigator.of(context).pop();
                                }),
                            ListTile(
                              leading: const Icon(
                                Icons.edit,
                                color: Colors.green,
                              ),
                              title: const Text('Edit'),
                              onTap: () {
                                Navigator.of(context).pop();
                                TextEditingController messageCont =
                                    TextEditingController();
                                messageCont.text = data[i]['message'];
                                showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (BuildContext bc) {
                                      return Container(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.7,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        padding: const EdgeInsets.all(16),
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.only(
                                              topRight: Radius.circular(10),
                                              topLeft: Radius.circular(10)),
                                        ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 42,
                                                  width: 42,
                                                  decoration:
                                                      const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100),
                                                    child: Image.network(
                                                      data[i]['pic'],
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                SizedBox(
                                                  height: 42,
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width -
                                                      90,
                                                  child: TextFormField(
                                                    controller: messageCont,
                                                    decoration: InputDecoration(
                                                      fillColor:
                                                          Colors.grey[100],
                                                      contentPadding:
                                                          const EdgeInsets.all(
                                                              10),
                                                      enabledBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .transparent),
                                                      ),
                                                      focusedBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                                color: Colors
                                                                    .transparent),
                                                      ),
                                                      errorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    Colors.red),
                                                      ),
                                                      focusedErrorBorder:
                                                          OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        borderSide:
                                                            const BorderSide(
                                                                color:
                                                                    Colors.red),
                                                      ),
                                                      filled: true,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Row(
                                              children: [
                                                const Spacer(),
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.grey[100],
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        "Cancel",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    print(
                                                        "CONTROLLER VALUE ::::::::::::::::::::::::: ${messageCont.text}");

                                                    widget.doc!.reference
                                                        .update({
                                                      'comments': FieldValue
                                                          .arrayRemove(
                                                              [data[i]]),
                                                    });
                                                    data[i]['message'] =
                                                        messageCont.text;

                                                    widget.doc!.reference
                                                        .update({
                                                      'comments':
                                                          FieldValue.arrayUnion(
                                                              [data[i]]),
                                                    });
                                                    setState(() {});
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: Container(
                                                    height: 50,
                                                    width: 120,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                      color: Colors.grey[100],
                                                    ),
                                                    child: const Center(
                                                      child: Text(
                                                        "Update",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color:
                                                                Colors.green),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ],
                                        ),
                                      );
                                    });
                              },
                            ),
                            ListTile(
                                leading: const Icon(
                                  Icons.chat,
                                  color: Colors.black54,
                                ),
                                title: const Text('Report'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    return ReportCommentScreen(
                                      petId: widget.doc!.data()!['petId'],
                                      userId: widget.doc!.data()!['userId'],
                                      reportedComment: data[i]['message'],
                                    );
                                  }));
                                  setState(() {});
                                  //showInSnackBar("Comment Has Been Deleted.");
                                  //Navigator.of(context).pop();
                                }),
                          ],
                        );
                      });
                } else {
                  showModalBottomSheet(
                      context: context,
                      builder: (BuildContext bc) {

                        return Container(
                          child: Wrap(
                            children: <Widget>[
                              ListTile(
                                  leading: const Icon(
                                    Icons.chat,
                                    color: Colors.black54,
                                  ),
                                  title: const Text('Report'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).push(
                                        MaterialPageRoute(builder: (context) {
                                      return ReportCommentScreen(
                                        petId: widget.doc!.data()!['petId'],
                                        userId: widget.doc!.data()!['userId'],
                                        reportedComment: data[i]['message'],
                                      );
                                    }));
                                    setState(() {});
                                    //showInSnackBar("Comment Has Been Deleted.");
                                    //Navigator.of(context).pop();
                                  }),
                            ],
                          ),
                        );
                      });
                }
              },
              child: Container(
                child: Row(
                  children: [
                    Container(
                      height: 40.0,
                      width: 40.0,
                      decoration: const BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.all(Radius.circular(50))),
                      child: CircleAvatar(
                          radius: 50,
                          backgroundImage: showImage(data[i]['pic'])
                    ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey[100],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data[i]['name'],
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(
                            height: 2,
                          ),
                          Text(
                            data[i]['message'],
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
      ],
    );
  }
  showImage(String? url)
  {
    if(url != null)
      {
        return NetworkImage(url);
      }
    else
      {
        return const AssetImage("assets/man.png");
      }
  }
  showInSnackBar(String message) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  initState() {
    comments.addAll(widget.commentsList!);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
        padding:
            EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0))),
        child: CommentBox(
          userImage: NetworkImage(widget.userImageUrl ??
              "https://cdn4.iconfinder.com/data/icons/ionicons/512/icon-ios7-person-1024.png"),
          labelText: 'Write a comment...',
          withBorder: false,
          errorText: 'Comment cannot be blank',
          sendButtonMethod: () {
            if (formKey.currentState!.validate()) {
              setState(() {
                Map<String, dynamic> value = {
                  'name': widget.userName,
                  'pic': widget.userImageUrl,
                  'message': commentController.text,
                  'commentorId': FirebaseAuth.instance.currentUser!.uid,
                  'time': DateTime.now().millisecondsSinceEpoch
                };
                comments.add(value);
                widget.doc!.reference.set({
                  'comments': FieldValue.arrayUnion([value])
                }, SetOptions(merge: true));
              });
              commentController.clear();
              //FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Colors.transparent,
          textColor: Colors.black,
          sendWidget: const Icon(Icons.send_sharp, size: 23, color: mainColor),
          child: commentChild(comments),
        ),
      ),
    );
  }
}
