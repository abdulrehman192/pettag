import 'package:flutter/material.dart';

Future<DateTime> appDatePicker(BuildContext context) async {
  final _currentDatetime = DateTime.now();
  final DateTime? _picked =
      await showDatePicker(context: context, initialDate: _currentDatetime, firstDate: DateTime.now().subtract(Duration(days: 10000)), lastDate: DateTime(_currentDatetime.year + 1));

  if (_picked != null) {
    return _picked;
  }

  return _currentDatetime;
}

Future<TimeOfDay> appTimePicker(BuildContext context) async {
  final _currentTime = TimeOfDay.now();

  final TimeOfDay? _picked = await showTimePicker(
    context: context,
    initialTime: _currentTime,
    builder: (context, child) {
      return MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      );
    },
  );

  if (_picked != null) {
    return _picked;
  }

  return _currentTime;
}
