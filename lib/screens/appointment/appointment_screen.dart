import 'package:flutter/material.dart';
import 'package:pettag/screens/appointment/pages/highligts_page.dart';
import 'package:pettag/screens/appointment/pages/profile_page.dart';
import 'package:pettag/screens/appointment/pages/time_line_page.dart';

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({Key? key}) : super(key: key);
  static const String appointmentScreenRoute = 'appointmentScreen';

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.grey.shade300,
        appBar: AppBar(
          backgroundColor: Colors.red,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Highlights'),
              Tab(text: 'Timeline'),
              Tab(text: 'Profile'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            HighLightsPage(),
            TimeLinePage(),
            ProfilePage(),
          ],
        ),
      ),
    );
  }
}
