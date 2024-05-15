import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/models/dental_exam_model.dart';
import 'package:pettag/models/vacination_model.dart';
import 'package:pettag/models/weight_tracker_model.dart';
import 'package:pettag/screens/appointment/widgets/date_time_functions.dart';
import 'package:pettag/utils/common_textfiels.dart';
import 'package:pettag/utils/date_time_picker.dart';
import 'package:pettag/widgets/weight_chart.dart';
import 'package:toggle_switch/toggle_switch.dart';

class WeightItem extends StatefulWidget {
  const WeightItem({Key? key, required this.title, required this.image, required this.examList,required this.onStateUpdate, required this.petId}) : super(key: key);
  final String petId;
  final String title;
  final String image;
  final List<WeightTrackerModel> examList;
  final Function onStateUpdate;


  @override
  State<WeightItem> createState() => _DentalItemState();
}

class _DentalItemState extends State<WeightItem> {
  bool isExpanded = false;
  final typeController = TextEditingController();
  String dueDate = '';
  String lastGivenDate = '';
  String format = 'kg';

  @override
  void initState() {

    super.initState();
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Column(
      key: _scaffoldKey,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.all(25.0),
          margin: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: (){
                  setState(() {
                    isExpanded = !isExpanded;
                  });
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(

                      children: [
                        CircleAvatar(
                            radius: 20.0,
                            backgroundColor: Colors.lightBlue.shade300,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(widget.image,color: Colors.white,),
                            )),
                        const SizedBox(width: 20.0,),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold),),
                            const SizedBox(height: 10.0,),
                            Row(
                              children: [
                                if(widget.examList.isEmpty)...{
                                  const CircleAvatar(
                                    radius: 6.0,
                                    backgroundColor: Colors.grey,
                                  ),
                                  const SizedBox(width: 6.0,),
                                  const Text('Nothing on file', style: TextStyle(
                                      fontSize: 12.0, color: Colors.grey),),

                                } else if(isPastDue(widget.examList.length - 1)) ...{
                                  const CircleAvatar(
                                    radius: 6.0,
                                    backgroundColor: Colors.red,
                                  ),
                                  const SizedBox(width: 6.0,),
                                  const Text('Overweight', style: TextStyle(
                                      fontSize: 12.0, color: Colors.red),)
                                } else ...{
                                  const CircleAvatar(
                                    radius: 6.0,
                                    backgroundColor: Colors.green,
                                  ),
                                  const SizedBox(width: 6.0,),
                                  const Text('Ideal', style: TextStyle(
                                      fontSize: 12.0, color: Colors.green),)
                                }
                              ],
                            )
                          ],
                        )
                      ],
                    ),
                    Icon(getArrowIcon(), color: Colors.red,)
                  ],
                ),
              ),
            ],
          ),
        ),
        if(isExpanded) ...{
          GestureDetector(
            onTap: (){
              showBottomDialog();
            },
            child: const Card(
              child: Icon(Icons.add, color: Colors.black,size: 25,),
            ),
          ),
          const SizedBox(height: 10.0),
          widget.examList.isEmpty ? const SizedBox.shrink() :
          WeightChart(examList: widget.examList),
          const SizedBox(height: 12.0),
          ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: widget.examList.length,
              itemBuilder: (BuildContext ctx, index) {
            return GestureDetector(
              onLongPress: () {
                debugPrint('---> onLongPress');
               final alert = AlertDialog(
                  title: const Text('Please confirm'),
                  content: const Text('Are you sure you want to delete?'),
                  actions: [
                    ElevatedButton(onPressed: (){
                      Navigator.pop(context);
                    }, child: const Text('Cancel')),
                    ElevatedButton(onPressed: () async {
                      Navigator.pop(context);
                      showInSnackBar('Deleted successfully');

                      await FirebaseFirestore.instance
                          .collection("Pet")
                          .doc(widget.petId)
                          .set({
                        'weight': FieldValue.arrayRemove([widget.examList[index].toJson()]),
                      }, SetOptions(merge: true)).then((value) {
                        debugPrint('---> value saved in firebase');
                        setState(() {

                          widget.examList.removeAt(index);
                        });
                      });

                    }, child: const Text('Delete')),

                  ],
                );

                // show the dialog
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return alert;
                  },
                );
              },
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(25.0),
                margin: const EdgeInsets.only(bottom: 1.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text('${widget.examList[index].weight} ${widget.examList[index].format}',style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    const Text('Date'),
                      Text(convertDateFromMillisecondsSinceEpoch(widget.examList[index].date.toString())),
                  ],),

                ],),
              ),
            );
          }),
        }
      ],
    );
  }

  bool isPastDue(int index) {
    return  false;
  }

  IconData getArrowIcon() {
    return isExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios;
  }

  void showBottomDialog() {
    final dueDateController = TextEditingController();

    showModalBottomSheet(
        isScrollControlled:true,
        isDismissible: true,
        context: _scaffoldKey.currentContext!, builder: (BuildContext ctx) {
      return Container(
        height: MediaQuery.of(context).size.height/1.2,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              titleTextField(),
              const SizedBox(height: 10.0),
            InkWell(
              onTap: () async {
                final date = await appDatePicker(context);
                final formattedDate = '${date.month}/${date.day}/${date.year}';
                dueDateController.text = formattedDate;
                dueDate = date.millisecondsSinceEpoch.toString();
              },
              child: AbsorbPointer(
                child: offerTextField(
                    controller: dueDateController,
                    iconData: Icons.date_range_outlined,
                    label: 'Date',
              ),
            )),
              const SizedBox(height: 10.0),
              SizedBox(
                height: 40.0,
                child: ToggleSwitch(
                  minHeight: 60,
                  minWidth: 100,
                  initialLabelIndex: 0,
                  activeBgColor: [Colors.red],
                  inactiveBgColor: Colors.grey.shade500,
                  totalSwitches: 2,
                  labels: ['kg', 'lb'],
                  onToggle: (index) {
                    if(index == 0) {
                      format = 'kg';
                    } else {
                      format = 'lb';
                    }
                    print('switched to: $index');
                  },
                ),
              ),
              const SizedBox(height: 10.0),

              TextButton(onPressed: () async {



                WeightTrackerModel examModel = WeightTrackerModel(
                  weight: typeController.text.toString(),
                  date: dueDate,
                  format: format,
                );

                await FirebaseFirestore.instance
                    .collection("Pet")
                    .doc(widget.petId)
                    .set({
                  'weight': FieldValue.arrayUnion([examModel.toJson()]),
                }, SetOptions(merge: true)).then((value) {
                  widget.onStateUpdate();
                  debugPrint('---> value saved in firebase');
                });
                // showInSnackBar('Saved successfully');
                debugPrint('---> title: ${widget.title}    | dueDate:  ');
                Navigator.pop(context);
                }, child:
              const Text('Submit', style: TextStyle(fontSize: 22, color: Colors.red),)),
            ],
          ),
        ),
      );
    });
  }

  Future<SnackBarClosedReason> showInSnackBar(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    return ScaffoldMessenger.of(_scaffoldKey.currentContext!).showSnackBar(snackBar).closed;
  }

  Widget titleTextField() {
    return SizedBox(
      width:  250,
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(15.0),
        child: TextFormField(
          controller: typeController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.title,
              color: Colors.red,
            ),
            labelText: 'Weight lb/kilo',
            fillColor: Colors.white,
            filled: true,
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ),
      ),
    );
  }





}
