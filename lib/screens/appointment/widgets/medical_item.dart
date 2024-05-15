import 'package:flutter/material.dart';
import 'package:pettag/screens/appointment/pages/profile_page.dart';
import 'package:toggle_switch/toggle_switch.dart';


class MedicalItem extends StatefulWidget {
  const MedicalItem({Key? key,required this.title, required this.value, required this.allergiesController}) : super(key: key);

  final String title;
  final String value;
  final TextEditingController allergiesController;

  @override
  State<MedicalItem> createState() => _AlergyItemState();
}

class _AlergyItemState extends State<MedicalItem> {

  bool isSelected = false;
  int selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isSelected = !(widget.value == null || widget.value.isEmpty || widget.value == 'null');
    selectedIndex = isSelected ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0, left: 15.0, right: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title, style: const TextStyle(fontWeight: FontWeight.bold),),

                Container(
                  height: 20.0,
                  child: ToggleSwitch(
                    minWidth: 60,
                    initialLabelIndex: selectedIndex,
                    activeBgColor: [Colors.red],
                    inactiveBgColor: Colors.grey.shade500,
                    totalSwitches: 2,
                    labels: ['No', 'Yes'],
                    onToggle: (index) {
                      if(index == 0) {
                        isSelected = false;
                        selectedIndex = 0;
                      ProfilePage.medicalController.text = '';
                      } else {
                        isSelected = true;
                        selectedIndex = 1;
                      }
                      setState(() {

                      });
                      print('switched to: $index');
                    },
                  ),
                ),

            ],
          ),
        ),
        if(isSelected)...{
          const SizedBox(height: 5.0,),
          Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0, bottom: 10.0),
            child: TextFormField(
              maxLines: null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.fromLTRB(25, 25, 25, 10),
                  hintText: 'Enter details',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(0.0),
                  ),
                ),
                controller:  ProfilePage.medicalController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Text not valid';
                  } else if(value.characters.length >500) {
                    return 'Enter less than 500 characters';
                  }else {
                    return null;
                  }
                }),
          )
        },
        Container(
          color: Colors.grey,
          height: 0.4,
          width: MediaQuery.of(context).size.width,
        )
      ],
    );
  }
}
