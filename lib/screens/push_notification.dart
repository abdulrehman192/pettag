import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/services/sharedPref.dart';

class PushNotification extends StatefulWidget {
  static const String pushNotificationScreenRoute = "PushNotification";

  const PushNotification({super.key});
  @override
  _PushNotificationState createState() => _PushNotificationState();
}

class _PushNotificationState extends State<PushNotification> {
  bool _newMatch = false;
  bool _messages = false;
  bool _treat = false;
  bool _superTreat = false;
  bool _topPick = false;
  bool _petWall = true;
  @override
  void initState() {
    _newMatch = SharedPrefs().pushNotificationNewMatches;
    _messages = SharedPrefs().pushNotificationNewMessages;
    _treat = SharedPrefs().pushNotificationNewTreat;
    _superTreat = SharedPrefs().pushNotificationNewSuperTreat;
    _topPick = SharedPrefs().pushNotificationNewTopPick;
    _topPick = SharedPrefs().pushNotificationNewPetWall;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          splashColor: Colors.transparent,
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.redAccent,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const LocaleText(
          "notification_settings",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 17,
          ),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 5,
            ),
            const LocaleText(
              "push_notification",
              style: TextStyle(color: Colors.pink, fontWeight: FontWeight.bold, fontSize: 17),
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'new_matches'),
              onChanged: (bool value) {
                setState(() {
                  _newMatch = value;
                  SharedPrefs().pushNotificationNewMatches = value;
                });
              },
              value: _newMatch,
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'new_messages'),
              onChanged: (bool value) {
                setState(() {
                  _messages = value;
                  SharedPrefs().pushNotificationNewMessages = value;
                });
              },
              value: _messages,
            ),
            buildCupertinoOptions(
              text: "Treat",
              onChanged: (bool value) {
                setState(() {
                  _treat = value;
                  SharedPrefs().pushNotificationNewTreat = value;
                });
              },
              value: _treat,
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'supertreat'),
              onChanged: (bool value) {
                setState(() {
                  _superTreat = value;
                  SharedPrefs().pushNotificationNewSuperTreat = value;
                });
              },
              value: _superTreat,
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'top_pick'),
              onChanged: (bool value) {
                setState(() {
                  _topPick = value;
                  SharedPrefs().pushNotificationNewTopPick = value;
                });
              },
              value: _topPick,
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'pet_wall'),
              onChanged: (bool value) {
                setState(() {
                  _petWall = value;
                  SharedPrefs().pushNotificationNewPetWall = value;
                });
              },
              value: _petWall,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCupertinoOptions({String? text, onChanged, value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text.toString(),
            style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.teal,
            inactiveTrackColor: Colors.black26,
          ),
        ],
      ),
    );
  }
}
