import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pettag/models/dental_exam_model.dart';
import 'package:pettag/models/vacination_model.dart';
import 'package:pettag/screens/appointment/widgets/date_time_functions.dart';
import 'package:pettag/utils/common_textfiels.dart';
import 'package:pettag/utils/date_time_picker.dart';

class DentalItem extends StatefulWidget {
  const DentalItem({Key? key, required this.title, required this.image, required this.examList,required this.onStateUpdate, required this.petId}) : super(key: key);

  final String petId;
  final String title;
  final String image;
  final List<DentalExamModel> examList;
  final Function onStateUpdate;


  @override
  State<DentalItem> createState() => _DentalItemState();
}

class _DentalItemState extends State<DentalItem> {
  bool isExpanded = false;
  final typeController = TextEditingController();
  final notesController = TextEditingController();
  String dueDate = '';
  String lastGivenDate = '';

  @override
  void initState() {

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
                                  const Text('Past Due', style: TextStyle(
                                      fontSize: 12.0, color: Colors.red),)
                                } else ...{
                                  const CircleAvatar(
                                    radius: 6.0,
                                    backgroundColor: Colors.green,
                                  ),
                                  const SizedBox(width: 6.0,),
                                  const Text('Due Date', style: TextStyle(
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
                        'dental': FieldValue.arrayRemove([widget.examList[index].toJson()]),
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
                  Text('${widget.examList[index].examType}',style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                    Text('${widget.examList[index].veterinaryNotes}'),
                    const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                    const Text('Last date given'),
                      Text(convertDateFromMillisecondsSinceEpoch(widget.examList[index].lastDateGiven.toString())),
                  ],),
                  const SizedBox(height: 5,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                       isPastDue(index) ?
                        const Text('Due Date', style: TextStyle(color: Colors.red),) : const Text(  'Due Date',style: TextStyle(color: Colors.green),),
                      isPastDue(index) ?
                      Text(convertDateFromMillisecondsSinceEpoch(widget.examList[index].dueDate.toString()),
                          style: const TextStyle(color: Colors.red)) :
                      Text(convertDateFromMillisecondsSinceEpoch(widget.examList[index].dueDate.toString()), style: const TextStyle(color: Colors.green)),


                    ],),
                    const SizedBox(height: 5,),
                    if(isPastDue(index))...{
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Past Due', style: TextStyle(color: Colors.red),),
                          Text(pastDueDate(index, widget.examList[index].dueDate.toString()),
                              style: const TextStyle(color: Colors.red)),
                        ],),
                    },
                ],),
              ),
            );
          }),
        }
      ],
    );
  }

  bool isPastDue(int index) {
    return DateTime.now().millisecondsSinceEpoch > int.parse(widget.examList[index].dueDate.toString());
  }



  IconData getArrowIcon() {
    return isExpanded ? Icons.keyboard_arrow_down : Icons.arrow_forward_ios;
  }

  void showBottomDialog() {
    final dueDateController = TextEditingController();
    final lateDateController = TextEditingController();

    showModalBottomSheet(
        isScrollControlled:true,
        isDismissible: true,
        context: context, builder: (BuildContext ctx) {
      return Container(
        height: MediaQuery.of(context).size.height/1.2,
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20.0),
              titleTextField(),
              const SizedBox(height: 10.0),
              notesTextField(),
              const SizedBox(height: 10.0),
            InkWell(
              onTap: () async {
                final _date = await appDatePicker(context);
                final _formattedDate = '${_date.month}/${_date.day}/${_date.year}';
                dueDateController.text = _formattedDate;
                dueDate = _date.millisecondsSinceEpoch.toString();
              },
              child: AbsorbPointer(
                child: offerTextField(
                    controller: dueDateController,
                    iconData: Icons.date_range_outlined,
                    label: 'Due Date',
              ),
            )),
              const SizedBox(height: 10.0),
              InkWell(
                  onTap: () async {
                    final _date = await appDatePicker(context);
                    final _formattedDate = '${_date.month}/${_date.day}/${_date.year}';
                    lateDateController.text = _formattedDate;
                    lastGivenDate = _date.millisecondsSinceEpoch.toString();

                  },
                  child: AbsorbPointer(
                    child: offerTextField(
                      controller: lateDateController,
                      iconData: Icons.date_range_outlined,
                      label: 'Last date given',
                    ),
                  )),
              const SizedBox(height: 10.0),
              TextButton(onPressed: () async {
                Navigator.pop(context);
                showInSnackBar('Saved successfully');

                DentalExamModel examModel = DentalExamModel(
                  examType: typeController.text.toString(),
                  veterinaryNotes: notesController.text.toString(),
                  dueDate: dueDate,
                  lastDateGiven: lastGivenDate,

                );

                await FirebaseFirestore.instance
                    .collection("Pet")
                    .doc(widget.petId)
                    .set({
                  'dental': FieldValue.arrayUnion([examModel.toJson()]),
                }, SetOptions(merge: true)).then((value) {
                  widget.onStateUpdate();
                  debugPrint('---> value saved in firebase');
                });
                debugPrint('---> title: ${widget.title}    | dueDate:  ');
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
    return ScaffoldMessenger.of(context).showSnackBar(snackBar).closed;
  }

  Widget titleTextField() {
    return Container(
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
            labelText: 'Exam Type',
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

  Widget notesTextField() {
    return Container(
      width:  250,
      child: Material(
        elevation: 10.0,
        borderRadius: BorderRadius.circular(15.0),
        child: TextFormField(
          controller: notesController,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.title,
              color: Colors.red,
            ),
            labelText: 'Veterinary notes',
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
