import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'generic_shadow_button.dart';

class ReportCommentScreen extends StatefulWidget {

  final String userId;
  final String petId;
  final String reportedComment;

  const ReportCommentScreen({super.key, required this.petId, required this.userId, required this.reportedComment});

  @override
  _ReportCommentScreenState createState() => _ReportCommentScreenState();
}

class _ReportCommentScreenState extends State<ReportCommentScreen> {
  int selectedIndex = 0;
  Color complaintColor = Colors.black;

  TextEditingController otherController = TextEditingController();

  Future<void> send({required String body, required String options}) async {

    String emailBody = "Type : $options\n Complaint : $body";
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('User').doc(widget.userId).get();
    Map<String, dynamic> data = documentSnapshot.data() as Map<String, dynamic>;

    await FirebaseFirestore.instance.collection('ReportedComments').doc().set({
      'firstName': data['firstName'],
      'lastName': data['lastName'],
      'image': data['images'].length == 0 ? "" : data['images'][0],
      'comment': widget.reportedComment,
      'userId': widget.userId,
      'reportedById': FirebaseAuth.instance.currentUser!.uid,
      'reason': options,
      'complaint': body,
    }).whenComplete((){
      setState(() {
        isLoading = false;
      });
    });

    /*final Email email = Email(
      body: emailBody,
      subject: 'Report User',
      recipients: ["pettag.llc@gmail.com"],
      attachmentPaths: null,
      isHTML: false,
    );

    String platformResponse;

    try {
      await FlutterEmailSender.send(email).then((value)
      {
        print('Email is Sent');
        String status = 'Send';
        platformResponse = 'Reason email sent to Passenger';

        FirebaseFirestore.instance.collection('hourlyBooking').doc(widget.bookingId).update({'invoiceStatus' : status}).then((value)
        {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });

      });
    } catch (error) {
      platformResponse = error.toString();
    }*/

    // if (!mounted) return;

    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(
    //     content: Text(platformResponse),
    //   ),
    // );

  }

  List<String> reportOptions = [
    'Nudity',
    'Violence',
    'Harassment',
    'Spam',
    'Hate Speech',
    'Terrorism'
  ];

  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Report',
          style: TextStyle(
            fontSize: 17,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(
                Icons.clear,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Comment',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.black87),
              ),
              const Text(
                'You can report a comment after selecting a problem',
                style: TextStyle(
                    color: Colors.black26,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 15,
              ),
              ListView.separated(
                  shrinkWrap: true,
                  itemCount: reportOptions.length,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (context, index) {
                    return Divider(
                      height: 1,
                      color: Colors.grey[200],
                    );
                  },
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(
                        reportOptions[index],
                        style: selectedIndex == index ? const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ) : const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                      trailing: selectedIndex == index
                          ? const Icon(
                              Icons.check,
                              size: 17,
                              color: Colors.black87,
                            )
                          : const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.transparent,
                            ),
                    );
                  }),
              const SizedBox(
                height: 10,
              ),
              RichText(
                text: const TextSpan(
                  text: 'Other ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  children: <TextSpan>[
                    TextSpan(text: '(Optional)', style: TextStyle(fontSize: 16,color: Colors.black45,fontWeight: FontWeight.normal)),
                  ],
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              TextField(
                controller: otherController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Write your complaint here',
                  hintStyle: const TextStyle(color: Colors.black45, fontSize: 14),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: complaintColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: complaintColor, width: 1),
                  ),
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              isLoading ? const Center(child: CircularProgressIndicator(color: Colors.pink,),) : Center(
                child: GenericBShadowButton(
                  height: 50,
                  width: 250,
                  onPressed: (){
                    setState(() {
                      isLoading = true;
                    });
                    send(body: otherController.text, options: reportOptions[selectedIndex]);
                  },
                  buttonText: 'Submit',
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
