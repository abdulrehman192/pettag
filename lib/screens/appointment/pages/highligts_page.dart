import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/models/dental_exam_model.dart';
import 'package:pettag/models/parasite_control_model.dart';
import 'package:pettag/models/vacination_model.dart';
import 'package:pettag/models/weight_tracker_model.dart';
import 'package:pettag/screens/appointment/widgets/comprehensive_widget.dart';
import 'package:pettag/screens/appointment/widgets/dental_widget.dart';
import 'package:pettag/screens/appointment/widgets/parasite_widget.dart';
import 'package:pettag/screens/appointment/widgets/vacination_widget.dart';
import 'package:pettag/screens/appointment/widgets/weight_widget.dart';
import 'package:pettag/utilities/firebase_credentials.dart';

class HighLightsPage extends StatefulWidget {
  const HighLightsPage({Key? key}) : super(key: key);

  @override
  State<HighLightsPage> createState() => _HighLightsPageState();
}

class _HighLightsPageState extends State<HighLightsPage> {

  String petId = '';
  Future<Map<String,dynamic>> getPetData() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    QuerySnapshot snap = await FirebaseCredentials()
        .db
        .collection('Pet')
        .where('ownerId', isEqualTo: auth.currentUser!.uid)
        .get();
    petId = snap.docs.first.id;
    return  snap.docs.first.data() as Map<String, dynamic>;
  }

  updateState(){
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(10.0),
      child: FutureBuilder(
        future: getPetData(),
        builder: (context, snapshot) {
          if (snapshot.data != null) {
            final data = snapshot.data as Map<String, dynamic>;
            List vacinationList = data['vacination'] ?? [] ;
            final List<VacinationModel> vacination = [];
            List parasiteList = data['parasite'] ?? [];
            final List<ParasiteControlModel> parasite = [];
            List dentalList = data['dental'] ?? [];
            final List<DentalExamModel> dentalExam = [];
            List comprehensiveList = data['comprehensive'] ?? [];
            final List<DentalExamModel> comprehensiveExam = [];

            List weightList = data['weight'] ?? [];
            final List<WeightTrackerModel> weightTracker = [];

            if (vacinationList != null) {
              for (final l in vacinationList) {
                final VacinationModel exam = VacinationModel.fromJson(l);
                vacination.add(exam);
              }
            }

            if (parasiteList != null) {
              for (final l in parasiteList) {
                final ParasiteControlModel exam = ParasiteControlModel.fromJson(
                    l);
                parasite.add(exam);
              }
            }

            if (dentalList != null) {
              for (final l in dentalList) {
                final DentalExamModel exam = DentalExamModel.fromJson(l);
                dentalExam.add(exam);
              }
            }

            if (comprehensiveList != null) {
              for (final l in comprehensiveList) {
                final DentalExamModel exam = DentalExamModel.fromJson(l);
                comprehensiveExam.add(exam);
              }
            }

            if (weightList != null) {
              for (final l in weightList) {
                final WeightTrackerModel exam = WeightTrackerModel.fromJson(l);
                weightTracker.add(exam);
              }
              print("length : ${weightTracker.length}");
            }


            return SingleChildScrollView(
              child: Column(
                children: [
                  VacinationItem(
                    petId: petId,
                    title: 'Vacinations',
                    image: 'assets/icon/injection.png',
                    examList: vacination,
                    onStateUpdate: () {
                      debugPrint('---> on stateUPdate called');
                      updateState();
                    },),
                  ParasiteItem(
                    petId: petId,
                    title: 'Parasite control',
                    image: 'assets/icon/parasite.png',
                    examList: parasite,
                    onStateUpdate: () {
                      setState(() {

                      });
                    },),
                  DentalItem(
                    petId: petId,
                    title: 'Dental exam',
                    image: 'assets/icon/tooth.png',
                    examList: dentalExam,
                    onStateUpdate: () {
                      setState(() {

                      });
                    },),
                  ComprehensiveItem(
                    petId: petId,
                    title: 'Comprehensive exam',
                    image: 'assets/icon/medical.png',
                    examList: comprehensiveExam,
                    onStateUpdate: () {
                      setState(() {

                      });
                    },),
                  WeightItem(
                    petId: petId,
                    title: 'Weight tracker',
                    image: 'assets/icon/weight-scale.png',
                    examList: weightTracker,
                    onStateUpdate: () {
                      setState(() {

                      });
                    },),
                ],
              ),
            );
          }
          else
            {
              return const Center(child: CircularProgressIndicator());
            }
        }
      ),
    );
  }
}
