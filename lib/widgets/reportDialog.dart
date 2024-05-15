import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ReportDialog extends StatefulWidget {

  String? petId;
  String? ownerId;

  ReportDialog({ this.petId,  this.ownerId});

  @override
  _ReportDialogState createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  TextEditingController reportCont = TextEditingController();

  Color reportColor = Colors.black;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      elevation: 5,
      insetPadding: const EdgeInsets.all(10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: SizedBox(
        height: 310,
        width: 330,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.close_sharp,
                color: Colors.black38,
              ),
            ),
            const Center(
              child: Text(
                "Report User",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 22,
                    fontWeight: FontWeight.w900),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: TextFormField(
                  buildCounter: (context, {required currentLength, required isFocused, maxLength}) => null,
                  controller: reportCont,
                  maxLength: 200,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter Your Reason(within 200 letter)",
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: reportColor, width: 1)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: reportColor, width: 1)
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: ()async{
                      await FirebaseFirestore.instance.collection('User').doc(widget.ownerId).set(
                          {
                            'block_${FirebaseAuth.instance.currentUser!.uid}' : true,
                          }, SetOptions(merge: true));

                      await FirebaseFirestore.instance.collection('Pet').doc(widget.petId).set(
                          {
                            'block_${FirebaseAuth.instance.currentUser!.uid}' : true,
                          }, SetOptions(merge: true));

                      const snackBar = SnackBar(content: Text("User has been blocked"));
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    },
                    child: Container(
                      height: 60,
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(color: Colors.redAccent, width: 2)
                      ),
                      child: const Center(
                        child: Text(
                          "Block",
                          style: TextStyle(color: Colors.black, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  isLoading ? const Center(child: CircularProgressIndicator(color: Colors.pink,),) : InkWell(
                    onTap: () {
                      if(reportCont.text.isNotEmpty){
                        setState(() {
                          isLoading = true;
                        });
                        send(body: reportCont.text);
                      }
                      else{
                        setState(() {
                          reportColor = Colors.red;
                        });
                      }
                    },
                    child: Container(
                      height: 60,
                      width: 130,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.red[800],
                      ),
                      child: const Center(
                        child: Text(
                          "Report",
                          style: TextStyle(color: Colors.white, fontSize: 17,fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> send({required String body}) async {

    DocumentSnapshot ownerDoc = await FirebaseFirestore.instance.collection("User").doc(widget.ownerId).get();
    QuerySnapshot petDoc = await FirebaseFirestore.instance.collection("Pet").where('ownerId', isEqualTo: widget.ownerId).get();

    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('ReportedUsers').doc("${widget.ownerId}-${FirebaseAuth.instance.currentUser!.uid}").get();

    if(doc.exists){
      print("Already reported.");
    }else{
      DocumentReference reportDoc = FirebaseFirestore.instance.collection("ReportedUsers").doc("${widget.ownerId}-${FirebaseAuth.instance.currentUser!.uid}");
      Map<String, dynamic> data = ownerDoc.data() as Map<String, dynamic>;

      await reportDoc.set({
        'userId': data['id'],
        'firstName': data['firstName'],
        'lastName': data['lastName'],
        'image': data['images'].length==0 ? "" : data['images'][0],
        'reason': body,
        'petIds': FieldValue.arrayUnion(data['pet'])
      });
    }
    setState(() {
      isLoading = false;
    });

    /*final Email email = Email(
      body: body,
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
      });
    } catch (error) {
      platformResponse = error.toString();
    }*/
  }
}
