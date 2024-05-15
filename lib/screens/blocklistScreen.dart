import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../constant.dart';

class BlocklistScreen extends StatefulWidget {
  const BlocklistScreen({super.key});

  @override
  _BlocklistScreenState createState() => _BlocklistScreenState();
}

class _BlocklistScreenState extends State<BlocklistScreen> {
  bool isBlock = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          'blocklist',
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('User')
                  .where("block_${FirebaseAuth.instance.currentUser!.uid}",
                      isEqualTo: true)
                  .snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return snapshot.data!.docs.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/block.png",
                                height: 100,
                                width: 100,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                "blocklist Empty",
                                style: GoogleFonts.poppins(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> map = snapshot.data!.docs[index]
                                .data() as Map<String, dynamic>;

                            return Container(
                              height: 70,
                              margin: const EdgeInsets.only(bottom: 10),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Colors.redAccent, width: 1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 70,
                                    width: 70,
                                    decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            bottomLeft: Radius.circular(10))),
                                    child: ClipRRect(
                                      borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(9),
                                          bottomLeft: Radius.circular(9)),
                                      child: Image.network(
                                        map['images'].length > 0
                                            ? map['images'][0]
                                            : "https://images.unsplash.com/photo-1621317911160-70ee9c68750d?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=700&q=80",
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 15,
                                  ),
                                  Text(
                                    map['firstName'] + " " + map['lastName'],
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  InkWell(
                                    onTap: () async {
                                      snapshot.data!.docs[index].reference
                                          .update({
                                        'block_${FirebaseAuth.instance.currentUser!.uid}':
                                            FieldValue.delete()
                                      });
                                      await FirebaseFirestore.instance
                                          .collection('Pet')
                                          .where('ownerId',
                                              isEqualTo:
                                                  snapshot.data!.docs[index].id)
                                          .get()
                                          .then((value) {
                                        for (var element in value.docs) {
                                          element.data().containsKey(
                                                  'block_${FirebaseAuth.instance.currentUser!.uid}')
                                              ? element.reference.update({
                                                  'block_${FirebaseAuth.instance.currentUser!.uid}':
                                                      FieldValue.delete()
                                                })
                                              : null;
                                        }
                                      });
                                      const snackBar = SnackBar(
                                          content:
                                              Text("User has been unblocked"));
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    },
                                    child: Container(
                                      height: 40,
                                      width: 70,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'Unblock',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                } else {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: mainColor,
                      backgroundColor: Colors.white,
                    ),
                  );
                }
              }),
        ),
      ),
    );
  }
}
