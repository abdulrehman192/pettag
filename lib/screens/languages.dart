import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:pettag/models/language_model.dart';

class Languages extends StatefulWidget {
  const Languages({Key? key}) : super(key: key);

  @override
  _LanguagesState createState() => _LanguagesState();
}

class _LanguagesState extends State<Languages> {
  List<LanguageModel> languageModel = [
    LanguageModel(pic: "assets/uk.png", name: 'English', isSelected: false),
    LanguageModel(pic: "assets/spain.png", name: 'Spanish', isSelected: false),
    LanguageModel(pic: "assets/india.png", name: 'Hindi', isSelected: false),
    LanguageModel(pic: "assets/china.png", name: 'Chinese', isSelected: false),
    LanguageModel(pic: "assets/portugal.png", name: 'Portuguese', isSelected: false)
  ];
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black, //change your color here
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15, right: 15, top: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const LocaleText(
                "language",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(
                height: 10,
              ),
              ListView(
                shrinkWrap: true,
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: (){
                          LocaleNotifier.of(context)!.change('en');
                        },
                        leading: Image.asset(
                          "assets/uk.png",
                          height: 55,
                          width: 55,
                        ),
                        title: const LocaleText(
                          'english',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: (){
                          LocaleNotifier.of(context)!.change('es');
                        },
                        leading: Image.asset(
                          "assets/spain.png",
                          height: 55,
                          width: 55,
                        ),
                        title: const LocaleText(
                          'spanish',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: (){
                          LocaleNotifier.of(context)!.change('hi');
                        },
                        leading: Image.asset(
                          "assets/india.png",
                          height: 55,
                          width: 55,
                        ),
                        title: const LocaleText(
                          'hindi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: (){

                          LocaleNotifier.of(context)!.change('zh');
                        },
                        leading: Image.asset(
                          "assets/china.png",
                          height: 55,
                          width: 55,
                        ),
                        title: const LocaleText(
                          'chinese',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ListTile(
                        onTap: () async{

                          LocaleNotifier.of(context)!.change('pt');
                        },
                        leading: Image.asset(
                          "assets/portugal.png",
                          height: 55,
                          width: 55,
                        ),
                        title: const LocaleText(
                          'portuguese',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
