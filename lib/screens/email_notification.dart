import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:pettag/services/sharedPref.dart';

class EmailNotification extends StatefulWidget {
  static const String emailNotificationScreenRoute = "EmailNotification";

  const EmailNotification({super.key});
  @override
  _EmailNotificationState createState() => _EmailNotificationState();
}

class _EmailNotificationState extends State<EmailNotification> {
  bool newMatch = false;
  bool newMessage = false;

  @override
  void initState() {
    newMessage = SharedPrefs().emailNewMessageNotification;
    newMatch = SharedPrefs().emailNewMatchNotification;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          "notification",
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
              "email_notification",
              style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 17),
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'new_matches'),
              onChanged: (bool value) {
                setState(() {
                  newMatch = value;
                  SharedPrefs().emailNewMatchNotification = value;
                });
              },
              value: newMatch,
            ),
            buildCupertinoOptions(
              text: Locales.string(context, 'new_messages'),
              onChanged: (bool value) {
                setState(() {
                  newMessage = value;
                  SharedPrefs().emailNewMessageNotification = value;
                });
              },
              value: newMessage,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildCupertinoOptions({required String text, onChanged, value}) {
    return Padding(
      padding: const EdgeInsets.only(left: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text,
            style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 15),
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
