import 'package:flutter/material.dart';


class TimeLinePage extends StatefulWidget {
  const TimeLinePage({Key? key}) : super(key: key);

  @override
  State<TimeLinePage> createState() => _TimeLinePageState();
}

class _TimeLinePageState extends State<TimeLinePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Text('No timeline data available'),
      ),
    );
  }
}
