import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pettag/main.dart';
import 'package:pettag/widgets/generic_shadow_button.dart';

import 'package:location/location.dart' as LocationManager;
import '../constant.dart';
import 'agree_screen.dart';

class PermissionDisclosureScreen extends StatefulWidget {
  static const String permissionDisclosureRoute = 'permissionDisclosureScreen';

  const PermissionDisclosureScreen({Key? key}) : super(key: key);


  @override
  State<PermissionDisclosureScreen> createState() => _PermissionDisclosureScreenState();
}

class _PermissionDisclosureScreenState extends State<PermissionDisclosureScreen> with WidgetsBindingObserver{


  bool isPermanentlyDenied = false;
  bool returnedFromSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState appLifecycleState) async {
    super.didChangeAppLifecycleState(appLifecycleState);
    debugPrint(appLifecycleState.name);
    if (appLifecycleState == AppLifecycleState.paused) {
      //_askPermissionRun = false;
    }
    if (appLifecycleState == AppLifecycleState.resumed) {
      if (returnedFromSettings) {
        final PermissionStatus status = await Permission.location.request();

      Future.delayed(Duration(seconds: 1), (){
        if(status.isPermanentlyDenied || status.isDenied) {
          isPermanentlyDenied = true;
          setState((){});
        } else {
          Navigator.pop(context);
        }

      });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          //color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              //DemoWidget(),
              const Spacer(
                flex: 1,
              ),
              Container(
                padding: const EdgeInsets.only(
                  top: 20,
                ),
                child: Image.asset(
                  'assets/logo@3xUpdated.png',
                  width: 80,
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                "Location Permission Needed",
                style: kwordStyle(color: Colors.black).copyWith(fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),

              const SizedBox(
                height: 10,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  "PetTag requires location permission for the following features.",
                  style: kwordStyle(
                      color: Colors.black, fontWeight: FontWeight.normal)
                      .copyWith(fontSize: 17),
                ),
              ),


              const Spacer(
                flex: 1,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "1). PetTag collects location data to find best matches nearby you even when the app is closed or not in use.\n\n "
                      "2). PetTag collects location data to notify you when a match is nearby, even when the app is closed or not in use.",
                  style: TextStyle(
                      color: Colors.pink[900], fontSize: 15, height: 1.3),
                  textAlign: TextAlign.left,
                ),
              ),
              const Spacer(
                flex: 2,
              ),
              if(!isPermanentlyDenied)
              GenericBShadowButton(
                buttonText: "Grant Permission",
                onPressed: () async {
                  final PermissionStatus status = await Permission.location.request();

                  if(status.isPermanentlyDenied || status.isDenied) {
                    isPermanentlyDenied = true;
                    setState((){});
                  } else {
                    Navigator.pop(context);
                  }

                },
              ),
              if(isPermanentlyDenied)
                GenericBShadowButton(
                  buttonText: "Open Settings",
                  onPressed: () async {

                    await openAppSettings().whenComplete(() {
                      returnedFromSettings = true;
                    });
                  },
                ),
                const Spacer(
                flex: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
