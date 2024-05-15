import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pettag/screens/appointment/widgets/alergy_item.dart';
import 'package:pettag/screens/appointment/widgets/medical_item.dart';
import 'package:pettag/screens/appointment/widgets/profile_item.dart';
import 'package:pettag/utilities/firebase_credentials.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static TextEditingController allergyController = TextEditingController();
  static TextEditingController medicalController = TextEditingController();
  static TextEditingController srController = TextEditingController();
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  Map<String, dynamic> data = {};
  Future<Map<String,dynamic>> getPetData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    QuerySnapshot snap = await FirebaseCredentials()
        .db
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser!.uid)
        .get();

    if(snap.docs.first.data() != null)
      {
        data = snap.docs.first.data() as Map<String, dynamic>;
        ProfilePage.allergyController.text = data['allergies'].toString();
        ProfilePage.medicalController.text = data['medical'].toString();
        ProfilePage.srController.text = data['sr'] ?? "";
        _birthday = data['birthday'] == null ? _birthday : DateTime.fromMillisecondsSinceEpoch(int.parse(data['birthday'].toString()));
        setState(() {

        });
      }
    return  data;
  }

  DateTime _birthday = DateTime.now();
  String sr = '';
  @override
  void initState() {
    getPetData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return data.isEmpty ? const  Center(child:  CircularProgressIndicator(),) :
      Container(
      color: Colors.white,
      margin: const EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            CircleAvatar(
              radius: 70.0,
              backgroundColor: Colors.lightBlue.shade200,
              backgroundImage: showImage(data['images'][0]),
            ),
            const SizedBox(height: 20.0),
            ProfileItem(title: 'Name',value: data['name'].toString()),
            ProfileItem(title: 'Breed',value: data['breed'].toString()),
            ProfileItem(title: 'Sex',value: data['sex'].toString()),
            ProfileItem(title: 'Size',value:  data['size'].toString()),
            ProfileItem(title: 'Type',value:  data['type'].toString()),
            ProfileItem(title: 'Birthday',
              value: _birthday == DateTime.now() ? "Add Birthday" : DateFormat("dd-MMM-yyyy").format(_birthday),
              onTap: ()async{
                DateTime initialDate = data['birthday'] == null ? DateTime.now() : DateTime.fromMillisecondsSinceEpoch(int.parse(data['birthday'].toString()));
                var date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now()
                );
                if(date != null)
                {
                  _birthday = date;
                  setState(() {

                  });
                }
              },
            ),
            ProfileItem(title: 'Age',value: data['age'].toString()),
            ProfileItem(title: 'Behaviour',value: data['behaviour'].toString()),
            Padding(
              padding: const EdgeInsets.only(top: 10.0, bottom: 10.0, left: 15.0, right: 15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children:  [
                  const Text("Microchip Tag Number", style: TextStyle(fontWeight: FontWeight.bold),),
                  SizedBox(
                      width: MediaQuery.of(context).size.width * 0.40,
                      height: 30,
                      child: TextField(
                        controller: ProfilePage.srController,
                        keyboardType: TextInputType.number,
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ], // Only numbers can be entered
                        textAlign: TextAlign.center,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val)
                        {
                          sr = val;
                        },
                      )
                  )
                ],
              ),
            ),
            const Divider(),
            AlergyItem(title: 'Allergies',value: data['allergies'].toString(), allergiesController: ProfilePage.allergyController,),
            MedicalItem(title: 'Medical condition',value: data['medical'].toString(), allergiesController: ProfilePage.medicalController,),
            const SizedBox(height: 10.0,),
            GenericBShadowButton(
              buttonText:'Save',
              onPressed: () async {
                FocusScope.of(context).unfocus();
                await FirebaseCredentials()
                    .db
                    .collection('Pet')
                    .where("ownerId", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                    .get()
                    .then((value) {
                  for (var element in value.docs) {
                    element.reference.set(
                        {
                          'allergies': ProfilePage.allergyController.text.toString(),
                          'medical': ProfilePage.medicalController.text.toString(),
                          'birthday' : _birthday.millisecondsSinceEpoch,
                          'sr' : sr
                        }, SetOptions(merge: true));
                  }
                }).then((value) {
                  // setState(() {
                  showInSnackBar('Saved successfully');
                  getPetData();
                  // });
                });
                setState(() {

                });
              },
              width: MediaQuery.of(context).size.width / 1.4,
              height: 50,
            ),
            const SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }


  Future<SnackBarClosedReason> showInSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    return ScaffoldMessenger.of(context).showSnackBar(snackBar).closed;
  }

  showImage(String? url) {
    if(url != null)
      {
        return NetworkImage(url);
      }
    else
    {
      return const AssetImage("assets/profile.png");
    }
  }
}
