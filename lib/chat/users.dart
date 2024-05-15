import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pettag/chat/repo/route_argument.dart';

class Users extends StatefulWidget {
  @override
  _UsersState createState() => _UsersState();
}

class _UsersState extends State<Users> {
  FirebaseAuth auth = FirebaseAuth.instance;
  String? userId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('User').where('id', isNotEqualTo: auth.currentUser!.uid).snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasData) {
            int length = snapshot.data!.docs.length;
            return ListView.builder(
              itemBuilder: (context, index) {
                Map<String, dynamic>? data = snapshot.data!.docs[index].data()! as Map<String, dynamic>?;
                return ListTile(
                  onTap: () async {
                    User? user = FirebaseAuth.instance.currentUser;
                    String userId = FirebaseAuth.instance.currentUser!.uid;
                    SharedPreferences prefs = await SharedPreferences.getInstance();
                    await prefs.setString('id', userId);
                    DocumentSnapshot doc = await FirebaseFirestore.instance
                        .collection('User')
                        .doc(data!['id'])
                        .get();

                    Navigator.of(context).pushNamed('/chat',
                        arguments: RouteArgument(
                            param1: doc['id'],
                            param2: doc['pictureUrl'] ?? 'default',
                            param3: doc['email'] ?? 'User'));
                  },
                  title: Text('${data!['email']}', style: const TextStyle(color: Colors.black),)
                );
              },
              padding: const EdgeInsets.all(10),
              itemCount: length,
            );
          }
          return const Center(child: Text('No Data'));
        },
      ),
    );
  }
}
